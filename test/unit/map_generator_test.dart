import 'package:city_builder/core/map_generator.dart';
import 'package:city_builder/core/terrain_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = MapGenerator();

  group('MapGenerator', () {
    test('generate with same seed produces identical maps', () {
      final map1 = generator.generate(seed: 1337, size: MapSize.small);
      final map2 = generator.generate(seed: 1337, size: MapSize.small);

      for (var row = 0; row < map1.height; row++) {
        for (var col = 0; col < map1.width; col++) {
          final pos = (col: col, row: row);
          expect(map1.get(pos), map2.get(pos),
              reason: 'Mismatch at ($col, $row)');
        }
      }
    });

    test('generate with different seeds produces different maps', () {
      final map1 = generator.generate(seed: 0, size: MapSize.small);
      final map2 = generator.generate(seed: 999, size: MapSize.small);

      var differences = 0;
      for (var row = 0; row < map1.height; row++) {
        for (var col = 0; col < map1.width; col++) {
          final pos = (col: col, row: row);
          if (map1.get(pos) != map2.get(pos)) differences++;
        }
      }
      expect(differences, greaterThan(100));
    });

    test('small map has correct dimensions', () {
      final map = generator.generate(seed: 0, size: MapSize.small);
      expect(map.width, 64);
      expect(map.height, 64);
    });

    test('medium map has correct dimensions', () {
      final map = generator.generate(seed: 0, size: MapSize.medium);
      expect(map.width, 128);
      expect(map.height, 128);
    });

    test('map contains all terrain types', () {
      final map = generator.generate(seed: 42, size: MapSize.medium);
      final terrains = <TerrainType>{};
      for (var row = 0; row < map.height; row++) {
        for (var col = 0; col < map.width; col++) {
          terrains.add(map.get((col: col, row: row)));
        }
      }
      expect(terrains, containsAll([TerrainType.grass, TerrainType.water, TerrainType.hill]));
    });

    test('no resources placed on water tiles', () {
      final map = generator.generate(seed: 42, size: MapSize.medium);
      for (var row = 0; row < map.height; row++) {
        for (var col = 0; col < map.width; col++) {
          final pos = (col: col, row: row);
          if (map.get(pos) == TerrainType.water) {
            expect(map.getResource(pos), isNull,
                reason: 'Water tile at ($col, $row) should have no resource');
          }
        }
      }
    });
  });
}
