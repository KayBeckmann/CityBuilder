import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/zone_type.dart';

class PopulationStats {
  const PopulationStats({
    required this.total,
    required this.capacity,
    required this.history,
  });

  final int total;
  final int capacity;
  final List<int> history;

  double get occupancyRate => capacity > 0 ? total / capacity : 0;

  PopulationStats withNewTick(int newTotal, int newCapacity) {
    final newHistory = [...history, newTotal];
    if (newHistory.length > 10) newHistory.removeAt(0);
    return PopulationStats(
      total: newTotal,
      capacity: newCapacity,
      history: newHistory,
    );
  }
}

PopulationStats calculatePopulation({
  required TileMap tileMap,
  required PopulationStats previous,
  required double satisfactionScore,
}) {
  var capacity = 0;

  for (var row = 0; row < tileMap.height; row++) {
    for (var col = 0; col < tileMap.width; col++) {
      final data = tileMap.getData((col: col, row: row));
      if (data.zone == ZoneType.residential) {
        capacity += data.buildingLevel.capacity;
      }
    }
  }

  final target = (capacity * satisfactionScore.clamp(0, 1)).round();
  var delta = ((target - previous.total) * 0.1).round();
  // Ensure at least 1 person moves in/out when there's room to grow/shrink
  if (target > previous.total && delta == 0) delta = 1;
  if (target < previous.total && delta == 0) delta = -1;
  final newTotal = (previous.total + delta).clamp(0, capacity);

  return previous.withNewTick(newTotal, capacity);
}

double calculateLandValue({
  required TileMap tileMap,
  required int col,
  required int row,
  int radius = 3,
}) {
  var value = 50.0;
  final minCol = (col - radius).clamp(0, tileMap.width - 1);
  final maxCol = (col + radius).clamp(0, tileMap.width - 1);
  final minRow = (row - radius).clamp(0, tileMap.height - 1);
  final maxRow = (row + radius).clamp(0, tileMap.height - 1);

  for (var r = minRow; r <= maxRow; r++) {
    for (var c = minCol; c <= maxCol; c++) {
      final pos = (col: c, row: r);
      final terrain = tileMap.get(pos);
      switch (terrain) {
        case _:
          break;
      }
      final data = tileMap.getData(pos);
      if (data.zone == ZoneType.industrial && data.buildingLevel.hasBuilding) {
        value -= 5;
      }
    }
  }

  return value.clamp(0, 100);
}
