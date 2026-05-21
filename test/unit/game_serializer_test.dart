import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/game_serializer.dart';
import 'package:city_builder/core/map_generator.dart';
import 'package:city_builder/core/space_phase.dart';
import 'package:city_builder/core/tech_tree.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const serializer = GameSerializer();

  group('GameSerializer', () {
    test('serialize then deserialize produces identical state', () {
      const generator = MapGenerator();
      final tileMap = generator.generate(seed: 777, size: MapSize.small);
      const pos1 = (col: 10, row: 10);
      tileMap.setZone(pos1, ZoneType.residential);
      tileMap.setBuildingLevel(pos1, BuildingLevel.medium);

      final model = newGame(seed: 777, size: MapSize.small, budget: 75000);
      model.tileMap.setZone(pos1, ZoneType.residential);
      model.tileMap.setBuildingLevel(pos1, BuildingLevel.medium);

      final json = serializer.serialize(model);
      final restored = serializer.deserialize(json);

      expect(restored.budget, closeTo(model.budget, 0.01));
      expect(restored.tick, model.tick);
      expect(restored.tileMap.width, model.tileMap.width);
      expect(restored.tileMap.height, model.tileMap.height);
      expect(
        restored.tileMap.getZone(pos1),
        ZoneType.residential,
      );
      expect(
        restored.tileMap.getBuildingLevel(pos1),
        BuildingLevel.medium,
      );
    });

    test('all terrain types survive round-trip', () {
      final model = newGame(seed: 42, size: MapSize.small);
      final json = serializer.serialize(model);
      final restored = serializer.deserialize(json);

      for (var row = 0; row < model.tileMap.height; row++) {
        for (var col = 0; col < model.tileMap.width; col++) {
          final pos = (col: col, row: row);
          expect(
            restored.tileMap.get(pos),
            model.tileMap.get(pos),
          );
        }
      }
    });

    test('tax rates survive round-trip', () {
      final model = newGame(seed: 0, size: MapSize.small);
      final withTax = model.copyWith(
        taxRates: model.taxRates.copyWith(residential: 0.15),
      );
      final json = serializer.serialize(withTax);
      final restored = serializer.deserialize(json);
      expect(restored.taxRates.residential, closeTo(0.15, 0.001));
    });

    test('tech tree researched nodes survive round-trip', () {
      final model = newGame(seed: 0, size: MapSize.small);
      model.techTree.researched
        ..add(TechNode.solarPower)
        ..add(TechNode.asphaltRoads);
      model.techTree.researchPoints = 42.5;

      final json = serializer.serialize(model);
      final restored = serializer.deserialize(json);

      expect(
          restored.techTree.isResearched(TechNode.solarPower), isTrue);
      expect(
          restored.techTree.isResearched(TechNode.asphaltRoads), isTrue);
      expect(
          restored.techTree.isResearched(TechNode.nuclearPower), isFalse);
      expect(restored.techTree.researchPoints, closeTo(42.5, 0.01));
    });

    test('tech tree in-progress research survives round-trip', () {
      final model = newGame(seed: 0, size: MapSize.small);
      model.techTree.progress[TechNode.school] = 150.0;

      final json = serializer.serialize(model);
      final restored = serializer.deserialize(json);

      expect(restored.techTree.progress[TechNode.school], closeTo(150.0, 0.01));
    });

    test('space phase active state survives round-trip', () {
      final model = newGame(seed: 0, size: MapSize.small);
      model.spacePhase.spacePhaseActive = true;
      model.spacePhase.rareEarthStockpile = 250.0;
      model.spacePhase.colonyPopulation = 100;

      final json = serializer.serialize(model);
      final restored = serializer.deserialize(json);

      expect(restored.spacePhase.spacePhaseActive, isTrue);
      expect(
          restored.spacePhase.rareEarthStockpile, closeTo(250.0, 0.01));
      expect(restored.spacePhase.colonyPopulation, 100);
    });

    test('active space missions survive round-trip', () {
      final model = newGame(seed: 0, size: MapSize.small);
      model.spacePhase.spacePhaseActive = true;
      model.spacePhase.activeMissions.add(SpaceMission(
        type: SpaceMissionType.satelliteNetwork,
        startedAtTick: 10,
        durationTicks: 60,
      ));

      final json = serializer.serialize(model);
      final restored = serializer.deserialize(json);

      expect(restored.spacePhase.activeMissions.length, 1);
      expect(restored.spacePhase.activeMissions.first.type,
          SpaceMissionType.satelliteNetwork);
      expect(restored.spacePhase.activeMissions.first.startedAtTick, 10);
    });

    test('spaceport tile flag survives round-trip', () {
      final model = newGame(seed: 0, size: MapSize.small);
      const pos = (col: 5, row: 5);
      model.tileMap.setSpaceport(pos);

      final json = serializer.serialize(model);
      final restored = serializer.deserialize(json);

      expect(restored.tileMap.getData(pos).hasSpaceport, isTrue);
    });
  });
}
