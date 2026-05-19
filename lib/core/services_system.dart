import 'package:city_builder/core/world_position.dart';

enum ServiceType {
  police,
  fire,
  hospital,
  school,
  university;

  int get defaultRadius => switch (this) {
        ServiceType.police => 8,
        ServiceType.fire => 10,
        ServiceType.hospital => 12,
        ServiceType.school => 6,
        ServiceType.university => 8,
      };

  double get educationBonus => switch (this) {
        ServiceType.school => 0.1,
        ServiceType.university => 0.3,
        _ => 0,
      };
}

class ServiceBuilding {
  const ServiceBuilding({
    required this.position,
    required this.type,
    this.active = true,
  });

  final WorldPosition position;
  final ServiceType type;
  final bool active;
}

class ServicesState {
  const ServicesState({
    required this.policeCoverage,
    required this.fireCoverage,
    required this.medicalCoverage,
    required this.educationIndex,
  });

  final Set<WorldPosition> policeCoverage;
  final Set<WorldPosition> fireCoverage;
  final Set<WorldPosition> medicalCoverage;
  final double educationIndex;

  bool hasPolice(WorldPosition pos) => policeCoverage.contains(pos);
  bool hasFire(WorldPosition pos) => fireCoverage.contains(pos);
  bool hasMedical(WorldPosition pos) => medicalCoverage.contains(pos);
}

ServicesState calculateServices({
  required List<ServiceBuilding> buildings,
}) {
  final police = <WorldPosition>{};
  final fire = <WorldPosition>{};
  final medical = <WorldPosition>{};
  var education = 0.0;

  for (final building in buildings) {
    if (!building.active) continue;
    final radius = building.type.defaultRadius;
    final covered = _coverageTiles(building.position, radius);

    switch (building.type) {
      case ServiceType.police:
        police.addAll(covered);
      case ServiceType.fire:
        fire.addAll(covered);
      case ServiceType.hospital:
        medical.addAll(covered);
      case ServiceType.school || ServiceType.university:
        education += building.type.educationBonus;
    }
  }

  return ServicesState(
    policeCoverage: police,
    fireCoverage: fire,
    medicalCoverage: medical,
    educationIndex: education.clamp(0, 1),
  );
}

Set<WorldPosition> _coverageTiles(WorldPosition center, int radius) {
  final tiles = <WorldPosition>{};
  for (var dc = -radius; dc <= radius; dc++) {
    for (var dr = -radius; dr <= radius; dr++) {
      if (dc * dc + dr * dr <= radius * radius) {
        tiles.add((col: center.col + dc, row: center.row + dr));
      }
    }
  }
  return tiles;
}

class PollutionSystem {
  PollutionSystem(this.mapWidth, this.mapHeight);

  final int mapWidth;
  final int mapHeight;

  Map<WorldPosition, double> calculate({
    required List<({WorldPosition position, double intensity, int radius})> sources,
  }) {
    final result = <WorldPosition, double>{};

    for (final source in sources) {
      for (var dc = -source.radius; dc <= source.radius; dc++) {
        for (var dr = -source.radius; dr <= source.radius; dr++) {
          final dist2 = dc * dc + dr * dr;
          if (dist2 > source.radius * source.radius) continue;

          final col = source.position.col + dc;
          final row = source.position.row + dr;
          if (col < 0 || row < 0 || col >= mapWidth || row >= mapHeight) continue;

          final pos = (col: col, row: row);
          final decay = 1.0 - (dist2 / (source.radius * source.radius));
          result[pos] = (result[pos] ?? 0) + source.intensity * decay;
        }
      }
    }

    return result;
  }
}

class CrimeSystem {
  CrimeSystem();

  Map<WorldPosition, double> calculate({
    required Map<WorldPosition, double> baseCrimeByZone,
    required Set<WorldPosition> policeCoverage,
    double policeReductionFactor = 0.6,
  }) {
    return {
      for (final entry in baseCrimeByZone.entries)
        entry.key: policeCoverage.contains(entry.key)
            ? entry.value * (1 - policeReductionFactor)
            : entry.value,
    };
  }
}
