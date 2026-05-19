import 'package:city_builder/core/game_model.dart';
import 'package:city_builder/core/map_generator.dart';
import 'package:city_builder/core/terrain_type.dart';
import 'package:city_builder/features/game_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ProviderContainer makeContainer({double budget = 50000}) {
  final container = ProviderContainer(
    overrides: [
      gameProvider.overrideWith(() => _TestGameNotifier(budget: budget)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('terrainEditCost', () {
    test('water costs more than grass', () {
      expect(
        terrainEditCost[TerrainType.water]!,
        greaterThan(terrainEditCost[TerrainType.grass]!),
      );
    });
  });

  group('GameNotifier.editTerrain', () {
    test('deducts correct cost from budget', () {
      final container = makeContainer(budget: 10000);
      final notifier = container.read(gameProvider.notifier);

      const pos = (col: 5, row: 5);
      final success = notifier.editTerrain(pos, TerrainType.water);

      expect(success, isTrue);
      final remaining = container.read(gameProvider).budget;
      expect(remaining, closeTo(10000 - terrainEditCost[TerrainType.water]!, 0.01));
    });

    test('returns false when budget is insufficient', () {
      final container = makeContainer(budget: 100);
      final notifier = container.read(gameProvider.notifier);

      const pos = (col: 5, row: 5);
      final success = notifier.editTerrain(pos, TerrainType.water);

      expect(success, isFalse);
      expect(container.read(gameProvider).budget, 100);
    });

    test('terrain type changes on success', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);

      const pos = (col: 10, row: 10);
      notifier.editTerrain(pos, TerrainType.hill);

      expect(container.read(gameProvider).tileMap.get(pos), TerrainType.hill);
    });
  });

  group('GameNotifier.canAffordEdit', () {
    test('returns false when budget below cost', () {
      final container = makeContainer(budget: 100);
      final notifier = container.read(gameProvider.notifier);
      expect(notifier.canAffordEdit(TerrainType.water), isFalse);
    });

    test('returns true when budget is sufficient', () {
      final container = makeContainer();
      final notifier = container.read(gameProvider.notifier);
      expect(notifier.canAffordEdit(TerrainType.water), isTrue);
    });
  });
}

class _TestGameNotifier extends GameNotifier {
  _TestGameNotifier({required this.budget});

  final double budget;

  @override
  GameModel build() {
    const generator = MapGenerator();
    final tileMap = generator.generate(seed: 0, size: MapSize.small);
    return GameModel(tileMap: tileMap, budget: budget, tick: 0);
  }
}
