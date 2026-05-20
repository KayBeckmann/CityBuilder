import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/resource_type.dart';
import 'package:city_builder/core/terrain_type.dart';
import 'package:city_builder/core/world_position.dart';
import 'package:city_builder/core/zone_type.dart';

class TileData {
  TileData({
    required this.terrain,
    this.resource,
    this.forestAge = 0,
    this.zone,
    this.buildingLevel = BuildingLevel.empty,
    this.hasRoad = false,
    this.hasPowerLine = false,
    this.hasPipe = false,
    this.hasPowerPlant = false,
    this.hasWaterTower = false,
    this.hasPark = false,
    this.hasPoliceStation = false,
    this.hasHospital = false,
    this.hasSchool = false,
    this.hasFireStation = false,
  });

  TerrainType terrain;
  ResourceType? resource;
  int forestAge;
  ZoneType? zone;
  BuildingLevel buildingLevel;
  bool hasRoad;
  bool hasPowerLine;
  bool hasPipe;
  bool hasPowerPlant;
  bool hasWaterTower;
  bool hasPark;
  bool hasPoliceStation;
  bool hasHospital;
  bool hasSchool;
  bool hasFireStation;
}

class TileMap {
  TileMap({required this.width, required this.height})
      : _tiles = List.generate(
          height,
          (_) => List.generate(width, (_) => TileData(terrain: TerrainType.grass)),
        );

  final int width;
  final int height;

  final List<List<TileData>> _tiles;

  int get tileCount => width * height;

  TileData getData(WorldPosition pos) => _tiles[pos.row][pos.col];

  TerrainType get(WorldPosition pos) => _tiles[pos.row][pos.col].terrain;

  void set(WorldPosition pos, TerrainType type) {
    assert(pos.isValid(width, height), 'Position out of bounds: $pos');
    _tiles[pos.row][pos.col].terrain = type;
  }

  void setResource(WorldPosition pos, ResourceType? resource) {
    assert(pos.isValid(width, height), 'Position out of bounds: $pos');
    _tiles[pos.row][pos.col].resource = resource;
  }

  ResourceType? getResource(WorldPosition pos) =>
      _tiles[pos.row][pos.col].resource;

  ZoneType? getZone(WorldPosition pos) => _tiles[pos.row][pos.col].zone;

  void setZone(WorldPosition pos, ZoneType? zone) {
    assert(pos.isValid(width, height), 'Position out of bounds: $pos');
    if (zone != null && _tiles[pos.row][pos.col].hasPark) return;
    _tiles[pos.row][pos.col].zone = zone;
    if (zone == null) {
      _tiles[pos.row][pos.col].buildingLevel = BuildingLevel.empty;
    }
  }

  BuildingLevel getBuildingLevel(WorldPosition pos) =>
      _tiles[pos.row][pos.col].buildingLevel;

  void setBuildingLevel(WorldPosition pos, BuildingLevel level) {
    assert(pos.isValid(width, height), 'Position out of bounds: $pos');
    _tiles[pos.row][pos.col].buildingLevel = level;
  }

  bool contains(WorldPosition pos) => pos.isValid(width, height);

  void setRoad(WorldPosition pos, {bool value = true}) {
    assert(pos.isValid(width, height));
    _tiles[pos.row][pos.col].hasRoad = value;
  }

  void setPowerLine(WorldPosition pos, {bool value = true}) {
    assert(pos.isValid(width, height));
    _tiles[pos.row][pos.col].hasPowerLine = value;
  }

  void setPipe(WorldPosition pos, {bool value = true}) {
    assert(pos.isValid(width, height));
    _tiles[pos.row][pos.col].hasPipe = value;
  }

  void setPowerPlant(WorldPosition pos, {bool value = true}) {
    assert(pos.isValid(width, height));
    _tiles[pos.row][pos.col].hasPowerPlant = value;
  }

  void setWaterTower(WorldPosition pos, {bool value = true}) {
    assert(pos.isValid(width, height));
    _tiles[pos.row][pos.col].hasWaterTower = value;
  }

  void setPark(WorldPosition pos, {bool value = true}) {
    assert(pos.isValid(width, height));
    _tiles[pos.row][pos.col].hasPark = value;
  }

  void setPoliceStation(WorldPosition pos, {bool value = true}) {
    assert(pos.isValid(width, height));
    _tiles[pos.row][pos.col].hasPoliceStation = value;
  }

  void setFireStation(WorldPosition pos, {bool value = true}) {
    assert(pos.isValid(width, height));
    _tiles[pos.row][pos.col].hasFireStation = value;
  }

  void setSchool(WorldPosition pos, {bool value = true}) {
    assert(pos.isValid(width, height));
    _tiles[pos.row][pos.col].hasSchool = value;
  }

  void setHospital(WorldPosition pos, {bool value = true}) {
    assert(pos.isValid(width, height));
    _tiles[pos.row][pos.col].hasHospital = value;
  }

  void clearAll(WorldPosition pos) {
    assert(pos.isValid(width, height));
    final t = _tiles[pos.row][pos.col];
    t.zone = null;
    t.buildingLevel = BuildingLevel.empty;
    t.hasRoad = false;
    t.hasPowerLine = false;
    t.hasPipe = false;
    t.hasPowerPlant = false;
    t.hasWaterTower = false;
    t.hasPark = false;
    t.hasPoliceStation = false;
    t.hasHospital = false;
    t.hasSchool = false;
    t.hasFireStation = false;
  }

  Set<WorldPosition> computeWateredTiles() {
    final towers = <WorldPosition>[];
    final pipes = <WorldPosition>{};
    for (var row = 0; row < height; row++) {
      for (var col = 0; col < width; col++) {
        final pos = (col: col, row: row);
        final data = _tiles[row][col];
        if (data.hasWaterTower) towers.add(pos);
        if (data.hasPipe || data.hasWaterTower) pipes.add(pos);
      }
    }
    if (towers.isEmpty) return const {};

    final watered = <WorldPosition>{};
    final queue = [...towers];
    while (queue.isNotEmpty) {
      final pos = queue.removeLast();
      if (!watered.add(pos)) continue;
      for (final n in _neighbors(pos)) {
        if (!watered.contains(n) && pipes.contains(n)) queue.add(n);
      }
    }
    return watered;
  }

  Set<WorldPosition> computePoweredTiles() {
    final plants = <WorldPosition>[];
    final lines = <WorldPosition>{};
    for (var row = 0; row < height; row++) {
      for (var col = 0; col < width; col++) {
        final pos = (col: col, row: row);
        final data = _tiles[row][col];
        if (data.hasPowerPlant) plants.add(pos);
        if (data.hasPowerLine || data.hasPowerPlant) lines.add(pos);
      }
    }
    if (plants.isEmpty) return const {};

    final powered = <WorldPosition>{};
    final queue = [...plants];
    while (queue.isNotEmpty) {
      final pos = queue.removeLast();
      if (!powered.add(pos)) continue;
      for (final n in _neighbors(pos)) {
        if (!powered.contains(n) && lines.contains(n)) queue.add(n);
      }
    }
    return powered;
  }

  List<WorldPosition> _neighbors(WorldPosition pos) => [
        (col: pos.col - 1, row: pos.row),
        (col: pos.col + 1, row: pos.row),
        (col: pos.col, row: pos.row - 1),
        (col: pos.col, row: pos.row + 1),
      ].where((p) => p.isValid(width, height)).toList();
}
