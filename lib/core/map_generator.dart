import 'dart:math';

import 'package:city_builder/core/resource_type.dart';
import 'package:city_builder/core/simplex_noise.dart';
import 'package:city_builder/core/terrain_type.dart';
import 'package:city_builder/core/tile_map.dart';

enum MapSize { small, medium, large }

extension MapSizeExt on MapSize {
  int get tiles => switch (this) {
        MapSize.small => 64,
        MapSize.medium => 128,
        MapSize.large => 256,
      };
}

class MapGenerator {
  const MapGenerator();

  TileMap generate({
    required int seed,
    required MapSize size,
  }) {
    final noise = SimplexNoise(seed);
    final side = size.tiles;
    final map = TileMap(width: side, height: side);
    const scale = 0.03;

    for (var row = 0; row < side; row++) {
      for (var col = 0; col < side; col++) {
        final elevation = noise.octave(col * scale, row * scale);
        map.set((col: col, row: row), _elevationToTerrain(elevation));
      }
    }

    _placeForests(map, seed);
    _placeResources(map, seed);

    return map;
  }

  TerrainType _elevationToTerrain(double elevation) {
    if (elevation < -0.15) return TerrainType.water;
    if (elevation > 0.35) return TerrainType.hill;
    return TerrainType.grass;
  }

  void _placeForests(TileMap map, int seed) {
    final rng = Random(seed ^ 0xDEADBEEF);
    final forestCount = (map.tileCount * 0.05).round();

    for (var i = 0; i < forestCount; i++) {
      final col = rng.nextInt(map.width);
      final row = rng.nextInt(map.height);
      final pos = (col: col, row: row);
      if (map.get(pos) == TerrainType.grass) {
        map.set(pos, TerrainType.forest);
      }
    }
  }

  void _placeResources(TileMap map, int seed) {
    final rng = Random(seed ^ 0xCAFEBABE);
    const resources = ResourceType.values;
    final totalDeposits = (map.tileCount * 0.02).round();

    for (var i = 0; i < totalDeposits; i++) {
      final col = rng.nextInt(map.width);
      final row = rng.nextInt(map.height);
      final pos = (col: col, row: row);
      final terrain = map.get(pos);
      if (terrain != TerrainType.water) {
        final resource = resources[rng.nextInt(resources.length)];
        map.setResource(pos, resource);
      }
    }
  }
}
