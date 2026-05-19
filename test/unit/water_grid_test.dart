import 'package:city_builder/core/water_grid.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WaterGridSystem', () {
    final system = WaterGridSystem();

    test('no sources means no supply', () {
      final state = system.calculate(
        sources: const [],
        pipes: const [],
        sewerPlants: const [],
        demandMap: const {},
      );
      expect(state.suppliedTiles, isEmpty);
      expect(state.totalCapacity, 0);
    });

    test('source position is always supplied', () {
      const source = WaterSource(position: (col: 3, row: 3), capacity: 1000);
      final state = system.calculate(
        sources: const [source],
        pipes: const [],
        sewerPlants: const [],
        demandMap: const {},
      );
      expect(state.isSupplied((col: 3, row: 3)), isTrue);
    });

    test('pipe-connected tiles are supplied', () {
      const source = WaterSource(position: (col: 0, row: 0), capacity: 500);
      const pipe = WaterPipe(from: (col: 0, row: 0), to: (col: 1, row: 0));
      final state = system.calculate(
        sources: const [source],
        pipes: const [pipe],
        sewerPlants: const [],
        demandMap: const {},
      );
      expect(state.isSupplied((col: 0, row: 0)), isTrue);
      expect(state.isSupplied((col: 1, row: 0)), isTrue);
    });

    test('disconnected tile is not supplied', () {
      const source = WaterSource(position: (col: 0, row: 0), capacity: 500);
      final state = system.calculate(
        sources: const [source],
        pipes: const [],
        sewerPlants: const [],
        demandMap: const {},
      );
      expect(state.isSupplied((col: 5, row: 5)), isFalse);
    });

    test('shortage when demand exceeds capacity', () {
      const source = WaterSource(position: (col: 0, row: 0), capacity: 100);
      final state = system.calculate(
        sources: const [source],
        pipes: const [],
        sewerPlants: const [],
        demandMap: const {(col: 0, row: 0): 5000},
      );
      expect(state.hasShortage, isTrue);
    });

    test('sewage plant covers tiles in radius', () {
      const plant = SewerPlant(position: (col: 5, row: 5), coverage: 2);
      final state = system.calculate(
        sources: const [],
        pipes: const [],
        sewerPlants: const [plant],
        demandMap: const {},
      );
      expect(state.isSewaged((col: 5, row: 5)), isTrue);
      expect(state.isSewaged((col: 7, row: 7)), isTrue);
      expect(state.isSewaged((col: 8, row: 8)), isFalse);
    });
  });
}
