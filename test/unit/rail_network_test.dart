import 'package:city_builder/core/rail_network.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const network = RailNetwork();

  group('RailNetwork.findRoute', () {
    test('returns null when no path exists', () {
      final route = network.findRoute(
        from: (col: 0, row: 0),
        to: (col: 5, row: 5),
        segments: const [],
      );
      expect(route, isNull);
    });

    test('returns single-element path when from == to', () {
      final route = network.findRoute(
        from: (col: 3, row: 3),
        to: (col: 3, row: 3),
        segments: const [],
      );
      expect(route, [(col: 3, row: 3)]);
    });

    test('finds direct path through connected segments', () {
      final segments = [
        const RailSegment(from: (col: 0, row: 0), to: (col: 1, row: 0)),
        const RailSegment(from: (col: 1, row: 0), to: (col: 2, row: 0)),
      ];
      final route = network.findRoute(
        from: (col: 0, row: 0),
        to: (col: 2, row: 0),
        segments: segments,
      );
      expect(route, isNotNull);
      expect(route!.first, (col: 0, row: 0));
      expect(route.last, (col: 2, row: 0));
    });

    test('finds shortest path (Dijkstra)', () {
      final segments = [
        const RailSegment(from: (col: 0, row: 0), to: (col: 1, row: 0)),
        const RailSegment(from: (col: 1, row: 0), to: (col: 2, row: 0)),
        const RailSegment(from: (col: 0, row: 0), to: (col: 0, row: 1)),
        const RailSegment(from: (col: 0, row: 1), to: (col: 0, row: 2)),
        const RailSegment(from: (col: 0, row: 2), to: (col: 1, row: 2)),
        const RailSegment(from: (col: 1, row: 2), to: (col: 2, row: 2)),
        const RailSegment(from: (col: 2, row: 2), to: (col: 2, row: 0)),
      ];
      final route = network.findRoute(
        from: (col: 0, row: 0),
        to: (col: 2, row: 0),
        segments: segments,
      );
      expect(route, isNotNull);
      expect(route!.length, lessThanOrEqualTo(4));
    });

    test('route starts at from and ends at to', () {
      final segments = [
        const RailSegment(from: (col: 1, row: 0), to: (col: 2, row: 0)),
        const RailSegment(from: (col: 2, row: 0), to: (col: 3, row: 0)),
      ];
      final route = network.findRoute(
        from: (col: 1, row: 0),
        to: (col: 3, row: 0),
        segments: segments,
      );
      expect(route!.first, (col: 1, row: 0));
      expect(route.last, (col: 3, row: 0));
    });
  });
}
