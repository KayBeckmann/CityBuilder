import 'package:city_builder/core/zone_type.dart';

class DemandCurve {
  const DemandCurve({
    required this.residential,
    required this.commercial,
    required this.industrial,
  });

  final double residential;
  final double commercial;
  final double industrial;

  double forZone(ZoneType zone) => switch (zone) {
        ZoneType.residential => residential,
        ZoneType.commercial => commercial,
        ZoneType.industrial => industrial,
      };

  @override
  String toString() =>
      'DemandCurve(R=$residential, C=$commercial, I=$industrial)';
}

class DemandSystem {
  const DemandSystem();

  DemandCurve calculate({
    required int population,
    required int commercialBuildings,
    required int industrialBuildings,
  }) {
    if (population == 0) {
      // Allow initial residential growth even without existing population
      return const DemandCurve(residential: 1.0, commercial: 0, industrial: 0);
    }

    const baseResidential = 1.0;
    final commercialRatio = population > 0 ? commercialBuildings / population : 0.0;
    final industrialRatio = population > 0 ? industrialBuildings / population : 0.0;

    final residentialDemand = baseResidential * (1.0 + population / 1000.0);
    final commercialDemand = (residentialDemand * 0.4) * (1.0 - commercialRatio * 2).clamp(0, 1);
    final industrialDemand = (residentialDemand * 0.3) * (1.0 - industrialRatio * 3).clamp(0, 1);

    return DemandCurve(
      residential: residentialDemand.clamp(0, 10),
      commercial: commercialDemand.clamp(0, 10),
      industrial: industrialDemand.clamp(0, 10),
    );
  }
}
