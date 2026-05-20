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
  powerPlant,
  waterTower,
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
        ToolType.powerPlant => 'Kraftwerk',
        ToolType.waterTower => 'Wasserturm',
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
        ToolType.powerPlant => Icons.power_outlined,
        ToolType.waterTower => Icons.water_damage_outlined,
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
        ToolType.powerPlant => const Color(0xFFFFCC02),
        ToolType.waterTower => const Color(0xFF00BCD4),
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
        ToolType.powerPlant => 5000,
        ToolType.waterTower => 3000,
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
