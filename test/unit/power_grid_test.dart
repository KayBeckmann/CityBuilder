import 'package:city_builder/core/power_grid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final system = PowerGridSystem();

  group('PowerGridSystem', () {
    test('no plants means no powered tiles', () {
      final state = system.calculate(
        plants: const [],
        lines: const [],
        gridWidth: 10,
        gridHeight: 10,
        demandMap: const {},
      );
      expect(state.poweredTiles, isEmpty);
      expect(state.totalCapacity, 0);
    });

    test('plant position is always powered', () {
      const plant = PowerPlant(
        position: (col: 5, row: 5),
        type: PowerPlantType.coal,
      );
      final state = system.calculate(
        plants: const [plant],
        lines: const [],
        gridWidth: 20,
        gridHeight: 20,
        demandMap: const {},
      );
      expect(state.isPowered((col: 5, row: 5)), isTrue);
    });

    test('connected tiles are powered', () {
      const plant = PowerPlant(
        position: (col: 0, row: 0),
        type: PowerPlantType.solar,
      );
      const line1 = PowerLine(from: (col: 0, row: 0), to: (col: 1, row: 0));
      const line2 = PowerLine(from: (col: 1, row: 0), to: (col: 2, row: 0));

      final state = system.calculate(
        plants: const [plant],
        lines: const [line1, line2],
        gridWidth: 10,
        gridHeight: 10,
        demandMap: const {},
      );

      expect(state.isPowered((col: 0, row: 0)), isTrue);
      expect(state.isPowered((col: 1, row: 0)), isTrue);
      expect(state.isPowered((col: 2, row: 0)), isTrue);
    });

    test('disconnected tile is not powered', () {
      const plant = PowerPlant(
        position: (col: 0, row: 0),
        type: PowerPlantType.solar,
      );
      const line = PowerLine(from: (col: 0, row: 0), to: (col: 1, row: 0));

      final state = system.calculate(
        plants: const [plant],
        lines: const [line],
        gridWidth: 10,
        gridHeight: 10,
        demandMap: const {},
      );

      expect(state.isPowered((col: 5, row: 5)), isFalse);
    });

    test('blackout when demand exceeds capacity', () {
      const plant = PowerPlant(
        position: (col: 0, row: 0),
        type: PowerPlantType.solar,
      );

      final state = system.calculate(
        plants: const [plant],
        lines: const [],
        gridWidth: 10,
        gridHeight: 10,
        demandMap: const {(col: 0, row: 0): 99999},
      );

      expect(state.isBlackout, isTrue);
    });

    test('no blackout when capacity covers demand', () {
      const plant = PowerPlant(
        position: (col: 0, row: 0),
        type: PowerPlantType.coal,
      );

      final state = system.calculate(
        plants: const [plant],
        lines: const [],
        gridWidth: 10,
        gridHeight: 10,
        demandMap: const {(col: 0, row: 0): 100},
      );

      expect(state.isBlackout, isFalse);
    });
  });
}
