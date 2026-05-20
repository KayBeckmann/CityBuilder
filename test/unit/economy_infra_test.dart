import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/economy.dart';
import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateEconomy with infrastructure', () {
    late TileMap map;
    const rates = TaxRates();

    setUp(() {
      map = TileMap(width: 10, height: 10);
    });

    test('no buildings no infra → zero income and cost', () {
      final result = calculateEconomy(tileMap: map, taxRates: rates);
      expect(result.taxIncome, 0);
      expect(result.operatingCosts, 0);
    });

    test('road tile adds maintenance cost', () {
      map.setRoad((col: 0, row: 0));
      final result = calculateEconomy(tileMap: map, taxRates: rates);
      expect(result.operatingCosts, closeTo(0.5, 0.01));
    });

    test('power plant adds maintenance cost', () {
      map.setPowerPlant((col: 0, row: 0));
      final result = calculateEconomy(tileMap: map, taxRates: rates);
      expect(result.operatingCosts, closeTo(5.0, 0.01));
    });

    test('water tower adds maintenance cost', () {
      map.setWaterTower((col: 0, row: 0));
      final result = calculateEconomy(tileMap: map, taxRates: rates);
      expect(result.operatingCosts, closeTo(4.0, 0.01));
    });

    test('park adds maintenance cost', () {
      map.setPark((col: 0, row: 0));
      final result = calculateEconomy(tileMap: map, taxRates: rates);
      expect(result.operatingCosts, closeTo(1.0, 0.01));
    });

    test('building generates tax income and operating cost', () {
      const pos = (col: 5, row: 5);
      map.setZone(pos, ZoneType.residential);
      map.setBuildingLevel(pos, BuildingLevel.small);
      final result = calculateEconomy(tileMap: map, taxRates: rates);
      // income = 10 * 5.0 * 0.08 = 4.0
      expect(result.taxIncome, closeTo(4.0, 0.01));
      // operating = 10.0 (small building)
      expect(result.operatingCosts, closeTo(10.0, 0.01));
    });

    test('net balance is positive for large commercial', () {
      const pos = (col: 5, row: 5);
      map.setZone(pos, ZoneType.commercial);
      map.setBuildingLevel(pos, BuildingLevel.large);
      final result = calculateEconomy(tileMap: map, taxRates: rates);
      // income = 200 * 5.0 * 0.10 = 100.0
      // operating = 60.0
      expect(result.netBalance, greaterThan(0));
    });

    test('multiple infrastructure items accumulate costs', () {
      map.setRoad((col: 0, row: 0));
      map.setPowerLine((col: 1, row: 0));
      map.setPipe((col: 2, row: 0));
      final result = calculateEconomy(tileMap: map, taxRates: rates);
      // 0.5 + 0.25 + 0.25 = 1.0
      expect(result.operatingCosts, closeTo(1.0, 0.01));
    });
  });
}
