import 'package:flutter/material.dart';

enum TerrainType {
  grass,
  water,
  hill,
  forest;

  String get label => switch (this) {
        TerrainType.grass => 'Wiese',
        TerrainType.water => 'Wasser',
        TerrainType.hill => 'Hügel',
        TerrainType.forest => 'Wald',
      };

  Color get debugColor => switch (this) {
        TerrainType.grass => const Color(0xFF4CAF50),
        TerrainType.water => const Color(0xFF2196F3),
        TerrainType.hill => const Color(0xFF795548),
        TerrainType.forest => const Color(0xFF1B5E20),
      };
}
