import 'package:city_builder/core/terrain_type.dart';
import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:flutter/material.dart';

class Minimap extends StatelessWidget {
  const Minimap({super.key, required this.tileMap, required this.onClose});

  final TileMap tileMap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Karte',
                    style: TextStyle(color: Colors.white38, fontSize: 10)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(Icons.close,
                      color: Colors.white24, size: 10),
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(128, 128),
            painter: _MinimapPainter(tileMap),
          ),
        ],
      ),
    );
  }
}

class _MinimapPainter extends CustomPainter {
  _MinimapPainter(this.tileMap);
  final TileMap tileMap;

  static const _terrainColors = {
    TerrainType.grass: Color(0xFF2E7D32),
    TerrainType.water: Color(0xFF1565C0),
    TerrainType.hill: Color(0xFF6D4C41),
    TerrainType.forest: Color(0xFF1B5E20),
  };

  static const _zoneColors = {
    ZoneType.residential: Color(0xFF4CAF50),
    ZoneType.commercial: Color(0xFF2196F3),
    ZoneType.industrial: Color(0xFFFF9800),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final pixelW = size.width / tileMap.width;
    final pixelH = size.height / tileMap.height;

    for (var row = 0; row < tileMap.height; row++) {
      for (var col = 0; col < tileMap.width; col++) {
        final pos = (col: col, row: row);
        final data = tileMap.getData(pos);

        Color color;
        if (data.hasPowerPlant) {
          color = const Color(0xFFFFCC02);
        } else if (data.hasWaterTower) {
          color = const Color(0xFF00BCD4);
        } else if (data.hasPark) {
          color = const Color(0xFF00C853);
        } else if (data.zone != null && data.buildingLevel.hasBuilding) {
          color = _zoneColors[data.zone!] ?? const Color(0xFF888888);
        } else if (data.zone != null) {
          final base = _zoneColors[data.zone!] ?? const Color(0xFF888888);
          color = Color.lerp(base, Colors.black, 0.6)!;
        } else if (data.hasRoad) {
          color = const Color(0xFF555555);
        } else {
          color = _terrainColors[data.terrain] ?? const Color(0xFF333333);
        }

        canvas.drawRect(
          Rect.fromLTWH(col * pixelW, row * pixelH, pixelW + 0.5, pixelH + 0.5),
          Paint()..color = color,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter old) => old.tileMap != tileMap;
}
