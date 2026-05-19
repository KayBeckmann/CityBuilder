import 'package:city_builder/core/tile_map.dart';
import 'package:city_builder/core/zone_type.dart';

class TaxRates {
  const TaxRates({
    this.residential = 0.08,
    this.commercial = 0.10,
    this.industrial = 0.12,
  })  : assert(residential >= 0 && residential <= 1),
        assert(commercial >= 0 && commercial <= 1),
        assert(industrial >= 0 && industrial <= 1);

  final double residential;
  final double commercial;
  final double industrial;

  double forZone(ZoneType zone) => switch (zone) {
        ZoneType.residential => residential,
        ZoneType.commercial => commercial,
        ZoneType.industrial => industrial,
      };

  TaxRates copyWith({
    double? residential,
    double? commercial,
    double? industrial,
  }) =>
      TaxRates(
        residential: residential ?? this.residential,
        commercial: commercial ?? this.commercial,
        industrial: industrial ?? this.industrial,
      );
}

class EconomyResult {
  const EconomyResult({
    required this.taxIncome,
    required this.operatingCosts,
  });

  final double taxIncome;
  final double operatingCosts;
  double get netBalance => taxIncome - operatingCosts;
}

const double _baseIncomePerCapacity = 5.0;

EconomyResult calculateEconomy({
  required TileMap tileMap,
  required TaxRates taxRates,
}) {
  double taxIncome = 0;
  double operatingCosts = 0;

  for (var row = 0; row < tileMap.height; row++) {
    for (var col = 0; col < tileMap.width; col++) {
      final pos = (col: col, row: row);
      final data = tileMap.getData(pos);
      final zone = data.zone;
      final level = data.buildingLevel;

      if (zone != null && level.hasBuilding) {
        final rate = taxRates.forZone(zone);
        taxIncome += level.capacity * _baseIncomePerCapacity * rate;
        operatingCosts += level.operatingCost;
      }
    }
  }

  return EconomyResult(taxIncome: taxIncome, operatingCosts: operatingCosts);
}
