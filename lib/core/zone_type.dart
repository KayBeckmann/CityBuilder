import 'package:flutter/material.dart';

enum ZoneType {
  residential,
  commercial,
  industrial;

  Color get overlayColor => switch (this) {
        ZoneType.residential => const Color(0x8032CD32),
        ZoneType.commercial => const Color(0x800000FF),
        ZoneType.industrial => const Color(0x80FFA500),
      };

  String get label => switch (this) {
        ZoneType.residential => 'R',
        ZoneType.commercial => 'C',
        ZoneType.industrial => 'I',
      };

  String get fullLabel => switch (this) {
        ZoneType.residential => 'Wohngebiet',
        ZoneType.commercial => 'Gewerbe',
        ZoneType.industrial => 'Industrie',
      };
}
