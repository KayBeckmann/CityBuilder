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
  });

  TerrainType terrain;
  ResourceType? resource;
  int forestAge;
  ZoneType? zone;
  BuildingLevel buildingLevel;
  bool hasRoad;
  bool hasPowerLine;
  bool hasPipe;
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
}
