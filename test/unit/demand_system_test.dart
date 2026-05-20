import 'package:city_builder/core/demand_system.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const system = DemandSystem();

  group('DemandSystem', () {
    test('residential demand is seeded when population is 0', () {
      final demand = system.calculate(
        population: 0,
        commercialBuildings: 0,
        industrialBuildings: 0,
      );
      // Initial seed so first residential buildings can develop
      expect(demand.residential, greaterThan(0.5));
      expect(demand.commercial, 0);
      expect(demand.industrial, 0);
    });

    test('residential demand grows with population', () {
      final small = system.calculate(population: 100, commercialBuildings: 0, industrialBuildings: 0);
      final large = system.calculate(population: 5000, commercialBuildings: 0, industrialBuildings: 0);
      expect(large.residential, greaterThan(small.residential));
    });

    test('commercial demand is positive with residents', () {
      final demand = system.calculate(
        population: 500,
        commercialBuildings: 0,
        industrialBuildings: 0,
      );
      expect(demand.commercial, greaterThan(0));
    });

    test('industrial demand is positive with residents', () {
      final demand = system.calculate(
        population: 500,
        commercialBuildings: 0,
        industrialBuildings: 0,
      );
      expect(demand.industrial, greaterThan(0));
    });

    test('forZone returns correct value per zone type', () {
      final demand = system.calculate(
        population: 200,
        commercialBuildings: 0,
        industrialBuildings: 0,
      );
      expect(demand.forZone(ZoneType.residential), demand.residential);
      expect(demand.forZone(ZoneType.commercial), demand.commercial);
      expect(demand.forZone(ZoneType.industrial), demand.industrial);
    });
  });
}
