import 'package:city_builder/core/terrain_type.dart';
import 'package:city_builder/core/tile_map.dart';
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
}
