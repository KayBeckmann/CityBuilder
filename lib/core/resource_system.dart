import 'package:city_builder/core/resource_type.dart';
import 'package:city_builder/core/world_position.dart';
import 'package:flutter/material.dart';

enum ExtractionBuildingType {
  mine,
  sawmill,
  oilPump,
  quarry;

  ResourceType get primaryResource => switch (this) {
        ExtractionBuildingType.mine => ResourceType.iron,
        ExtractionBuildingType.sawmill => ResourceType.wood,
        ExtractionBuildingType.oilPump => ResourceType.oil,
        ExtractionBuildingType.quarry => ResourceType.stone,
      };

  int get outputPerTick => switch (this) {
        ExtractionBuildingType.mine => 5,
        ExtractionBuildingType.sawmill => 8,
        ExtractionBuildingType.oilPump => 3,
        ExtractionBuildingType.quarry => 6,
      };

  double get pollutionRadius => switch (this) {
        ExtractionBuildingType.mine => 4.0,
        ExtractionBuildingType.sawmill => 2.0,
        ExtractionBuildingType.oilPump => 5.0,
        ExtractionBuildingType.quarry => 3.0,
      };

  Color get fallbackColor => switch (this) {
        ExtractionBuildingType.mine => const Color(0xFF8D6E63),
        ExtractionBuildingType.sawmill => const Color(0xFF558B2F),
        ExtractionBuildingType.oilPump => const Color(0xFF37474F),
        ExtractionBuildingType.quarry => const Color(0xFF78909C),
      };
}

class ResourceDeposit {
  ResourceDeposit({
    required this.position,
    required this.type,
    required this.remaining,
  });

  final WorldPosition position;
  final ResourceType type;
  int remaining;

  bool get isExhausted => remaining <= 0;
}

class ExtractionBuilding {
  const ExtractionBuilding({
    required this.position,
    required this.type,
    this.active = true,
  });

  final WorldPosition position;
  final ExtractionBuildingType type;
  final bool active;
}

class ProcessingResult {
  const ProcessingResult({
    required this.outputType,
    required this.amount,
  });

  final ResourceType outputType;
  final int amount;
}

class ResourceInventory {
  ResourceInventory([Map<ResourceType, int>? initial])
      : _stock = Map.of(initial ?? {});

  final Map<ResourceType, int> _stock;

  int get(ResourceType type) => _stock[type] ?? 0;

  void add(ResourceType type, int amount) {
    _stock[type] = (_stock[type] ?? 0) + amount;
  }

  bool consume(ResourceType type, int amount) {
    final current = _stock[type] ?? 0;
    if (current < amount) return false;
    _stock[type] = current - amount;
    return true;
  }

  Map<ResourceType, int> get snapshot => Map.unmodifiable(_stock);
}

const Map<ResourceType, (ResourceType output, int ratio)> processingChain = {
  ResourceType.iron: (ResourceType.coal, 2),
};

class ResourceSystem {
  ResourceExtractionResult tick({
    required List<ExtractionBuilding> buildings,
    required List<ResourceDeposit> deposits,
    required ResourceInventory inventory,
    required Map<ResourceType, double> marketPrices,
  }) {
    var exportRevenue = 0.0;
    final depositMap = {for (final d in deposits) d.position: d};

    for (final building in buildings) {
      if (!building.active) continue;
      final deposit = depositMap[building.position];
      if (deposit == null || deposit.isExhausted) continue;

      final output = building.type.outputPerTick;
      final actual = output.clamp(0, deposit.remaining);
      deposit.remaining -= actual;
      inventory.add(deposit.type, actual);
    }

    for (final resource in ResourceType.values) {
      final surplus = inventory.get(resource);
      if (surplus > 0) {
        final price = marketPrices[resource] ?? 10.0;
        exportRevenue += surplus * price;
        inventory.consume(resource, surplus);
      }
    }

    return ResourceExtractionResult(exportRevenue: exportRevenue);
  }
}

class ResourceExtractionResult {
  const ResourceExtractionResult({required this.exportRevenue});

  final double exportRevenue;
}
