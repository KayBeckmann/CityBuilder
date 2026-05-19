import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/game_serializer.dart';
import 'package:city_builder/core/map_generator.dart';
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
  });
}
