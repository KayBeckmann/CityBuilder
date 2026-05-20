import 'package:city_builder/core/building_level.dart';
import 'package:city_builder/core/map_generator.dart';
import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/zone_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const generator = MapGenerator();

  group('TileMap infrastructure', () {
    late TileMap map;

    setUp(() {
      map = generator.generate(seed: 0, size: MapSize.small);
    });

    test('setRoad marks tile as having road', () {
      const pos = (col: 5, row: 5);
      expect(map.getData(pos).hasRoad, isFalse);
      map.setRoad(pos);
      expect(map.getData(pos).hasRoad, isTrue);
    });

    test('setPowerLine marks tile correctly', () {
      const pos = (col: 5, row: 5);
      map.setPowerLine(pos);
      expect(map.getData(pos).hasPowerLine, isTrue);
    });

    test('setPipe marks tile correctly', () {
      const pos = (col: 5, row: 5);
      map.setPipe(pos);
      expect(map.getData(pos).hasPipe, isTrue);
    });

    test('clearAll removes zone, buildings and all infrastructure', () {
      const pos = (col: 5, row: 5);
      map.setZone(pos, ZoneType.residential);
      map.setBuildingLevel(pos, BuildingLevel.large);
      map.setRoad(pos);
      map.setPowerLine(pos);
      map.setPipe(pos);
      map.clearAll(pos);
      final d = map.getData(pos);
      expect(d.zone, isNull);
      expect(d.buildingLevel, BuildingLevel.empty);
      expect(d.hasRoad, isFalse);
      expect(d.hasPowerLine, isFalse);
      expect(d.hasPipe, isFalse);
    });
  });

  group('PowerGrid flood-fill', () {
    late TileMap map;

    setUp(() {
      map = TileMap(width: 10, height: 10);
    });

    test('no power plant → empty powered set', () {
      map.setPowerLine((col: 0, row: 0));
      expect(map.computePoweredTiles(), isEmpty);
    });

    test('power plant alone powers its own tile', () {
      map.setPowerPlant((col: 5, row: 5));
      final powered = map.computePoweredTiles();
      expect(powered, contains((col: 5, row: 5)));
    });

    test('power spreads through adjacent power lines', () {
      // Plant at (0,0), line at (1,0), (2,0)
      map.setPowerPlant((col: 0, row: 0));
      map.setPowerLine((col: 1, row: 0));
      map.setPowerLine((col: 2, row: 0));
      final powered = map.computePoweredTiles();
      expect(powered, contains((col: 0, row: 0)));
      expect(powered, contains((col: 1, row: 0)));
      expect(powered, contains((col: 2, row: 0)));
    });

    test('disconnected power line not powered', () {
      map.setPowerPlant((col: 0, row: 0));
      map.setPowerLine((col: 1, row: 0));
      // Gap at (2,0), line at (3,0) — not connected
      map.setPowerLine((col: 3, row: 0));
      final powered = map.computePoweredTiles();
      expect(powered, contains((col: 1, row: 0)));
      expect(powered, isNot(contains((col: 3, row: 0))));
    });
  });

  group('WaterGrid flood-fill', () {
    late TileMap map;

    setUp(() {
      map = TileMap(width: 10, height: 10);
    });

    test('no water tower → empty watered set', () {
      map.setPipe((col: 0, row: 0));
      expect(map.computeWateredTiles(), isEmpty);
    });

    test('water tower spreads through adjacent pipes', () {
      map.setWaterTower((col: 0, row: 0));
      map.setPipe((col: 0, row: 1));
      map.setPipe((col: 0, row: 2));
      final watered = map.computeWateredTiles();
      expect(watered, contains((col: 0, row: 0)));
      expect(watered, contains((col: 0, row: 1)));
      expect(watered, contains((col: 0, row: 2)));
    });

    test('tile without pipe not watered even if near tower', () {
      map.setWaterTower((col: 0, row: 0));
      // (1,0) has no pipe — should not be watered
      expect(map.computeWateredTiles(), isNot(contains((col: 1, row: 0))));
    });
  });
}
