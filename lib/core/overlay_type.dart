import 'package:flutter/material.dart';

enum OverlayType {
  none,
  power,
  water,
  traffic,
  pollution,
  crime,
  landValue,
  populationDensity;

  String get label => switch (this) {
        OverlayType.none => 'Normal',
        OverlayType.power => 'Strom',
        OverlayType.water => 'Wasser',
        OverlayType.traffic => 'Verkehr',
        OverlayType.pollution => 'Verschmutzung',
        OverlayType.crime => 'Kriminalität',
        OverlayType.landValue => 'Bodenwert',
        OverlayType.populationDensity => 'Bevölkerung',
      };

  IconData get icon => switch (this) {
        OverlayType.none => Icons.map_outlined,
        OverlayType.power => Icons.bolt,
        OverlayType.water => Icons.water_drop_outlined,
        OverlayType.traffic => Icons.traffic_outlined,
        OverlayType.pollution => Icons.cloud_outlined,
        OverlayType.crime => Icons.security_outlined,
        OverlayType.landValue => Icons.trending_up_outlined,
        OverlayType.populationDensity => Icons.people_outlined,
      };

  Color get lowColor => switch (this) {
        OverlayType.power => const Color(0x8032CD32),
        OverlayType.water => const Color(0x800080FF),
        OverlayType.traffic => const Color(0x8000FF00),
        OverlayType.pollution => const Color(0x8000FF00),
        OverlayType.crime => const Color(0x8000FF00),
        OverlayType.landValue => const Color(0x80FF4500),
        OverlayType.populationDensity => const Color(0x80FFFF00),
        OverlayType.none => Colors.transparent,
      };

  Color get highColor => switch (this) {
        OverlayType.power => const Color(0x80FF4500),
        OverlayType.water => const Color(0x800000FF),
        OverlayType.traffic => const Color(0x80FF0000),
        OverlayType.pollution => const Color(0x80FF0000),
        OverlayType.crime => const Color(0x80FF0000),
        OverlayType.landValue => const Color(0x8000FF00),
        OverlayType.populationDensity => const Color(0x80FF6600),
        OverlayType.none => Colors.transparent,
      };
}
