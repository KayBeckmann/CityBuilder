import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/world_position.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class TileMapComponent extends Component with HasGameReference {
  TileMapComponent({required this.tileMap});

  final TileMap tileMap;

  static const double _borderWidth = 0.5;
  static final _borderPaint = Paint()
    ..color = Colors.black26
    ..style = PaintingStyle.stroke
    ..strokeWidth = _borderWidth;

  @override
  void render(Canvas canvas) {
    final camera = game.camera;
    final visibleRect = camera.visibleWorldRect;

    final firstCol = (visibleRect.left / kTileSize).floor().clamp(0, tileMap.width - 1);
    final lastCol = (visibleRect.right / kTileSize).ceil().clamp(0, tileMap.width);
    final firstRow = (visibleRect.top / kTileSize).floor().clamp(0, tileMap.height - 1);
    final lastRow = (visibleRect.bottom / kTileSize).ceil().clamp(0, tileMap.height);

    for (var row = firstRow; row < lastRow; row++) {
      for (var col = firstCol; col < lastCol; col++) {
        final pos = (col: col, row: row);
        final terrain = tileMap.get(pos);
        final screenPos = pos.toScreen();

        final rect = Rect.fromLTWH(screenPos.x, screenPos.y, kTileSize, kTileSize);

        canvas.drawRect(
          rect,
          Paint()..color = terrain.debugColor,
        );
        canvas.drawRect(rect, _borderPaint);
      }
    }
  }
}
