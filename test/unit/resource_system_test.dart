import 'package:city_builder/core/resource_system.dart';
import 'package:city_builder/core/resource_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResourceSystem', () {
    final system = ResourceSystem();

    test('extraction reduces deposit amount per tick', () {
      final deposit = ResourceDeposit(
        position: (col: 5, row: 5),
        type: ResourceType.coal,
        remaining: 100,
      );
      const building = ExtractionBuilding(
        position: (col: 5, row: 5),
        type: ExtractionBuildingType.mine,
      );
      final inventory = ResourceInventory();

      system.tick(
        buildings: const [building],
        deposits: [deposit],
        inventory: inventory,
        marketPrices: const {},
      );

      expect(deposit.remaining, lessThan(100));
    });

    test('exhausted deposit produces nothing', () {
      final deposit = ResourceDeposit(
        position: (col: 1, row: 1),
        type: ResourceType.iron,
        remaining: 0,
      );
      const building = ExtractionBuilding(
        position: (col: 1, row: 1),
        type: ExtractionBuildingType.mine,
      );
      final inventory = ResourceInventory();

      system.tick(
        buildings: const [building],
        deposits: [deposit],
        inventory: inventory,
        marketPrices: const {},
      );

      expect(deposit.remaining, 0);
    });

    test('export revenue calculated correctly', () {
      final deposit = ResourceDeposit(
        position: (col: 0, row: 0),
        type: ResourceType.stone,
        remaining: 1000,
      );
      const building = ExtractionBuilding(
        position: (col: 0, row: 0),
        type: ExtractionBuildingType.quarry,
      );
      final inventory = ResourceInventory();
      const price = 15.0;

      final result = system.tick(
        buildings: const [building],
        deposits: [deposit],
        inventory: inventory,
        marketPrices: {ResourceType.stone: price},
      );

      expect(result.exportRevenue, greaterThan(0));
    });
  });

  group('ResourceInventory', () {
    test('add increases stock', () {
      final inv = ResourceInventory();
      inv.add(ResourceType.wood, 50);
      expect(inv.get(ResourceType.wood), 50);
    });

    test('consume decreases stock when available', () {
      final inv = ResourceInventory({ResourceType.coal: 100});
      final success = inv.consume(ResourceType.coal, 30);
      expect(success, isTrue);
      expect(inv.get(ResourceType.coal), 70);
    });

    test('consume fails when insufficient', () {
      final inv = ResourceInventory({ResourceType.oil: 5});
      final success = inv.consume(ResourceType.oil, 100);
      expect(success, isFalse);
      expect(inv.get(ResourceType.oil), 5);
    });
  });

  group('ResourceDeposit', () {
    test('isExhausted when remaining is 0', () {
      final deposit = ResourceDeposit(
        position: (col: 0, row: 0),
        type: ResourceType.iron,
        remaining: 0,
      );
      expect(deposit.isExhausted, isTrue);
    });

    test('not exhausted when remaining > 0', () {
      final deposit = ResourceDeposit(
        position: (col: 0, row: 0),
        type: ResourceType.iron,
        remaining: 50,
      );
      expect(deposit.isExhausted, isFalse);
    });
  });
}
