import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/overlay_type.dart';
import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/world_position.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:city_builder/game/sprite_registry.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TileMapComponent extends Component with HasGameReference {
  TileMapComponent({required this.tileMap});

  final TileMap tileMap;

  OverlayType activeOverlay = OverlayType.none;
  Map<WorldPosition, double> overlayValues = const {};

  static const double _borderWidth = 0.5;
  static final _borderPaint = Paint()
    ..color = Colors.black26
    ..style = PaintingStyle.stroke
    ..strokeWidth = _borderWidth;

  static final _roadPaint = Paint()..color = const Color(0xFF555555);
  static final _roadEdgePaint = Paint()..color = const Color(0xFF444444);
  static final _powerLinePaint = Paint()
    ..color = const Color(0xFFFFEE58)
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke;
  static final _pipePaint = Paint()..color = const Color(0xFF1565C0);
  static final _powerPlantPaint = Paint()..color = const Color(0xFFFFCC02);
  static final _powerPlantBgPaint = Paint()..color = const Color(0xFF333300);
  static final _waterTowerPaint = Paint()..color = const Color(0xFF00BCD4);
  static final _waterTowerBgPaint = Paint()..color = const Color(0xFF002030);

  // Zone tints (shown when no overlay, no building sprite)
  static final _zoneTints = {
    ZoneType.residential: const Color(0x4032CD32),
    ZoneType.commercial: const Color(0x402196F3),
    ZoneType.industrial: const Color(0x40FFA500),
  };

  // Building level debug colors (fallback when sprites not loaded)
  static final _buildingColors = {
    (ZoneType.residential, BuildingLevel.small): const Color(0xFFAED581),
    (ZoneType.residential, BuildingLevel.medium): const Color(0xFF7CB342),
    (ZoneType.residential, BuildingLevel.large): const Color(0xFF33691E),
    (ZoneType.commercial, BuildingLevel.small): const Color(0xFF64B5F6),
    (ZoneType.commercial, BuildingLevel.medium): const Color(0xFF1E88E5),
    (ZoneType.commercial, BuildingLevel.large): const Color(0xFF0D47A1),
    (ZoneType.industrial, BuildingLevel.small): const Color(0xFFFFCC80),
    (ZoneType.industrial, BuildingLevel.medium): const Color(0xFFFF9800),
    (ZoneType.industrial, BuildingLevel.large): const Color(0xFFE65100),
  };

  final _labelPainter = TextPainter(textDirection: TextDirection.ltr);

  void updateOverlay(OverlayType overlay, Map<WorldPosition, double> values) {
    activeOverlay = overlay;
    overlayValues = values;
  }

  @override
  void render(Canvas canvas) {
    final camera = game.camera;
    final visibleRect = camera.visibleWorldRect;
    final registry = SpriteRegistry.I;
    final zoom = camera.viewfinder.zoom;
    final showLabels = zoom >= 1.5;

    final firstCol = (visibleRect.left / kTileSize).floor().clamp(0, tileMap.width - 1);
    final lastCol = (visibleRect.right / kTileSize).ceil().clamp(0, tileMap.width);
    final firstRow = (visibleRect.top / kTileSize).floor().clamp(0, tileMap.height - 1);
    final lastRow = (visibleRect.bottom / kTileSize).ceil().clamp(0, tileMap.height);

    for (var row = firstRow; row < lastRow; row++) {
      for (var col = firstCol; col < lastCol; col++) {
        final pos = (col: col, row: row);
        final data = tileMap.getData(pos);
        final screenPos = pos.toScreen();
        final rect = Rect.fromLTWH(screenPos.x, screenPos.y, kTileSize, kTileSize);
        final destSize = Vector2(kTileSize, kTileSize);

        // ── Terrain ──────────────────────────────────────────────────
        final terrainSprite = registry.terrainSprite(data.terrain);
        if (terrainSprite != null) {
          terrainSprite.render(canvas, position: screenPos, size: destSize);
        } else {
          canvas.drawRect(rect, Paint()..color = data.terrain.debugColor);
        }

        // ── Zone / Building ──────────────────────────────────────────
        final zone = data.zone;
        if (zone != null) {
          if (data.buildingLevel.hasBuilding) {
            final buildingSprite = registry.buildingSprite(zone, data.buildingLevel);
            if (buildingSprite != null) {
              buildingSprite.render(canvas, position: screenPos, size: destSize);
            } else {
              // Fallback: colored fill + height indicator
              final color = _buildingColors[(zone, data.buildingLevel)] ??
                  (_zoneTints[zone] ?? Colors.grey);
              canvas.drawRect(rect, Paint()..color = color);
              _drawBuildingHeight(canvas, rect, data.buildingLevel);
            }
          } else if (activeOverlay == OverlayType.none) {
            // Empty zone — subtle tint + dashed border
            final tint = _zoneTints[zone];
            if (tint != null) canvas.drawRect(rect, Paint()..color = tint);
            _drawZoneBorder(canvas, rect, zone);
          }
        }

        // ── Infrastructure layer ──────────────────────────────────────
        if (data.hasRoad) {
          if (!data.buildingLevel.hasBuilding) {
            _drawRoadConnections(canvas, rect, pos);
          } else {
            // Small road strip at bottom when building is present
            canvas.drawRect(
              Rect.fromLTWH(rect.left + 1, rect.bottom - 4, rect.width - 2, 3),
              _roadEdgePaint,
            );
          }
        }
        if (data.hasPowerLine) {
          // Power line: yellow cross from center to edges
          final cx = rect.center.dx;
          final cy = rect.center.dy;
          canvas.drawLine(Offset(rect.left, cy), Offset(rect.right, cy), _powerLinePaint);
          canvas.drawLine(Offset(cx, rect.top), Offset(cx, rect.bottom), _powerLinePaint);
        }
        if (data.hasPipe) {
          // Pipe: small blue square in bottom-right corner
          canvas.drawRect(
            Rect.fromLTWH(rect.right - 5, rect.bottom - 5, 4, 4),
            _pipePaint,
          );
        }
        if (data.hasPowerPlant) {
          canvas.drawRect(rect.deflate(1), _powerPlantBgPaint);
          final cx = rect.center.dx;
          final cy = rect.center.dy;
          final path = Path()
            ..moveTo(cx + 3, rect.top + 4)
            ..lineTo(cx - 2, cy)
            ..lineTo(cx + 1, cy)
            ..lineTo(cx - 3, rect.bottom - 4)
            ..lineTo(cx + 3, cy + 2)
            ..lineTo(cx - 1, cy + 2)
            ..close();
          canvas.drawPath(path, _powerPlantPaint);
        }
        if (data.hasWaterTower) {
          canvas.drawRect(rect.deflate(1), _waterTowerBgPaint);
          // Draw a simple water drop shape
          final cx = rect.center.dx;
          final top = rect.top + 5;
          final bottom = rect.bottom - 4;
          final path = Path()
            ..moveTo(cx, top)
            ..lineTo(cx + 5, (top + bottom) * 0.55)
            ..arcToPoint(
              Offset(cx - 5, (top + bottom) * 0.55),
              radius: const Radius.circular(5),
              clockwise: false,
            )
            ..close();
          canvas.drawPath(path, _waterTowerPaint);
        }

        // ── Overlay heatmap ──────────────────────────────────────────
        if (activeOverlay != OverlayType.none) {
          final value = overlayValues[pos] ?? 0.0;
          if (value > 0) {
            final color = Color.lerp(activeOverlay.lowColor, activeOverlay.highColor, value)!;
            canvas.drawRect(rect, Paint()..color = color);
          }
        }

        // ── Grid lines ────────────────────────────────────────────────
        canvas.drawRect(rect, _borderPaint);

        // ── Zone label (high zoom only) ───────────────────────────────
        if (showLabels && zone != null && activeOverlay == OverlayType.none) {
          _drawLabel(canvas, rect, zone.label);
        }
      }
    }
  }

  void _drawBuildingHeight(Canvas canvas, Rect tile, BuildingLevel level) {
    // Draw "shadow/depth" lines to indicate building height
    final bars = level.index; // 1=small, 2=medium, 3=large
    const barH = 3.0;
    const gap = 2.0;
    final paint = Paint()..color = Colors.black38;
    for (var i = 0; i < bars; i++) {
      final y = tile.bottom - 4 - i * (barH + gap);
      canvas.drawRect(
        Rect.fromLTWH(tile.left + 2, y, tile.width - 4, barH),
        paint,
      );
    }
  }

  void _drawZoneBorder(Canvas canvas, Rect tile, ZoneType zone) {
    final color = switch (zone) {
      ZoneType.residential => const Color(0xFF4CAF50),
      ZoneType.commercial => const Color(0xFF2196F3),
      ZoneType.industrial => const Color(0xFFFF9800),
    };
    canvas.drawRect(
      tile,
      Paint()
        ..color = color.withAlpha(180)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  bool _neighborHasRoad(WorldPosition pos, int dc, int dr) {
    final n = (col: pos.col + dc, row: pos.row + dr);
    if (!n.isValid(tileMap.width, tileMap.height)) return false;
    return tileMap.getData(n).hasRoad;
  }

  void _drawRoadConnections(Canvas canvas, Rect rect, WorldPosition pos) {
    const arm = 6.0; // half-width of road arm
    final cx = rect.left + kTileSize / 2;
    final cy = rect.top + kTileSize / 2;

    // Center square
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, cy), width: arm * 2, height: arm * 2),
      _roadPaint,
    );

    // Arms toward road neighbors
    if (_neighborHasRoad(pos, -1, 0)) {
      canvas.drawRect(Rect.fromLTWH(rect.left, cy - arm, cx - rect.left - arm, arm * 2), _roadPaint);
    }
    if (_neighborHasRoad(pos, 1, 0)) {
      canvas.drawRect(Rect.fromLTWH(cx + arm, cy - arm, rect.right - cx - arm, arm * 2), _roadPaint);
    }
    if (_neighborHasRoad(pos, 0, -1)) {
      canvas.drawRect(Rect.fromLTWH(cx - arm, rect.top, arm * 2, cy - rect.top - arm), _roadPaint);
    }
    if (_neighborHasRoad(pos, 0, 1)) {
      canvas.drawRect(Rect.fromLTWH(cx - arm, cy + arm, arm * 2, rect.bottom - cy - arm), _roadPaint);
    }
  }

  void _drawLabel(Canvas canvas, Rect tile, String text) {
    _labelPainter.text = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 8,
        fontWeight: FontWeight.w700,
      ),
    );
    _labelPainter.layout();
    _labelPainter.paint(
      canvas,
      Offset(
        tile.left + (tile.width - _labelPainter.width) / 2,
        tile.top + (tile.height - _labelPainter.height) / 2,
      ),
    );
  }
}
