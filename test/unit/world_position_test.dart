import 'package:city_builder/core/world_position.dart';
import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorldPosition', () {
    test('toScreen converts correctly', () {
      const pos = (col: 3, row: 5);
      final screen = pos.toScreen();
      expect(screen, Vector2(3 * kTileSize, 5 * kTileSize));
    });

    test('toScreen at origin', () {
      const pos = (col: 0, row: 0);
      expect(pos.toScreen(), Vector2.zero());
    });

    test('isValid returns true for valid positions', () {
      const pos = (col: 10, row: 20);
      expect(pos.isValid(128, 128), isTrue);
    });

    test('isValid returns false for negative col', () {
      const pos = (col: -1, row: 0);
      expect(pos.isValid(128, 128), isFalse);
    });

    test('isValid returns false for negative row', () {
      const pos = (col: 0, row: -1);
      expect(pos.isValid(128, 128), isFalse);
    });

    test('isValid returns false for col >= width', () {
      const pos = (col: 128, row: 0);
      expect(pos.isValid(128, 128), isFalse);
    });

    test('isValid returns false for row >= height', () {
      const pos = (col: 0, row: 128);
      expect(pos.isValid(128, 128), isFalse);
    });

    test('screenToWorld inverts toScreen', () {
      const pos = (col: 7, row: 4);
      final screen = pos.toScreen();
      final back = screenToWorld(screen);
      expect(back.col, pos.col);
      expect(back.row, pos.row);
    });

    test('screenToWorld handles mid-tile positions', () {
      final midTile = Vector2(kTileSize * 2 + kTileSize / 2, kTileSize * 3 + kTileSize / 2);
      final pos = screenToWorld(midTile);
      expect(pos.col, 2);
      expect(pos.row, 3);
    });
  });
}
