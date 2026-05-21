import 'package:city_builder/core/terrain_type.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ToolCategory { inspect, zones, demolish, infrastructure }

enum ToolType {
  // Inspect
  inspect,
  // Zones
  zoneResidential,
  zoneCommercial,
  zoneIndustrial,
  // Demolish
  demolishZone,
  demolishInfra,
  demolishAll,
  // Infrastructure
  road,
  powerLine,
  pipe,
  // Special buildings
  park,
  policeStation,
  hospital,
  school,
  fireStation,
  powerPlant,
  waterTower,
  spaceport,
  // Rail
  railTrack,
  station,
  // Extraction buildings
  mine,
  sawmill,
  oilPump,
  quarry,
  // Terrain edit
  terrainGrass,
  terrainForest,
  terrainHill,
  terrainWater;

  String get label => switch (this) {
        ToolType.inspect => 'Inspizieren',
        ToolType.zoneResidential => 'Wohnzone',
        ToolType.zoneCommercial => 'Gewerbe',
        ToolType.zoneIndustrial => 'Industrie',
        ToolType.demolishZone => 'Zone entf.',
        ToolType.demolishInfra => 'Infra entf.',
        ToolType.demolishAll => 'Alles abreißen',
        ToolType.road => 'Straße',
        ToolType.powerLine => 'Stromleitung',
        ToolType.pipe => 'Wasserleitung',
        ToolType.park => 'Park',
        ToolType.policeStation => 'Polizei',
        ToolType.hospital => 'Krankenhaus',
        ToolType.school => 'Schule',
        ToolType.fireStation => 'Feuerwehr',
        ToolType.powerPlant => 'Kraftwerk',
        ToolType.waterTower => 'Wasserturm',
        ToolType.spaceport => 'Raumhafen',
        ToolType.railTrack => 'Gleis',
        ToolType.station => 'Bahnhof',
        ToolType.mine => 'Mine',
        ToolType.sawmill => 'Sägewerk',
        ToolType.oilPump => 'Ölpumpe',
        ToolType.quarry => 'Steinbruch',
        ToolType.terrainGrass => 'Wiese',
        ToolType.terrainForest => 'Wald',
        ToolType.terrainHill => 'Hügel',
        ToolType.terrainWater => 'Wasser',
      };

  IconData get icon => switch (this) {
        ToolType.inspect => Icons.info_outline,
        ToolType.zoneResidential => Icons.home_outlined,
        ToolType.zoneCommercial => Icons.store_outlined,
        ToolType.zoneIndustrial => Icons.factory_outlined,
        ToolType.demolishZone => Icons.delete_outline,
        ToolType.demolishInfra => Icons.cable_outlined,
        ToolType.demolishAll => Icons.delete_forever_outlined,
        ToolType.road => Icons.add_road,
        ToolType.powerLine => Icons.bolt_outlined,
        ToolType.pipe => Icons.water_outlined,
        ToolType.park => Icons.park_rounded,
        ToolType.policeStation => Icons.local_police_outlined,
        ToolType.hospital => Icons.local_hospital_outlined,
        ToolType.school => Icons.school_outlined,
        ToolType.fireStation => Icons.local_fire_department_outlined,
        ToolType.powerPlant => Icons.power_outlined,
        ToolType.waterTower => Icons.water_damage_outlined,
        ToolType.spaceport => Icons.rocket_launch_outlined,
        ToolType.railTrack => Icons.linear_scale_outlined,
        ToolType.station => Icons.train_outlined,
        ToolType.mine => Icons.hardware_outlined,
        ToolType.sawmill => Icons.forest_outlined,
        ToolType.oilPump => Icons.oil_barrel_outlined,
        ToolType.quarry => Icons.landscape,
        ToolType.terrainGrass => Icons.grass,
        ToolType.terrainForest => Icons.park_outlined,
        ToolType.terrainHill => Icons.landscape_outlined,
        ToolType.terrainWater => Icons.water,
      };

  Color get color => switch (this) {
        ToolType.inspect => Colors.white,
        ToolType.zoneResidential => const Color(0xFF4CAF50),
        ToolType.zoneCommercial => const Color(0xFF2196F3),
        ToolType.zoneIndustrial => const Color(0xFFFF9800),
        ToolType.demolishZone => const Color(0xFFEF5350),
        ToolType.demolishInfra => const Color(0xFFFF7043),
        ToolType.demolishAll => const Color(0xFFC62828),
        ToolType.road => const Color(0xFF90A4AE),
        ToolType.powerLine => const Color(0xFFFFEE58),
        ToolType.pipe => const Color(0xFF42A5F5),
        ToolType.park => const Color(0xFF00C853),
        ToolType.policeStation => const Color(0xFF1565C0),
        ToolType.hospital => const Color(0xFFE53935),
        ToolType.school => const Color(0xFFFF9800),
        ToolType.fireStation => const Color(0xFFDD2C00),
        ToolType.powerPlant => const Color(0xFFFFCC02),
        ToolType.waterTower => const Color(0xFF00BCD4),
        ToolType.spaceport => const Color(0xFF7B1FA2),
        ToolType.railTrack => const Color(0xFF5D4037),
        ToolType.station => const Color(0xFF4E342E),
        ToolType.mine => const Color(0xFF8D6E63),
        ToolType.sawmill => const Color(0xFF558B2F),
        ToolType.oilPump => const Color(0xFF37474F),
        ToolType.quarry => const Color(0xFF78909C),
        ToolType.terrainGrass => const Color(0xFF81C784),
        ToolType.terrainForest => const Color(0xFF388E3C),
        ToolType.terrainHill => const Color(0xFFA1887F),
        ToolType.terrainWater => const Color(0xFF29B6F6),
      };

  double get costPerTile => switch (this) {
        ToolType.inspect => 0,
        ToolType.zoneResidential => 100,
        ToolType.zoneCommercial => 150,
        ToolType.zoneIndustrial => 200,
        ToolType.demolishZone => 0,
        ToolType.demolishInfra => 0,
        ToolType.demolishAll => 50,
        ToolType.road => 300,
        ToolType.powerLine => 200,
        ToolType.pipe => 250,
        ToolType.park => 500,
        ToolType.policeStation => 4000,
        ToolType.hospital => 6000,
        ToolType.school => 3500,
        ToolType.fireStation => 4500,
        ToolType.powerPlant => 5000,
        ToolType.waterTower => 3000,
        ToolType.spaceport => 50000,
        ToolType.railTrack => 400,
        ToolType.station => 8000,
        ToolType.mine => 5000,
        ToolType.sawmill => 4000,
        ToolType.oilPump => 6000,
        ToolType.quarry => 3500,
        ToolType.terrainGrass => 500,
        ToolType.terrainForest => 300,
        ToolType.terrainHill => 1500,
        ToolType.terrainWater => 2000,
      };

  TerrainType? get terrain => switch (this) {
        ToolType.terrainGrass => TerrainType.grass,
        ToolType.terrainForest => TerrainType.forest,
        ToolType.terrainHill => TerrainType.hill,
        ToolType.terrainWater => TerrainType.water,
        _ => null,
      };

  ZoneType? get zone => switch (this) {
        ToolType.zoneResidential => ZoneType.residential,
        ToolType.zoneCommercial => ZoneType.commercial,
        ToolType.zoneIndustrial => ZoneType.industrial,
        _ => null,
      };
}

class ToolNotifier extends Notifier<ToolType> {
  @override
  ToolType build() => ToolType.inspect;

  void select(ToolType tool) => state = tool;
}

final toolProvider = NotifierProvider<ToolNotifier, ToolType>(ToolNotifier.new);
