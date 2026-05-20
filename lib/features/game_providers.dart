import 'dart:math';

import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/demand_system.dart';
import 'package:city_builder/core/economy.dart';
import 'package:city_builder/core/game_model.dart';
import 'package:city_builder/core/game_serializer.dart';
import 'package:city_builder/core/map_generator.dart';
import 'package:city_builder/core/population_model.dart';
import 'package:city_builder/core/satisfaction_system.dart';
import 'package:city_builder/core/terrain_type.dart';
import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/world_position.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:city_builder/features/notification_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double kRoadCost = 300.0;
const double kPowerLineCost = 200.0;
const double kPipeCost = 250.0;

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

  void newGame({
    required int seed,
    required MapSize size,
    double? startingBudget,
  }) {
    const generator = MapGenerator();
    final tileMap = generator.generate(seed: seed, size: size);
    state = GameModel(
      tileMap: tileMap,
      budget: startingBudget ?? GameModel.startingBudget,
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

    final newSatisfaction = _computeSatisfaction(tileMap, currentPop, commercial, industrial);
    final satisfactionScore = calculateSatisfaction(newSatisfaction);

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

    final prevPop = state.population.total;
    final prevBudget = state.budget;
    final prevApproval = state.approvalRating;
    final loanInterest = state.loan * GameModel.loanInterestRate;

    state = state.copyWith(
      tick: state.tick + 1,
      budget: state.budget + economy.netBalance - loanInterest,
      lastEconomy: economy,
      population: newPopulation,
      satisfaction: newSatisfaction,
      approvalRating: approval,
    );

    _checkMilestones(prevPop, newPopulation.total, prevBudget, prevApproval, approval);
  }

  static final _rng = Random();
  static const _popMilestones = [50, 100, 250, 500, 1000, 2500, 5000, 10000];

  void _checkMilestones(
    int prevPop,
    int newPop,
    double prevBudget,
    double prevApproval,
    double newApproval,
  ) {
    final q = ref.read(notificationQueueProvider.notifier);

    for (final milestone in _popMilestones) {
      if (prevPop < milestone && newPop >= milestone) {
        q.push(CityNotification(message: '$milestone Einwohner erreicht!'));
        return;
      }
    }

    if (prevBudget >= 10000 && state.budget < 10000 && state.budget > 0) {
      q.push(CityNotification(
        message: 'Budget unter \$10.000 – Finanzen prüfen!',
        isWarning: true,
      ));
    }

    if (prevBudget > 0 && state.budget <= 0) {
      q.push(CityNotification(
        message: 'Budget im Minus! Insolvenz droht.',
        isWarning: true,
      ));
    }

    if (prevApproval >= 0.3 && newApproval < 0.3) {
      q.push(CityNotification(
        message: 'Niedrige Zustimmung! Bürger sind unzufrieden.',
        isWarning: true,
      ));
    }

    // Random events every ~15 ticks
    if (state.tick > 5 && state.tick % 15 == 0) {
      _triggerRandomEvent(q);
    }
  }

  static const _events = [
    (msg: 'Wirtschaftsboom! Steuereinnahmen +\$500', budget: 500.0, warn: false),
    (msg: 'Stadtfest! Bevölkerung sehr zufrieden', budget: 200.0, warn: false),
    (msg: 'Rohrleitungsriss – Reparatur kostet \$300', budget: -300.0, warn: true),
    (msg: 'Stromnetz-Störung – Reparatur \$400', budget: -400.0, warn: true),
    (msg: 'Fördermittel vom Bund: +\$1000', budget: 1000.0, warn: false),
    (msg: 'Schwerer Sturm — Schäden: -\$500', budget: -500.0, warn: true),
  ];

  void _triggerRandomEvent(NotificationQueue q) {
    if (state.population.total < 10) return;
    final event = _events[_rng.nextInt(_events.length)];
    state = state.copyWith(budget: state.budget + event.budget);
    q.push(CityNotification(message: event.msg, isWarning: event.warn));
  }

  SatisfactionFactors _computeSatisfaction(
    TileMap tileMap,
    int population,
    int commercial,
    int industrial,
  ) {
    final poweredTiles = tileMap.computePoweredTiles();
    final wateredTiles = tileMap.computeWateredTiles();
    var buildings = 0, withRoad = 0, withPower = 0, withWater = 0;
    for (var row = 0; row < tileMap.height; row++) {
      for (var col = 0; col < tileMap.width; col++) {
        final pos = (col: col, row: row);
        final data = tileMap.getData(pos);
        if (data.zone != null && data.buildingLevel.hasBuilding) {
          buildings++;
          if (data.hasRoad) withRoad++;
          if (poweredTiles.contains(pos)) withPower++;
          if (wateredTiles.contains(pos)) withWater++;
        }
      }
    }

    if (buildings == 0) {
      return const SatisfactionFactors(employment: 0.5, housing: 0.5, services: 0.5);
    }

    final roadCov = withRoad / buildings;
    final powerCov = withPower / buildings;
    final pipeCov = withWater / buildings;

    final employmentRatio = population > 0
        ? ((commercial + industrial) * 10.0 / population).clamp(0.0, 1.0)
        : 0.5;

    return SatisfactionFactors(
      employment: (employmentRatio * (0.5 + 0.5 * powerCov)).clamp(0.0, 1.0),
      housing: (0.3 + 0.7 * roadCov).clamp(0.0, 1.0),
      // Base service score 0.3 so the city isn't dead without early infrastructure
      services: (0.3 + 0.35 * powerCov + 0.35 * pipeCov).clamp(0.0, 1.0),
    );
  }

  void updateTaxRates(TaxRates rates) {
    state = state.copyWith(taxRates: rates);
  }

  bool takeLoan() {
    if (state.loan >= GameModel.maxLoan) return false;
    state = state.copyWith(
      budget: state.budget + GameModel.loanChunkSize,
      loan: state.loan + GameModel.loanChunkSize,
    );
    return true;
  }

  void repayLoan() {
    final repayAmount = GameModel.loanChunkSize.clamp(0, state.loan);
    if (repayAmount <= 0 || state.budget < repayAmount) return;
    state = state.copyWith(
      budget: state.budget - repayAmount,
      loan: state.loan - repayAmount,
    );
  }

  bool demolishAll(WorldPosition pos) {
    const cost = 50.0;
    if (state.budget < cost) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos)) return false;
    tileMap.clearAll(pos);
    state = state.copyWith(budget: state.budget - cost);
    return true;
  }

  bool placeWaterTower(WorldPosition pos) {
    const cost = 3000.0;
    if (state.budget < cost) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos) || tileMap.getData(pos).hasWaterTower) return false;
    tileMap.setWaterTower(pos);
    state = state.copyWith(budget: state.budget - cost);
    return true;
  }

  bool placePowerPlant(WorldPosition pos) {
    const cost = 5000.0;
    if (state.budget < cost) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos) || tileMap.getData(pos).hasPowerPlant) return false;
    tileMap.setPowerPlant(pos);
    state = state.copyWith(budget: state.budget - cost);
    return true;
  }

  bool placeRoad(WorldPosition pos) {
    if (state.budget < kRoadCost) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos) || tileMap.getData(pos).hasRoad) return false;
    tileMap.setRoad(pos);
    state = state.copyWith(budget: state.budget - kRoadCost);
    return true;
  }

  bool placePowerLine(WorldPosition pos) {
    if (state.budget < kPowerLineCost) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos) || tileMap.getData(pos).hasPowerLine) return false;
    tileMap.setPowerLine(pos);
    state = state.copyWith(budget: state.budget - kPowerLineCost);
    return true;
  }

  bool placePipe(WorldPosition pos) {
    if (state.budget < kPipeCost) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos) || tileMap.getData(pos).hasPipe) return false;
    tileMap.setPipe(pos);
    state = state.copyWith(budget: state.budget - kPipeCost);
    return true;
  }

  String saveToJson() => const GameSerializer().serialize(state);

  void loadFromJson(String json) {
    try {
      state = const GameSerializer().deserialize(json);
    } catch (_) {
      // Corrupt save — ignore
    }
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
        if (d > 0.25 && data.buildingLevel != BuildingLevel.large) {
          final next = data.buildingLevel.next;
          // Roads are required to grow beyond small buildings
          if (next != BuildingLevel.small && !data.hasRoad) continue;
          tileMap.setBuildingLevel(pos, next);
        } else if (d <= 0.0 && data.buildingLevel.hasBuilding) {
          tileMap.setBuildingLevel(pos, BuildingLevel.empty);
        }
      }
    }
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameModel>(GameNotifier.new);
