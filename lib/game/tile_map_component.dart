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

  static final _zoneOverlayPaints = {
    ZoneType.residential: Paint()..color = const Color(0x3032CD32),
    ZoneType.commercial: Paint()..color = const Color(0x300000FF),
    ZoneType.industrial: Paint()..color = const Color(0x30FFA500),
  };

  void updateOverlay(OverlayType overlay, Map<WorldPosition, double> values) {
    activeOverlay = overlay;
    overlayValues = values;
  }

  @override
  void render(Canvas canvas) {
    final camera = game.camera;
    final visibleRect = camera.visibleWorldRect;
    final registry = SpriteRegistry.I;

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

        // ── Building sprite ──────────────────────────────────────────
        if (data.zone != null && data.buildingLevel.hasBuilding) {
          final buildingSprite = registry.buildingSprite(data.zone!, data.buildingLevel);
          if (buildingSprite != null) {
            buildingSprite.render(canvas, position: screenPos, size: destSize);
          } else if (activeOverlay == OverlayType.none) {
            final zonePaint = _zoneOverlayPaints[data.zone!];
            if (zonePaint != null) canvas.drawRect(rect, zonePaint);
          }
        }

        // ── Zone tint (no sprites loaded yet) ────────────────────────
        if (data.zone != null && !data.buildingLevel.hasBuilding &&
            activeOverlay == OverlayType.none) {
          final zonePaint = _zoneOverlayPaints[data.zone!];
          if (zonePaint != null) canvas.drawRect(rect, zonePaint);
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
      }
    }
  }
}
