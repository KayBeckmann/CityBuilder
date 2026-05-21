import 'package:city_builder/core/terrain_type.dart';
import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TileMap', () {
    test('constructed with correct dimensions', () {
      final map = TileMap(width: 64, height: 32);
      expect(map.width, 64);
      expect(map.height, 32);
      expect(map.tileCount, 64 * 32);
    });

    test('default terrain is grass', () {
      final map = TileMap(width: 4, height: 4);
      for (var row = 0; row < 4; row++) {
        for (var col = 0; col < 4; col++) {
          expect(map.get((col: col, row: row)), TerrainType.grass);
        }
      }
    });

    test('set and get terrain type', () {
      final map = TileMap(width: 8, height: 8);
      const pos = (col: 3, row: 5);
      map.set(pos, TerrainType.water);
      expect(map.get(pos), TerrainType.water);
    });

    test('set does not affect neighbouring tiles', () {
      final map = TileMap(width: 8, height: 8);
      const pos = (col: 3, row: 3);
      map.set(pos, TerrainType.hill);

      expect(map.get((col: 2, row: 3)), TerrainType.grass);
      expect(map.get((col: 4, row: 3)), TerrainType.grass);
      expect(map.get((col: 3, row: 2)), TerrainType.grass);
      expect(map.get((col: 3, row: 4)), TerrainType.grass);
    });

    test('contains returns true for valid positions', () {
      final map = TileMap(width: 10, height: 10);
      expect(map.contains((col: 0, row: 0)), isTrue);
      expect(map.contains((col: 9, row: 9)), isTrue);
    });

    test('contains returns false for out-of-bounds', () {
      final map = TileMap(width: 10, height: 10);
      expect(map.contains((col: -1, row: 0)), isFalse);
      expect(map.contains((col: 10, row: 0)), isFalse);
      expect(map.contains((col: 0, row: 10)), isFalse);
    });
  });

  group('TileMap version counter', () {
    test('starts at 0', () {
      final map = TileMap(width: 5, height: 5);
      expect(map.version, 0);
    });

    test('increments on setZone', () {
      final map = TileMap(width: 5, height: 5);
      final v0 = map.version;
      map.setZone((col: 0, row: 0), ZoneType.residential);
      expect(map.version, greaterThan(v0));
    });

    test('increments on setRoad', () {
      final map = TileMap(width: 5, height: 5);
      final v0 = map.version;
      map.setRoad((col: 1, row: 1));
      expect(map.version, greaterThan(v0));
    });

    test('increments on clearAll', () {
      final map = TileMap(width: 5, height: 5);
      map.setRoad((col: 0, row: 0));
      final v0 = map.version;
      map.clearAll((col: 0, row: 0));
      expect(map.version, greaterThan(v0));
    });
  });

  group('TileMap flood-fill cache', () {
    test('computePoweredTiles returns same object when map unchanged', () {
      final map = TileMap(width: 5, height: 5);
      map.setPowerPlant((col: 2, row: 2));
      map.setPowerLine((col: 3, row: 2));
      final r1 = map.computePoweredTiles();
      final r2 = map.computePoweredTiles();
      expect(identical(r1, r2), isTrue);
    });

    test('computePoweredTiles recomputes after mutation', () {
      final map = TileMap(width: 5, height: 5);
      map.setPowerPlant((col: 2, row: 2));
      final r1 = map.computePoweredTiles();
      map.setPowerLine((col: 3, row: 2));
      final r2 = map.computePoweredTiles();
      expect(identical(r1, r2), isFalse);
      expect(r2.contains((col: 3, row: 2)), isTrue);
    });

    test('computeWateredTiles cached correctly', () {
      final map = TileMap(width: 5, height: 5);
      map.setWaterTower((col: 1, row: 1));
      map.setPipe((col: 2, row: 1));
      final r1 = map.computeWateredTiles();
      final r2 = map.computeWateredTiles();
      expect(identical(r1, r2), isTrue);
      expect(r1.contains((col: 2, row: 1)), isTrue);
    });

    test('computeWateredTiles recomputes after mutation', () {
      final map = TileMap(width: 5, height: 5);
      map.setWaterTower((col: 1, row: 1));
      final r1 = map.computeWateredTiles();
      map.setPipe((col: 2, row: 1));
      final r2 = map.computeWateredTiles();
      expect(identical(r1, r2), isFalse);
    });
  });
}
