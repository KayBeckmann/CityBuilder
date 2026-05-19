import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/map_generator.dart';
import 'package:city_builder/core/overlay_type.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:city_builder/features/overlay_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = MapGenerator();

  group('computeOverlayValues', () {
    test('returns empty map for OverlayType.none', () {
      final tileMap = generator.generate(seed: 0, size: MapSize.small);
      final result = computeOverlayValues(tileMap, OverlayType.none);
      expect(result, isEmpty);
    });

    test('population density > 0 for residential buildings', () {
      final tileMap = generator.generate(seed: 0, size: MapSize.small);
      const pos = (col: 5, row: 5);
      tileMap.setZone(pos, ZoneType.residential);
      tileMap.setBuildingLevel(pos, BuildingLevel.large);

      final result = computeOverlayValues(tileMap, OverlayType.populationDensity);
      expect(result[pos], greaterThan(0));
    });

    test('pollution > 0 for industrial buildings', () {
      final tileMap = generator.generate(seed: 0, size: MapSize.small);
      const pos = (col: 10, row: 10);
      tileMap.setZone(pos, ZoneType.industrial);
      tileMap.setBuildingLevel(pos, BuildingLevel.large);

      final result = computeOverlayValues(tileMap, OverlayType.pollution);
      expect(result[pos], greaterThan(0));
    });

    test('all overlay types produce a Map without error', () {
      final tileMap = generator.generate(seed: 42, size: MapSize.small);
      for (final type in OverlayType.values) {
        expect(() => computeOverlayValues(tileMap, type), returnsNormally);
      }
    });

    test('values are clamped between 0 and 1', () {
      final tileMap = generator.generate(seed: 0, size: MapSize.small);
      const pos = (col: 8, row: 8);
      tileMap.setZone(pos, ZoneType.residential);
      tileMap.setBuildingLevel(pos, BuildingLevel.large);

      for (final type in OverlayType.values) {
        final result = computeOverlayValues(tileMap, type);
        for (final v in result.values) {
          expect(v, inInclusiveRange(0.0, 1.0));
        }
      }
    });
  });
}
