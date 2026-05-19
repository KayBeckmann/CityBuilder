import 'package:city_builder/core/space_phase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const system = SpaceSystem();

  group('SpaceSystem.checkSpaceTrigger', () {
    test('triggers when all conditions met', () {
      expect(
        system.checkSpaceTrigger(
          population: kSpacePhaseMinPopulation,
          spaceportBuilt: true,
          spaceportResearched: true,
        ),
        isTrue,
      );
    });

    test('does not trigger with insufficient population', () {
      expect(
        system.checkSpaceTrigger(
          population: 1000,
          spaceportBuilt: true,
          spaceportResearched: true,
        ),
        isFalse,
      );
    });

    test('does not trigger without spaceport', () {
      expect(
        system.checkSpaceTrigger(
          population: kSpacePhaseMinPopulation,
          spaceportBuilt: false,
          spaceportResearched: true,
        ),
        isFalse,
      );
    });
  });

  group('SpaceSystem.tick', () {
    test('completes mission and adds rare earth to stockpile', () {
      final mission = SpaceMission(
        type: SpaceMissionType.rareEarthMining,
        startedAtTick: 0,
        durationTicks: 5,
      );
      final state = SpacePhaseState(
        spacePhaseActive: true,
        activeMissions: [mission],
      );

      final result = system.tick(state: state, currentTick: 10);
      expect(result.rareEarthStockpile, greaterThan(0));
      expect(result.activeMissions, isEmpty);
    });

    test('does nothing when space phase inactive', () {
      final state = SpacePhaseState();
      final result = system.tick(state: state, currentTick: 100);
      expect(result.rareEarthStockpile, 0);
    });
  });

  group('SpaceSystem.hightechDemandBonus', () {
    test('higher rare earth stockpile gives higher bonus', () {
      final low = system.hightechDemandBonus(rareEarth: 100);
      final high = system.hightechDemandBonus(rareEarth: 1000);
      expect(high, greaterThan(low));
    });

    test('bonus is clamped at 2.0', () {
      final bonus = system.hightechDemandBonus(rareEarth: 999999);
      expect(bonus, closeTo(2.0, 0.01));
    });
  });
}
