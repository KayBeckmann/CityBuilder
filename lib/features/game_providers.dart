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

const Map<ZoneType, double> kZoneCost = {
  ZoneType.residential: 100.0,
  ZoneType.commercial: 150.0,
  ZoneType.industrial: 200.0,
};

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
    String cityName = 'Neustadt',
  }) {
    _notifiedFirstBuilding = false;
    _notifiedFirstLarge = false;
    _lastInfraStats = const InfraStats();
    _lowEmploymentTicks = 0;
    _lowHousingTicks = 0;
    _lowServicesTicks = 0;
    const generator = MapGenerator();
    final tileMap = generator.generate(seed: seed, size: size);
    state = GameModel(
      tileMap: tileMap,
      budget: startingBudget ?? GameModel.startingBudget,
      tick: 0,
      cityName: cityName,
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
    final cost = zone != null ? (kZoneCost[zone] ?? kZoneCostPerTile) : 0.0;
    if (zone != null && state.budget < cost) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos)) return false;
    if (tileMap.get(pos) == TerrainType.water) return false;

    tileMap.setZone(pos, zone);
    if (zone != null) {
      state = state.copyWith(budget: state.budget - cost);
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

    final hadBuildings = _anyBuilding(tileMap);
    final hadLarge = _anyLarge(tileMap);
    _developZones(tileMap, demand);
    final hasBuildings = _anyBuilding(tileMap);
    final hasLarge = _anyLarge(tileMap);

    if (!hadBuildings && hasBuildings && !_notifiedFirstBuilding) {
      _notifiedFirstBuilding = true;
      ref.read(notificationQueueProvider.notifier).push(
        const CityNotification(message: 'Die Stadt lebt! Erste Gebäude entstehen.'),
      );
    }
    if (!hadLarge && hasLarge && !_notifiedFirstLarge) {
      _notifiedFirstLarge = true;
      ref.read(notificationQueueProvider.notifier).push(
        const CityNotification(message: 'Erstes großes Gebäude! Die Stadt wächst.'),
      );
    }

    final economy = calculateEconomy(
      tileMap: tileMap,
      taxRates: state.taxRates,
    );

    final (newSatisfaction, infraStats) = _computeSatisfaction(tileMap, currentPop, commercial, industrial);
    _lastInfraStats = infraStats;
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

    final newBudget = state.budget + economy.netBalance - loanInterest;
    final newHistory = [...state.budgetHistory, newBudget];
    final budgetHistory = newHistory.length > 20
        ? newHistory.sublist(newHistory.length - 20)
        : newHistory;

    state = state.copyWith(
      tick: state.tick + 1,
      budget: newBudget,
      lastEconomy: economy,
      population: newPopulation,
      satisfaction: newSatisfaction,
      approvalRating: approval,
      infraStats: _lastInfraStats,
      budgetHistory: budgetHistory,
    );

    _checkMilestones(prevPop, newPopulation.total, prevBudget, prevApproval, approval);
  }

  static final _rng = Random();
  InfraStats _lastInfraStats = const InfraStats();
  bool _notifiedFirstBuilding = false;
  bool _notifiedFirstLarge = false;
  int _lowEmploymentTicks = 0;
  int _lowHousingTicks = 0;
  int _lowServicesTicks = 0;
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

    // Contextual hints when satisfaction stays low for multiple ticks
    final sat = state.satisfaction;
    _lowEmploymentTicks = sat.employment < 0.3 ? _lowEmploymentTicks + 1 : 0;
    _lowHousingTicks = sat.housing < 0.3 ? _lowHousingTicks + 1 : 0;
    _lowServicesTicks = sat.services < 0.3 ? _lowServicesTicks + 1 : 0;

    if (_lowEmploymentTicks == 5) {
      q.push(CityNotification(
        message: 'Tipp: Gewerbe- und Industriezonen + Strom erhöhen Beschäftigung.',
        isWarning: false,
      ));
    }
    if (_lowHousingTicks == 5) {
      q.push(CityNotification(
        message: 'Tipp: Straßen neben Wohnzonen verbessern die Wohnqualität.',
        isWarning: false,
      ));
    }
    if (_lowServicesTicks == 5) {
      q.push(CityNotification(
        message: 'Tipp: Parks, Polizei, Krankenhaus und Infrastruktur verbessern Services.',
        isWarning: false,
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

  (SatisfactionFactors, InfraStats) _computeSatisfaction(
    TileMap tileMap,
    int population,
    int commercial,
    int industrial,
  ) {
    final poweredTiles = tileMap.computePoweredTiles();
    final wateredTiles = tileMap.computeWateredTiles();
    var buildings = 0, withRoad = 0, withPower = 0, withWater = 0;
    var parkCount = 0;
    var policeCount = 0;
    var hospitalCount = 0;
    var schoolCount = 0;
    var industrialBuildings = 0;
    for (var row = 0; row < tileMap.height; row++) {
      for (var col = 0; col < tileMap.width; col++) {
        final pos = (col: col, row: row);
        final data = tileMap.getData(pos);
        if (data.hasPark) parkCount++;
        if (data.hasPoliceStation) policeCount++;
        if (data.hasHospital) hospitalCount++;
        if (data.hasSchool) schoolCount++;
        if (data.zone != null && data.buildingLevel.hasBuilding) {
          buildings++;
          if (data.hasRoad) withRoad++;
          if (poweredTiles.contains(pos)) withPower++;
          if (wateredTiles.contains(pos)) withWater++;
          if (data.zone == ZoneType.industrial) industrialBuildings++;
        }
      }
    }

    final stats = InfraStats(
      buildings: buildings,
      roadPct: buildings > 0 ? (withRoad * 100 ~/ buildings) : 0,
      powerPct: buildings > 0 ? (withPower * 100 ~/ buildings) : 0,
      waterPct: buildings > 0 ? (withWater * 100 ~/ buildings) : 0,
      parks: parkCount,
      policeStations: policeCount,
      hospitals: hospitalCount,
      schools: schoolCount,
    );

    if (buildings == 0) {
      return (const SatisfactionFactors(employment: 0.5, housing: 0.5, services: 0.5), stats);
    }

    final roadCov = withRoad / buildings;
    final powerCov = withPower / buildings;
    final pipeCov = withWater / buildings;

    final employmentRatio = population > 0
        ? ((commercial + industrial) * 10.0 / population).clamp(0.0, 1.0)
        : 0.5;

    return (
      SatisfactionFactors(
        employment: (employmentRatio * (0.5 + 0.5 * powerCov) + (hospitalCount * 0.02).clamp(0, 0.1) + (schoolCount * 0.03).clamp(0, 0.15)).clamp(0.0, 1.0),
        housing: (0.3 + 0.7 * roadCov).clamp(0.0, 1.0),
        services: () {
          final pollutionPenalty = (industrialBuildings / buildings * 0.3).clamp(0, 0.25);
          return (0.3 + (parkCount * 0.01).clamp(0, 0.10) + (policeCount * 0.03).clamp(0, 0.10) + (hospitalCount * 0.05).clamp(0, 0.10) + 0.2 * powerCov + 0.2 * pipeCov - pollutionPenalty).clamp(0.0, 1.0);
        }(),
      ),
      stats,
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

  bool placePoliceStation(WorldPosition pos) {
    const cost = 4000.0;
    if (state.budget < cost) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos)) return false;
    if (tileMap.get(pos) == TerrainType.water) return false;
    if (tileMap.getData(pos).hasPoliceStation) return false;
    tileMap.setPoliceStation(pos);
    tileMap.setZone(pos, null); // Can't have zone on police station
    state = state.copyWith(budget: state.budget - cost);
    return true;
  }

  bool placeSchool(WorldPosition pos) {
    const cost = 3500.0;
    if (state.budget < cost) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos)) return false;
    if (tileMap.get(pos) == TerrainType.water) return false;
    if (tileMap.getData(pos).hasSchool) return false;
    tileMap.setSchool(pos);
    tileMap.setZone(pos, null);
    state = state.copyWith(budget: state.budget - cost);
    return true;
  }

  bool placeHospital(WorldPosition pos) {
    const cost = 6000.0;
    if (state.budget < cost) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos)) return false;
    if (tileMap.get(pos) == TerrainType.water) return false;
    if (tileMap.getData(pos).hasHospital) return false;
    tileMap.setHospital(pos);
    tileMap.setZone(pos, null);
    state = state.copyWith(budget: state.budget - cost);
    return true;
  }

  bool placePark(WorldPosition pos) {
    const cost = 500.0;
    if (state.budget < cost) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos)) return false;
    if (tileMap.get(pos) == TerrainType.water) return false;
    if (tileMap.getData(pos).hasPark) return false;
    tileMap.setPark(pos);
    // Remove any existing zone
    tileMap.setZone(pos, null);
    state = state.copyWith(budget: state.budget - cost);
    return true;
  }

  void demolishInfra(WorldPosition pos) {
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos)) return;
    final t = tileMap.getData(pos);
    t.hasRoad = false;
    t.hasPowerLine = false;
    t.hasPipe = false;
    t.hasPark = false;
    t.hasPoliceStation = false;
    t.hasHospital = false;
    t.hasSchool = false;
    // Power plants and water towers kept intact (use demolishAll to remove them)
    state = state.copyWith();
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
    if (!tileMap.contains(pos)) return false;
    if (tileMap.get(pos) == TerrainType.water) return false;
    if (tileMap.getData(pos).hasWaterTower) return false;
    tileMap.setWaterTower(pos);
    state = state.copyWith(budget: state.budget - cost);
    return true;
  }

  bool placePowerPlant(WorldPosition pos) {
    const cost = 5000.0;
    if (state.budget < cost) return false;
    final tileMap = state.tileMap;
    if (!tileMap.contains(pos)) return false;
    if (tileMap.get(pos) == TerrainType.water) return false;
    if (tileMap.getData(pos).hasPowerPlant) return false;
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

  bool _anyBuilding(TileMap tileMap) {
    for (var row = 0; row < tileMap.height; row++) {
      for (var col = 0; col < tileMap.width; col++) {
        if (tileMap.getData((col: col, row: row)).buildingLevel.hasBuilding) return true;
      }
    }
    return false;
  }

  bool _anyLarge(TileMap tileMap) {
    for (var row = 0; row < tileMap.height; row++) {
      for (var col = 0; col < tileMap.width; col++) {
        if (tileMap.getData((col: col, row: row)).buildingLevel == BuildingLevel.large) return true;
      }
    }
    return false;
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
          if (next != BuildingLevel.small && !data.hasRoad) continue;

          // High taxes slow development: >15% tax adds 50% skip chance per 5% over threshold
          final taxRate = state.taxRates.forZone(zone);
          final taxPenalty = ((taxRate - 0.15) / 0.05).clamp(0, 1);
          if (taxPenalty > 0 && _rng.nextDouble() < taxPenalty * 0.5) continue;

          tileMap.setBuildingLevel(pos, next);
        } else if (d <= 0.0 && data.buildingLevel.hasBuilding) {
          tileMap.setBuildingLevel(pos, BuildingLevel.empty);
        }
      }
    }
  }
}

final gameProvider = NotifierProvider<GameNotifier, GameModel>(GameNotifier.new);
