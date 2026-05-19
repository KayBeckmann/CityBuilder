import 'package:city_builder/core/tech_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TechTreeState', () {
    test('cannot research node with unresearched dependency', () {
      final state = TechTreeState();
      expect(state.canResearch(TechNode.nuclearPower, 10000), isFalse);
    });

    test('can research tier-1 node with sufficient population', () {
      final state = TechTreeState();
      expect(state.canResearch(TechNode.solarPower, 0), isTrue);
    });

    test('cannot research with insufficient population', () {
      final state = TechTreeState();
      expect(state.canResearch(TechNode.nuclearPower, 100), isFalse);
    });

    test('researching adds to progress', () {
      final state = TechTreeState();
      state.startResearch(TechNode.asphaltRoads, 0);
      expect(state.progress.containsKey(TechNode.asphaltRoads), isTrue);
    });

    test('sufficient research points complete a tech', () {
      final state = TechTreeState();
      state.startResearch(TechNode.solarPower, 0);
      state.tickResearch(TechNode.solarPower.researchCost.toDouble());
      expect(state.isResearched(TechNode.solarPower), isTrue);
    });

    test('unlocked tech allows dependent to be researched', () {
      final state = TechTreeState();
      state.researched.add(TechNode.solarPower);
      state.researched.add(TechNode.school);
      expect(state.canResearch(TechNode.nuclearPower, 10000), isTrue);
    });

    test('research points generated scale with education', () {
      final state = TechTreeState();
      final low = state.researchPointsGenerated(educationIndex: 0.1, universityCount: 0);
      final high = state.researchPointsGenerated(educationIndex: 0.9, universityCount: 3);
      expect(high, greaterThan(low));
    });
  });
}
