import 'package:city_builder/core/world_position.dart';
import 'package:collection/collection.dart';

class RailSegment {
  const RailSegment({required this.from, required this.to});

  final WorldPosition from;
  final WorldPosition to;
}

class Station {
  const Station({required this.position, required this.name, this.isFreight = false});

  final WorldPosition position;
  final String name;
  final bool isFreight;
}

class Train {
  Train({
    required this.id,
    required this.route,
    required this.capacity,
    this.currentIndex = 0,
    this.cargoType,
    this.cargoAmount = 0,
  });

  final int id;
  final List<WorldPosition> route;
  final int capacity;
  int currentIndex;
  String? cargoType;
  int cargoAmount;

  WorldPosition get currentPosition => route[currentIndex];

  void advanceStep() {
    currentIndex = (currentIndex + 1) % route.length;
  }
}

class RailNetwork {
  const RailNetwork();

  List<WorldPosition>? findRoute({
    required WorldPosition from,
    required WorldPosition to,
    required List<RailSegment> segments,
  }) {
    if (from == to) return [from];

    final adj = _buildAdjacency(segments);
    final dist = <WorldPosition, int>{from: 0};
    final prev = <WorldPosition, WorldPosition>{};
    final queue = PriorityQueue<(int, WorldPosition)>((a, b) => a.$1.compareTo(b.$1));

    queue.add((0, from));

    while (queue.isNotEmpty) {
      final (cost, current) = queue.removeFirst();
      if (current == to) break;
      if (cost > (dist[current] ?? 999999)) continue;

      for (final neighbor in adj[current] ?? <WorldPosition>[]) {
        final newCost = cost + 1;
        if (newCost < (dist[neighbor] ?? 999999)) {
          dist[neighbor] = newCost;
          prev[neighbor] = current;
          queue.add((newCost, neighbor));
        }
      }
    }

    if (!prev.containsKey(to) && from != to) return null;

    final path = <WorldPosition>[];
    var current = to;
    while (current != from) {
      path.add(current);
      current = prev[current]!;
    }
    path.add(from);
    return path.reversed.toList();
  }

  Map<WorldPosition, List<WorldPosition>> _buildAdjacency(List<RailSegment> segments) {
    final adj = <WorldPosition, List<WorldPosition>>{};
    for (final seg in segments) {
      adj.putIfAbsent(seg.from, () => []).add(seg.to);
      adj.putIfAbsent(seg.to, () => []).add(seg.from);
    }
    return adj;
  }

  int freightCapacityReduction({
    required Station station,
    required int roadCapacityAtStation,
    int reductionPerTrain = 20,
  }) {
    return reductionPerTrain.clamp(0, roadCapacityAtStation);
  }
}
