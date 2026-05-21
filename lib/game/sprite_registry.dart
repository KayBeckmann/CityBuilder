import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/resource_system.dart';
import 'package:city_builder/core/terrain_type.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

class SpriteRegistry {
  SpriteRegistry._();

  static final SpriteRegistry I = SpriteRegistry._();

  final Map<String, Sprite> _cache = {};

  bool _loaded = false;
  bool _disabled = false;
  bool get isLoaded => _loaded;

  void disableForTest() {
    _disabled = true;
    _loaded = true;
  }

  static const _spritePaths = [
    'tiles/rail_h.png',
    'tiles/rail_v.png',
    'tiles/terrain_grass.png',
    'tiles/terrain_water.png',
    'tiles/terrain_hill.png',
    'tiles/terrain_forest.png',
    'tiles/building_res_1.png',
    'tiles/building_res_2.png',
    'tiles/building_res_3.png',
    'tiles/building_com_1.png',
    'tiles/building_com_2.png',
    'tiles/building_com_3.png',
    'tiles/building_ind_1.png',
    'tiles/building_ind_2.png',
    'tiles/building_ind_3.png',
    'tiles/building_police.png',
    'tiles/building_fire.png',
    'tiles/building_hospital.png',
    'tiles/building_school.png',
    'tiles/building_university.png',
    'tiles/building_spaceport.png',
    'tiles/building_mine.png',
    'tiles/building_sawmill.png',
    'tiles/building_oil_pump.png',
    'tiles/building_quarry.png',
    'tiles/building_smelter.png',
    'tiles/building_coal_plant.png',
    'tiles/building_solar_plant.png',
    'tiles/building_wind_turbine.png',
  ];

  /// Starts loading all sprites in the background. Safe to call multiple times.
  void schedulePreload() {
    if (_loaded || _disabled) return;
    _loaded = true;
    for (final path in _spritePaths) {
      Flame.images
          .load(path)
          .then((image) => _cache[path] = Sprite(image))
          .ignore();
    }
  }

  Future<void> preload() async => schedulePreload();

  Sprite? terrainSprite(TerrainType terrain) => _cache[_terrainPath(terrain)];

  Sprite? buildingSprite(ZoneType zone, BuildingLevel level) {
    if (!level.hasBuilding) return null;
    return _cache[_buildingPath(zone, level)];
  }

  Sprite? namedSprite(String path) => _cache[path];

  Sprite? extractionSprite(ExtractionBuildingType type) => switch (type) {
        ExtractionBuildingType.mine => namedSprite('tiles/building_mine.png'),
        ExtractionBuildingType.sawmill =>
          namedSprite('tiles/building_sawmill.png'),
        ExtractionBuildingType.oilPump =>
          namedSprite('tiles/building_oil_pump.png'),
        ExtractionBuildingType.quarry =>
          namedSprite('tiles/building_quarry.png'),
      };

  String _terrainPath(TerrainType terrain) => switch (terrain) {
        TerrainType.grass => 'tiles/terrain_grass.png',
        TerrainType.water => 'tiles/terrain_water.png',
        TerrainType.hill => 'tiles/terrain_hill.png',
        TerrainType.forest => 'tiles/terrain_forest.png',
      };

  String _buildingPath(ZoneType zone, BuildingLevel level) {
    final prefix = switch (zone) {
      ZoneType.residential => 'res',
      ZoneType.commercial => 'com',
      ZoneType.industrial => 'ind',
    };
    final suffix = switch (level) {
      BuildingLevel.small => '1',
      BuildingLevel.medium => '2',
      BuildingLevel.large => '3',
      BuildingLevel.empty => '1',
    };
    return 'tiles/building_${prefix}_$suffix.png';
  }
}
