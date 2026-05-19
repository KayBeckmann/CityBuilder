import 'package:city_builder/core/world_position.dart';

class WaterSource {
  const WaterSource({required this.position, required this.capacity});

  final WorldPosition position;
  final int capacity;
}

class WaterPipe {
  const WaterPipe({required this.from, required this.to});

  final WorldPosition from;
  final WorldPosition to;
}

class SewerPlant {
  const SewerPlant({required this.position, required this.coverage});

  final WorldPosition position;
  final int coverage;
}

class WaterGridState {
  const WaterGridState({
    required this.suppliedTiles,
    required this.totalCapacity,
    required this.totalDemand,
    required this.sewageCoverage,
  });

  final Set<WorldPosition> suppliedTiles;
  final int totalCapacity;
  final int totalDemand;
  final Set<WorldPosition> sewageCoverage;

  bool get hasShortage => totalDemand > totalCapacity;
  bool isSewaged(WorldPosition pos) => sewageCoverage.contains(pos);
  bool isSupplied(WorldPosition pos) => suppliedTiles.contains(pos);
}

class WaterGridSystem {
  WaterGridState calculate({
    required List<WaterSource> sources,
    required List<WaterPipe> pipes,
    required List<SewerPlant> sewerPlants,
    required Map<WorldPosition, int> demandMap,
  }) {
    final sewage = _calculateSewageCoverage(sewerPlants);

    if (sources.isEmpty) {
      return WaterGridState(
        suppliedTiles: const <WorldPosition>{},
        totalCapacity: 0,
        totalDemand: 0,
        sewageCoverage: sewage,
      );
    }

    final adjacency = _buildAdjacency(pipes);
    final supplied = <WorldPosition>{};

    for (final source in sources) {
      _floodFill(source.position, adjacency, supplied);
    }

    final capacity = sources.fold(0, (sum, s) => sum + s.capacity);
    final demand = demandMap.values.fold(0, (sum, d) => sum + d);

    return WaterGridState(
      suppliedTiles: supplied,
      totalCapacity: capacity,
      totalDemand: demand,
      sewageCoverage: sewage,
    );
  }

  Map<WorldPosition, Set<WorldPosition>> _buildAdjacency(List<WaterPipe> pipes) {
    final adj = <WorldPosition, Set<WorldPosition>>{};
    for (final pipe in pipes) {
      adj.putIfAbsent(pipe.from, () => {}).add(pipe.to);
      adj.putIfAbsent(pipe.to, () => {}).add(pipe.from);
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
      for (final n in adjacency[current] ?? {}) {
        if (!visited.contains(n)) queue.add(n);
      }
    }
  }

  Set<WorldPosition> _calculateSewageCoverage(List<SewerPlant> plants) {
    final covered = <WorldPosition>{};
    for (final plant in plants) {
      for (var dc = -plant.coverage; dc <= plant.coverage; dc++) {
        for (var dr = -plant.coverage; dr <= plant.coverage; dr++) {
          covered.add((col: plant.position.col + dc, row: plant.position.row + dr));
        }
      }
    }
    return covered;
  }
}
