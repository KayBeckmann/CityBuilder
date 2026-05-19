import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/demand_system.dart';
import 'package:city_builder/core/economy.dart';
import 'package:city_builder/core/game_model.dart';
import 'package:city_builder/core/map_generator.dart';
import 'package:city_builder/core/population_model.dart';
import 'package:city_builder/core/satisfaction_system.dart';
import 'package:city_builder/core/terrain_type.dart';
import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/world_position.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const Map<TerrainType, double> terrainEditCost = {
  TerrainType.grass: 500.0,
  TerrainType.water: 2000.0,
  TerrainType.hill: 1500.0,
  TerrainType.forest: 300.0,
};

const double kZoneCostPerTile = 100.0;

const _demandSystem = DemandSystem();

class GameNotifier extends Notifier<GameModel> {
  @override
  GameModel build() {
    const generator = MapGenerator();
    final tileMap = generator.generate(seed: 42, size: MapSize.medium);
    return GameModel(
      tileMap: tileMap,
      budget: GameModel.startingBudget,
      tick: 0,
    );
  }

  void newGame({required int seed, required MapSize size}) {
    const generator = MapGenerator();
    final tileMap = generator.generate(seed: seed, size: size);
    state = GameModel(
      tileMap: tileMap,
      budget: GameModel.startingBudget,
      tick: 0,
    );
  }

  void spendBudget(double amount) {
    state = state.copyWith(budget: state.budget - amount);
  }

  bool editTerrain(WorldPosition pos, TerrainType targetTerrain) {
    final cost = terrainEditCost[targetTerrain] ?? 0;
    if (state.budget < cost) return false;

    final tileMap = state.tileMap;
    if (!tileMap.contains(pos)) return false;

    tileMap.set(pos, targetTerrain);
    state = state.copyWith(budget: state.budget - cost);
    return true;
  }

  bool canAffordEdit(TerrainType targetTerrain) {
    final cost = terrainEditCost[targetTerrain] ?? 0;
    return state.budget >= cost;
  }

  bool setZone(WorldPosition pos, ZoneType? zone) {
    if (state.budget < kZoneCostPerTile) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos)) return false;
    if (tileMap.get(pos) == TerrainType.water) return false;

    tileMap.setZone(pos, zone);
    if (zone != null) {
      state = state.copyWith(budget: state.budget - kZoneCostPerTile);
    }
    return true;
  }

  void tick() {
    final tileMap = state.tileMap;

    final currentPop = state.population.total;
    final commercial = _countBuildingsByZone(tileMap, ZoneType.commercial);
    final industrial = _countBuildingsByZone(tileMap, ZoneType.industrial);

    final demand = _demandSystem.calculate(
      population: currentPop,
      commercialBuildings: commercial,
      industrialBuildings: industrial,
    );

    _developZones(tileMap, demand);

    final economy = calculateEconomy(
      tileMap: tileMap,
      taxRates: state.taxRates,
    );

    final satisfactionScore = calculateSatisfaction(state.satisfaction);

    final newPopulation = calculatePopulation(
      tileMap: tileMap,
      previous: state.population,
      satisfactionScore: satisfactionScore,
    );

    final approval = calculateApprovalRating(
      residentSatisfaction: satisfactionScore,
      commercialSatisfaction: satisfactionScore * 0.9,
      industrialSatisfaction: satisfactionScore * 0.8,
    );

    state = state.copyWith(
      tick: state.tick + 1,
      budget: state.budget + economy.netBalance,
      lastEconomy: economy,
      population: newPopulation,
      approvalRating: approval,
    );
  }

  void updateTaxRates(TaxRates rates) {
    state = state.copyWith(taxRates: rates);
  }

  int _countBuildingsByZone(TileMap tileMap, ZoneType zone) {
    var count = 0;
    for (var row = 0; row < tileMap.height; row++) {
      for (var col = 0; col < tileMap.width; col++) {
        final data = tileMap.getData((col: col, row: row));
        if (data.zone == zone && data.buildingLevel.hasBuilding) count++;
      }
    }
    return count;
  }

  void _developZones(TileMap tileMap, DemandCurve demand) {
    for (var row = 0; row < tileMap.height; row++) {
      for (var col = 0; col < tileMap.width; col++) {
        final pos = (col: col, row: row);
        final data = tileMap.getData(pos);
        final zone = data.zone;
        if (zone == null) continue;

        final d = demand.forZone(zone);
        if (d > 0.5 && data.buildingLevel != BuildingLevel.large) {
          tileMap.setBuildingLevel(pos, data.buildingLevel.next);
        } else if (d <= 0.0 && data.buildingLevel.hasBuilding) {
          tileMap.setBuildingLevel(pos, BuildingLevel.empty);
        }
      }
    }
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameModel>(GameNotifier.new);
