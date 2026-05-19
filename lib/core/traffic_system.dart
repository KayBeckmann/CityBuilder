import 'package:city_builder/core/world_position.dart';

class Road {
  const Road({required this.position, this.capacity = 100});

  final WorldPosition position;
  final int capacity;
}

class TrafficLoad {
  const TrafficLoad({required this.position, required this.load});

  final WorldPosition position;
  final int load;

  bool get isCongested => load > capacity;
  int get capacity => 100;
  double get congestionFactor => (load / capacity).clamp(0, 2);
}

class TrafficState {
  const TrafficState({required this.loads});

  final Map<WorldPosition, TrafficLoad> loads;

  TrafficLoad? loadAt(WorldPosition pos) => loads[pos];

  bool isCongested(WorldPosition pos) => loads[pos]?.isCongested ?? false;

  double satisfactionMalus(WorldPosition pos, {int radius = 3}) {
    var total = 0.0;
    var count = 0;
    for (final entry in loads.entries) {
      final dx = (entry.key.col - pos.col).abs();
      final dy = (entry.key.row - pos.row).abs();
      if (dx <= radius && dy <= radius) {
        total += entry.value.congestionFactor;
        count++;
      }
    }
    if (count == 0) return 0;
    return ((total / count) - 1).clamp(0, 1);
  }
}

class TrafficSystem {
  TrafficState calculate({
    required List<Road> roads,
    required Map<WorldPosition, int> zoneDensity,
    required Set<WorldPosition> connectedZones,
  }) {
    final loads = <WorldPosition, TrafficLoad>{};

    for (final road in roads) {
      final nearby = _sumNearbyDensity(road.position, zoneDensity);
      loads[road.position] = TrafficLoad(
        position: road.position,
        load: nearby,
      );
    }

    return TrafficState(loads: loads);
  }

  int _sumNearbyDensity(WorldPosition pos, Map<WorldPosition, int> density) {
    var total = 0;
    const radius = 3;
    for (final entry in density.entries) {
      final dx = (entry.key.col - pos.col).abs();
      final dy = (entry.key.row - pos.row).abs();
      if (dx <= radius && dy <= radius) {
        total += entry.value;
      }
    }
    return total;
  }
}
