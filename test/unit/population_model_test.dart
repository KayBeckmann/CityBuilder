import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/map_generator.dart';
import 'package:city_builder/core/population_model.dart';
import 'package:city_builder/core/satisfaction_system.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = MapGenerator();

  group('calculatePopulation', () {
    test('population grows when satisfaction is high and capacity exists', () {
      final tileMap = generator.generate(seed: 0, size: MapSize.small);
      const pos1 = (col: 10, row: 10);
      const pos2 = (col: 11, row: 10);
      tileMap.setZone(pos1, ZoneType.residential);
      tileMap.setBuildingLevel(pos1, BuildingLevel.large);
      tileMap.setZone(pos2, ZoneType.residential);
      tileMap.setBuildingLevel(pos2, BuildingLevel.large);

      const initial = PopulationStats(total: 0, capacity: 400, history: []);
      final result = calculatePopulation(
        tileMap: tileMap,
        previous: initial,
        satisfactionScore: 1.0,
      );
      expect(result.total, greaterThan(0));
    });

    test('population shrinks when satisfaction is 0', () {
      final tileMap = generator.generate(seed: 0, size: MapSize.small);
      const pos = (col: 10, row: 10);
      tileMap.setZone(pos, ZoneType.residential);
      tileMap.setBuildingLevel(pos, BuildingLevel.large);

      const initial = PopulationStats(total: 100, capacity: 200, history: []);
      final result = calculatePopulation(
        tileMap: tileMap,
        previous: initial,
        satisfactionScore: 0.0,
      );
      expect(result.total, lessThan(100));
    });

    test('population cannot exceed capacity', () {
      final tileMap = generator.generate(seed: 0, size: MapSize.small);
      const pos = (col: 5, row: 5);
      tileMap.setZone(pos, ZoneType.residential);
      tileMap.setBuildingLevel(pos, BuildingLevel.small);

      const initial = PopulationStats(total: 10, capacity: 10, history: []);
      final result = calculatePopulation(
        tileMap: tileMap,
        previous: initial,
        satisfactionScore: 1.0,
      );
      expect(result.total, lessThanOrEqualTo(result.capacity));
    });

    test('history keeps last 10 entries', () {
      final tileMap = generator.generate(seed: 0, size: MapSize.small);
      var stats = const PopulationStats(total: 0, capacity: 100, history: []);
      for (var i = 0; i < 15; i++) {
        stats = calculatePopulation(
          tileMap: tileMap,
          previous: stats,
          satisfactionScore: 0.8,
        );
      }
      expect(stats.history.length, lessThanOrEqualTo(10));
    });
  });

  group('calculateSatisfaction', () {
    test('perfect satisfaction returns 1.0', () {
      const factors = SatisfactionFactors(employment: 1, housing: 1, services: 1);
      expect(calculateSatisfaction(factors), closeTo(1.0, 0.01));
    });

    test('zero satisfaction returns 0.0', () {
      const factors = SatisfactionFactors(employment: 0, housing: 0, services: 0);
      expect(calculateSatisfaction(factors), closeTo(0.0, 0.01));
    });
  });

  group('calculateApprovalRating', () {
    test('high satisfaction across all zones gives high approval', () {
      final approval = calculateApprovalRating(
        residentSatisfaction: 1.0,
        commercialSatisfaction: 1.0,
        industrialSatisfaction: 1.0,
      );
      expect(approval, closeTo(1.0, 0.01));
    });

    test('low resident satisfaction reduces approval most', () {
      final lowResident = calculateApprovalRating(
        residentSatisfaction: 0.0,
        commercialSatisfaction: 1.0,
        industrialSatisfaction: 1.0,
      );
      final lowIndustrial = calculateApprovalRating(
        residentSatisfaction: 1.0,
        commercialSatisfaction: 1.0,
        industrialSatisfaction: 0.0,
      );
      expect(lowResident, lessThan(lowIndustrial));
    });
  });
}
