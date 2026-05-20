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

  // Pre-compute network tiles for power/water overlays
  final poweredTiles =
      overlay == OverlayType.power ? tileMap.computePoweredTiles() : null;
  final wateredTiles =
      overlay == OverlayType.water ? tileMap.computeWateredTiles() : null;

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
            if (data.hasPark) v += 0.3;
            // Check adjacent parks for land value bonus
            for (var d = -2; d <= 2; d++) {
              for (var e = -2; e <= 2; e++) {
                if (d == 0 && e == 0) continue;
                final n = (col: pos.col + d, row: pos.row + e);
                if (!n.isValid(tileMap.width, tileMap.height)) continue;
                if (tileMap.getData(n).hasPark) v += 0.05;
              }
            }
            return v.clamp(0.0, 1.0);
          }(),
        OverlayType.power => (poweredTiles?.contains(pos) ?? false)
            ? 1.0
            : (data.zone != null ? 0.15 : 0.0),
        OverlayType.water => (wateredTiles?.contains(pos) ?? false)
            ? 1.0
            : (data.zone != null ? 0.15 : 0.0),
        OverlayType.traffic => () {
            if (!data.hasRoad) return 0.0;
            // Traffic = sum of building capacities within radius 2
            var load = 0.0;
            for (var dr = -2; dr <= 2; dr++) {
              for (var dc = -2; dc <= 2; dc++) {
                if (dr == 0 && dc == 0) continue;
                final n = (col: pos.col + dc, row: pos.row + dr);
                if (!n.isValid(tileMap.width, tileMap.height)) continue;
                final nd = tileMap.getData(n);
                if (nd.buildingLevel.hasBuilding) load += nd.buildingLevel.capacity;
              }
            }
            return (load / 800.0).clamp(0.0, 1.0);
          }(),
        OverlayType.pollution => () {
            var pollution = 0.0;
            // Sum industrial output from self and nearby tiles
            for (var dr = -3; dr <= 3; dr++) {
              for (var dc = -3; dc <= 3; dc++) {
                final n = (col: pos.col + dc, row: pos.row + dr);
                if (!n.isValid(tileMap.width, tileMap.height)) continue;
                final nd = tileMap.getData(n);
                if (nd.zone == ZoneType.industrial && nd.buildingLevel.hasBuilding) {
                  final dist = (dr.abs() + dc.abs()).toDouble();
                  pollution += (nd.buildingLevel.index / 3.0) * (1.0 - dist / 7.0);
                }
              }
            }
            return pollution.clamp(0.0, 1.0);
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
