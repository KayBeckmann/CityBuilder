import 'package:flutter/material.dart';

enum TerrainType {
  grass,
  water,
  hill,
  forest;

  Color get debugColor => switch (this) {
        TerrainType.grass => const Color(0xFF4CAF50),
        TerrainType.water => const Color(0xFF2196F3),
        TerrainType.hill => const Color(0xFF795548),
        TerrainType.forest => const Color(0xFF1B5E20),
      };
}
