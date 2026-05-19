import 'package:city_builder/core/world_position.dart';

enum PowerPlantType {
  coal,
  solar,
  wind,
  gas;

  int get capacity => switch (this) {
        PowerPlantType.coal => 5000,
        PowerPlantType.solar => 1000,
        PowerPlantType.wind => 800,
        PowerPlantType.gas => 3000,
      };
}

class PowerPlant {
  const PowerPlant({required this.position, required this.type});

  final WorldPosition position;
  final PowerPlantType type;

  int get capacity => type.capacity;
}

class PowerLine {
  const PowerLine({required this.from, required this.to});

  final WorldPosition from;
  final WorldPosition to;
}

class PowerGridState {
  const PowerGridState({
    required this.poweredTiles,
    required this.totalCapacity,
    required this.totalDemand,
  });

  final Set<WorldPosition> poweredTiles;
  final int totalCapacity;
  final int totalDemand;

  bool get isBlackout => totalDemand > totalCapacity;
  double get loadFactor => totalCapacity > 0 ? totalDemand / totalCapacity : 0;

  bool isPowered(WorldPosition pos) => poweredTiles.contains(pos);
}

class PowerGridSystem {
  PowerGridState calculate({
    required List<PowerPlant> plants,
    required List<PowerLine> lines,
    required int gridWidth,
    required int gridHeight,
    required Map<WorldPosition, int> demandMap,
  }) {
    if (plants.isEmpty) {
      return const PowerGridState(
        poweredTiles: <WorldPosition>{},
        totalCapacity: 0,
        totalDemand: 0,
      );
    }

    final adjacency = _buildAdjacency(lines);
    final powered = <WorldPosition>{};

    for (final plant in plants) {
      _floodFill(plant.position, adjacency, powered);
    }

    final capacity = plants.fold(0, (sum, p) => sum + p.capacity);
    final demand = demandMap.values.fold(0, (sum, d) => sum + d);

    return PowerGridState(
      poweredTiles: powered,
      totalCapacity: capacity,
      totalDemand: demand,
    );
  }

  Map<WorldPosition, Set<WorldPosition>> _buildAdjacency(List<PowerLine> lines) {
    final adj = <WorldPosition, Set<WorldPosition>>{};
    for (final line in lines) {
      adj.putIfAbsent(line.from, () => {}).add(line.to);
      adj.putIfAbsent(line.to, () => {}).add(line.from);
    }
    return adj;
  }

  void _floodFill(
    WorldPosition start,
    Map<WorldPosition, Set<WorldPosition>> adjacency,
    Set<WorldPosition> visited,
  ) {
    final queue = [start];
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      if (visited.contains(current)) continue;
      visited.add(current);
      final neighbors = adjacency[current] ?? {};
      for (final n in neighbors) {
        if (!visited.contains(n)) queue.add(n);
      }
    }
  }
}
