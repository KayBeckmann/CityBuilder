import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/economy.dart';
import 'package:city_builder/core/map_generator.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateEconomy', () {
    test('empty map has 0 income and 0 costs', () {
      const generator = MapGenerator();
      final tileMap = generator.generate(seed: 0, size: MapSize.small);

      final result = calculateEconomy(
        tileMap: tileMap,
        taxRates: const TaxRates(),
      );

      expect(result.taxIncome, 0);
      expect(result.operatingCosts, 0);
      expect(result.netBalance, 0);
    });

    test('residential building generates tax income', () {
      const generator = MapGenerator();
      final tileMap = generator.generate(seed: 0, size: MapSize.small);

      const pos = (col: 5, row: 5);
      tileMap.setZone(pos, ZoneType.residential);
      tileMap.setBuildingLevel(pos, BuildingLevel.small);

      final result = calculateEconomy(
        tileMap: tileMap,
        taxRates: const TaxRates(residential: 0.10),
      );

      expect(result.taxIncome, greaterThan(0));
    });

    test('higher tax rate increases income', () {
      const generator = MapGenerator();
      final tileMap = generator.generate(seed: 0, size: MapSize.small);

      const pos = (col: 5, row: 5);
      tileMap.setZone(pos, ZoneType.residential);
      tileMap.setBuildingLevel(pos, BuildingLevel.medium);

      final low = calculateEconomy(tileMap: tileMap, taxRates: const TaxRates(residential: 0.05));
      final high = calculateEconomy(tileMap: tileMap, taxRates: const TaxRates(residential: 0.20));

      expect(high.taxIncome, greaterThan(low.taxIncome));
    });

    test('operating costs increase with building level', () {
      const generator = MapGenerator();
      final tileMap1 = generator.generate(seed: 0, size: MapSize.small);
      final tileMap2 = generator.generate(seed: 0, size: MapSize.small);

      const pos = (col: 5, row: 5);
      tileMap1.setZone(pos, ZoneType.commercial);
      tileMap1.setBuildingLevel(pos, BuildingLevel.small);

      tileMap2.setZone(pos, ZoneType.commercial);
      tileMap2.setBuildingLevel(pos, BuildingLevel.large);

      final small = calculateEconomy(tileMap: tileMap1, taxRates: const TaxRates());
      final large = calculateEconomy(tileMap: tileMap2, taxRates: const TaxRates());

      expect(large.operatingCosts, greaterThan(small.operatingCosts));
    });
  });
}
