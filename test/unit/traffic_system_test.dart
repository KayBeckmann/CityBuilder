import 'package:city_builder/core/traffic_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TrafficSystem', () {
    final system = TrafficSystem();

    test('empty roads produce no loads', () {
      final state = system.calculate(
        roads: const [],
        zoneDensity: const {},
        connectedZones: const {},
      );
      expect(state.loads, isEmpty);
    });

    test('road with nearby density accumulates load', () {
      const road = Road(position: (col: 5, row: 5));
      final density = {(col: 5, row: 5): 200};
      final state = system.calculate(
        roads: const [road],
        zoneDensity: density,
        connectedZones: const {},
      );
      final load = state.loadAt((col: 5, row: 5));
      expect(load, isNotNull);
      expect(load!.load, greaterThan(0));
    });

    test('congestion flagged when load exceeds capacity', () {
      const road = Road(position: (col: 0, row: 0));
      final density = {(col: 0, row: 0): 5000};
      final state = system.calculate(
        roads: const [road],
        zoneDensity: density,
        connectedZones: const {},
      );
      expect(state.isCongested((col: 0, row: 0)), isTrue);
    });

    test('satisfaction malus is 0 without congestion', () {
      const road = Road(position: (col: 5, row: 5));
      final state = system.calculate(
        roads: const [road],
        zoneDensity: const {(col: 5, row: 5): 10},
        connectedZones: const {},
      );
      final malus = state.satisfactionMalus((col: 5, row: 5));
      expect(malus, 0);
    });
  });
}
