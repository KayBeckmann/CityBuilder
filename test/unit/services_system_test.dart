import 'package:city_builder/core/services_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculateServices', () {
    test('police coverage reduces crime in radius', () {
      const police = ServiceBuilding(
        position: (col: 10, row: 10),
        type: ServiceType.police,
      );
      final state = calculateServices(buildings: const [police]);

      expect(state.hasPolice((col: 10, row: 10)), isTrue);
      expect(state.hasPolice((col: 18, row: 10)), isTrue);
      expect(state.hasPolice((col: 25, row: 10)), isFalse);
    });

    test('university increases education index', () {
      const uni = ServiceBuilding(
        position: (col: 5, row: 5),
        type: ServiceType.university,
      );
      final state = calculateServices(buildings: const [uni]);
      expect(state.educationIndex, greaterThan(0));
    });

    test('multiple schools stack education index', () {
      const school1 = ServiceBuilding(
        position: (col: 5, row: 5),
        type: ServiceType.school,
      );
      const school2 = ServiceBuilding(
        position: (col: 20, row: 20),
        type: ServiceType.school,
      );
      final one = calculateServices(buildings: const [school1]);
      final two = calculateServices(buildings: const [school1, school2]);
      expect(two.educationIndex, greaterThan(one.educationIndex));
    });

    test('education index is clamped to 1.0', () {
      final manySchools = List.generate(
        20,
        (i) => ServiceBuilding(
          position: (col: i * 2, row: 0),
          type: ServiceType.university,
        ),
      );
      final state = calculateServices(buildings: manySchools);
      expect(state.educationIndex, lessThanOrEqualTo(1.0));
    });
  });

  group('PollutionSystem', () {
    test('pollution radius covers tiles around source', () {
      final system = PollutionSystem(20, 20);
      final result = system.calculate(sources: [
        (position: (col: 10, row: 10), intensity: 1.0, radius: 3),
      ]);
      expect(result[(col: 10, row: 10)], greaterThan(0));
      expect(result[(col: 12, row: 10)], greaterThan(0));
      expect(result[(col: 15, row: 10)], isNull);
    });

    test('pollution reduces land value (represented as non-zero value)', () {
      final system = PollutionSystem(10, 10);
      final result = system.calculate(sources: [
        (position: (col: 5, row: 5), intensity: 1.0, radius: 4),
      ]);
      expect(result.isNotEmpty, isTrue);
      expect(result[(col: 5, row: 5)], greaterThan(0));
    });
  });

  group('CrimeSystem', () {
    test('police coverage reduces crime rate', () {
      const pos = (col: 5, row: 5);
      final baseCrime = {pos: 0.8};
      final police = {pos};

      final system = CrimeSystem();
      final result = system.calculate(
        baseCrimeByZone: baseCrime,
        policeCoverage: police,
      );

      expect(result[pos]!, lessThan(0.8));
    });

    test('without police, crime unchanged', () {
      const pos = (col: 3, row: 3);
      final baseCrime = {pos: 0.5};

      final system = CrimeSystem();
      final result = system.calculate(
        baseCrimeByZone: baseCrime,
        policeCoverage: const {},
      );

      expect(result[pos], closeTo(0.5, 0.01));
    });
  });
}
