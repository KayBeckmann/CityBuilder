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
  demolishAll,
  // Infrastructure
  road,
  powerLine,
  pipe;

  String get label => switch (this) {
        ToolType.inspect => 'Inspizieren',
        ToolType.zoneResidential => 'Wohnzone',
        ToolType.zoneCommercial => 'Gewerbe',
        ToolType.zoneIndustrial => 'Industrie',
        ToolType.demolishZone => 'Zone entf.',
        ToolType.demolishAll => 'Alles abreißen',
        ToolType.road => 'Straße',
        ToolType.powerLine => 'Stromleitung',
        ToolType.pipe => 'Wasserleitung',
      };

  IconData get icon => switch (this) {
        ToolType.inspect => Icons.info_outline,
        ToolType.zoneResidential => Icons.home_outlined,
        ToolType.zoneCommercial => Icons.store_outlined,
        ToolType.zoneIndustrial => Icons.factory_outlined,
        ToolType.demolishZone => Icons.delete_outline,
        ToolType.demolishAll => Icons.delete_forever_outlined,
        ToolType.road => Icons.add_road,
        ToolType.powerLine => Icons.bolt_outlined,
        ToolType.pipe => Icons.water_outlined,
      };

  Color get color => switch (this) {
        ToolType.inspect => Colors.white,
        ToolType.zoneResidential => const Color(0xFF4CAF50),
        ToolType.zoneCommercial => const Color(0xFF2196F3),
        ToolType.zoneIndustrial => const Color(0xFFFF9800),
        ToolType.demolishZone => const Color(0xFFEF5350),
        ToolType.demolishAll => const Color(0xFFC62828),
        ToolType.road => const Color(0xFF90A4AE),
        ToolType.powerLine => const Color(0xFFFFEE58),
        ToolType.pipe => const Color(0xFF42A5F5),
      };

  double get costPerTile => switch (this) {
        ToolType.inspect => 0,
        ToolType.zoneResidential => 100,
        ToolType.zoneCommercial => 150,
        ToolType.zoneIndustrial => 200,
        ToolType.demolishZone => 0,
        ToolType.demolishAll => 50,
        ToolType.road => 300,
        ToolType.powerLine => 200,
        ToolType.pipe => 250,
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
