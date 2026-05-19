import 'package:city_builder/core/overlay_type.dart';
import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/world_position.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverlayNotifier extends Notifier<OverlayType> {
  @override
  OverlayType build() => OverlayType.none;

  void setOverlay(OverlayType type) => state = type;
  void toggle(OverlayType type) => state = state == type ? OverlayType.none : type;
}

final overlayProvider = NotifierProvider<OverlayNotifier, OverlayType>(OverlayNotifier.new);

Map<WorldPosition, double> computeOverlayValues(
  TileMap tileMap,
  OverlayType overlay,
) {
  if (overlay == OverlayType.none) return const {};

  final result = <WorldPosition, double>{};

  for (var row = 0; row < tileMap.height; row++) {
    for (var col = 0; col < tileMap.width; col++) {
      final pos = (col: col, row: row);
      final data = tileMap.getData(pos);

      final value = switch (overlay) {
        OverlayType.populationDensity => () {
            if (data.zone == ZoneType.residential) {
              return data.buildingLevel.capacity / 200.0;
            }
            return 0.0;
          }(),
        OverlayType.landValue => () {
            var v = 0.5;
            if (data.zone == ZoneType.industrial && data.buildingLevel.hasBuilding) v -= 0.3;
            if (data.zone == ZoneType.commercial && data.buildingLevel.hasBuilding) v += 0.2;
            return v.clamp(0.0, 1.0);
          }(),
        OverlayType.power => data.buildingLevel.hasBuilding ? 0.7 : 0.2,
        OverlayType.water => data.buildingLevel.hasBuilding ? 0.7 : 0.1,
        OverlayType.traffic => () {
            if (data.zone != null && data.buildingLevel.hasBuilding) {
              return (data.buildingLevel.capacity / 200.0).clamp(0.0, 1.0);
            }
            return 0.0;
          }(),
        OverlayType.pollution => () {
            if (data.zone == ZoneType.industrial && data.buildingLevel.hasBuilding) {
              return (data.buildingLevel.index / 3.0).clamp(0.0, 1.0);
            }
            return 0.0;
          }(),
        OverlayType.crime => () {
            if (data.zone == ZoneType.industrial && data.buildingLevel.hasBuilding) return 0.6;
            if (data.zone == ZoneType.commercial && data.buildingLevel.hasBuilding) return 0.3;
            return 0.1;
          }(),
        OverlayType.none => 0.0,
      };

      if (value > 0) result[pos] = value;
    }
  }
  return result;
}
