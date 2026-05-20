import 'dart:convert';

import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/economy.dart';
import 'package:city_builder/core/game_model.dart';
import 'package:city_builder/core/map_generator.dart';
import 'package:city_builder/core/population_model.dart';
import 'package:city_builder/core/resource_type.dart';
import 'package:city_builder/core/satisfaction_system.dart';
import 'package:city_builder/core/space_phase.dart';
import 'package:city_builder/core/tech_tree.dart';
import 'package:city_builder/core/terrain_type.dart';
import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/zone_type.dart';

class GameSerializer {
  const GameSerializer();

  String serialize(GameModel model) {
    final tiles = <List<Map<String, dynamic>>>[];
    for (var row = 0; row < model.tileMap.height; row++) {
      final rowList = <Map<String, dynamic>>[];
      for (var col = 0; col < model.tileMap.width; col++) {
        final pos = (col: col, row: row);
        final data = model.tileMap.getData(pos);
        rowList.add({
          't': data.terrain.index,
          if (data.zone != null) 'z': data.zone!.index,
          if (data.buildingLevel != BuildingLevel.empty) 'b': data.buildingLevel.index,
          if (data.resource != null) 'r': data.resource!.index,
          if (data.hasRoad) 'rd': 1,
          if (data.hasPowerLine) 'pl': 1,
          if (data.hasPipe) 'pp': 1,
          if (data.hasPowerPlant) 'pw': 1,
          if (data.hasWaterTower) 'wt': 1,
          if (data.hasPark) 'pk': 1,
          if (data.hasPoliceStation) 'ps': 1,
          if (data.hasHospital) 'hp': 1,
          if (data.hasSchool) 'sc': 1,
          if (data.hasFireStation) 'fs': 1,
          if (data.hasSpaceport) 'sp': 1,
        });
      }
      tiles.add(rowList);
    }

    final json = {
      'version': 1,
      'width': model.tileMap.width,
      'height': model.tileMap.height,
      'budget': model.budget,
      'tick': model.tick,
      'taxR': model.taxRates.residential,
      'taxC': model.taxRates.commercial,
      'taxI': model.taxRates.industrial,
      'popTotal': model.population.total,
      'popCap': model.population.capacity,
      'popHistory': model.population.history,
      'satE': model.satisfaction.employment,
      'satH': model.satisfaction.housing,
      'satS': model.satisfaction.services,
      'approval': model.approvalRating,
      'loan': model.loan,
      'cityName': model.cityName,
      'techResearched': model.techTree.researched.map((n) => n.index).toList(),
      'techProgress': model.techTree.progress
          .map((k, v) => MapEntry(k.index.toString(), v)),
      'techPoints': model.techTree.researchPoints,
      'spaceActive': model.spacePhase.spacePhaseActive,
      'spaceRE': model.spacePhase.rareEarthStockpile,
      'spaceColony': model.spacePhase.colonyPopulation,
      'spaceMissions': model.spacePhase.activeMissions.map((m) => {
            'type': m.type.index,
            'start': m.startedAtTick,
            'dur': m.durationTicks,
          }).toList(),
      'tiles': tiles,
    };

    return jsonEncode(json);
  }

  GameModel deserialize(String data) {
    final json = jsonDecode(data) as Map<String, dynamic>;
    final width = json['width'] as int;
    final height = json['height'] as int;

    final tileMap = TileMap(width: width, height: height);
    final rawTiles = json['tiles'] as List<dynamic>;

    for (var row = 0; row < height; row++) {
      final rowList = rawTiles[row] as List<dynamic>;
      for (var col = 0; col < width; col++) {
        final cell = rowList[col] as Map<String, dynamic>;
        final pos = (col: col, row: row);
        tileMap.set(pos, TerrainType.values[cell['t'] as int]);
        if (cell.containsKey('z')) {
          tileMap.setZone(pos, ZoneType.values[cell['z'] as int]);
        }
        if (cell.containsKey('b')) {
          tileMap.setBuildingLevel(pos, BuildingLevel.values[cell['b'] as int]);
        }
        if (cell.containsKey('r')) {
          tileMap.setResource(pos, ResourceType.values[cell['r'] as int]);
        }
        if (cell.containsKey('rd')) tileMap.setRoad(pos);
        if (cell.containsKey('pl')) tileMap.setPowerLine(pos);
        if (cell.containsKey('pp')) tileMap.setPipe(pos);
        if (cell.containsKey('pw')) tileMap.setPowerPlant(pos);
        if (cell.containsKey('wt')) tileMap.setWaterTower(pos);
        if (cell.containsKey('pk')) tileMap.setPark(pos);
        if (cell.containsKey('ps')) tileMap.setPoliceStation(pos);
        if (cell.containsKey('hp')) tileMap.setHospital(pos);
        if (cell.containsKey('sc')) tileMap.setSchool(pos);
        if (cell.containsKey('fs')) tileMap.setFireStation(pos);
        if (cell.containsKey('sp')) tileMap.setSpaceport(pos);
      }
    }

    final historyRaw = json['popHistory'] as List<dynamic>;
    final history = historyRaw.map((e) => e as int).toList();

    TechTreeState? techTree;
    if (json.containsKey('techResearched')) {
      final researched = (json['techResearched'] as List<dynamic>)
          .map((i) => TechNode.values[i as int])
          .toSet();
      final progressRaw =
          (json['techProgress'] as Map<String, dynamic>?) ?? {};
      final progress = progressRaw.map(
        (k, v) => MapEntry(TechNode.values[int.parse(k)], (v as num).toDouble()),
      );
      techTree = TechTreeState(
        researched: researched,
        progress: progress,
        researchPoints: (json['techPoints'] as num? ?? 0).toDouble(),
      );
    }

    return GameModel(
      tileMap: tileMap,
      budget: (json['budget'] as num).toDouble(),
      tick: json['tick'] as int,
      taxRates: TaxRates(
        residential: (json['taxR'] as num).toDouble(),
        commercial: (json['taxC'] as num).toDouble(),
        industrial: (json['taxI'] as num).toDouble(),
      ),
      population: PopulationStats(
        total: json['popTotal'] as int,
        capacity: json['popCap'] as int,
        history: history,
      ),
      satisfaction: SatisfactionFactors(
        employment: (json['satE'] as num).toDouble(),
        housing: (json['satH'] as num).toDouble(),
        services: (json['satS'] as num).toDouble(),
      ),
      approvalRating: (json['approval'] as num).toDouble(),
      loan: (json['loan'] as num? ?? 0).toDouble(),
      cityName: (json['cityName'] as String? ?? 'Neustadt'),
      techTree: techTree,
      spacePhase: json.containsKey('spaceActive')
          ? SpacePhaseState(
              spacePhaseActive: json['spaceActive'] as bool? ?? false,
              rareEarthStockpile:
                  (json['spaceRE'] as num? ?? 0).toDouble(),
              colonyPopulation: json['spaceColony'] as int? ?? 0,
              activeMissions:
                  ((json['spaceMissions'] as List<dynamic>?) ?? [])
                      .map((m) {
                        final map = m as Map<String, dynamic>;
                        return SpaceMission(
                          type: SpaceMissionType.values[map['type'] as int],
                          startedAtTick: map['start'] as int,
                          durationTicks: map['dur'] as int,
                        );
                      })
                      .toList(),
            )
          : null,
    );
  }
}

GameModel newGame({
  required int seed,
  required MapSize size,
  double budget = GameModel.startingBudget,
}) {
  const generator = MapGenerator();
  final tileMap = generator.generate(seed: seed, size: size);
  return GameModel(tileMap: tileMap, budget: budget, tick: 0);
}
