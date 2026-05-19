enum SpaceMissionType {
  rareEarthMining,
  satelliteNetwork,
  colonySurvey;

  Duration get duration => switch (this) {
        SpaceMissionType.rareEarthMining => const Duration(seconds: 120),
        SpaceMissionType.satelliteNetwork => const Duration(seconds: 60),
        SpaceMissionType.colonySurvey => const Duration(seconds: 240),
      };

  double get cost => switch (this) {
        SpaceMissionType.rareEarthMining => 50000,
        SpaceMissionType.satelliteNetwork => 20000,
        SpaceMissionType.colonySurvey => 100000,
      };

  double get rareEarthYield => switch (this) {
        SpaceMissionType.rareEarthMining => 500,
        SpaceMissionType.satelliteNetwork => 0,
        SpaceMissionType.colonySurvey => 100,
      };
}

class SpaceMission {
  SpaceMission({
    required this.type,
    required this.startedAtTick,
    required this.durationTicks,
  });

  final SpaceMissionType type;
  final int startedAtTick;
  final int durationTicks;

  bool isComplete(int currentTick) => currentTick - startedAtTick >= durationTicks;
}

class SpacePhaseState {
  SpacePhaseState({
    this.spacePhaseActive = false,
    this.rareEarthStockpile = 0.0,
    List<SpaceMission>? activeMissions,
    this.colonyPopulation = 0,
  }) : activeMissions = activeMissions ?? [];

  bool spacePhaseActive;
  double rareEarthStockpile;
  final List<SpaceMission> activeMissions;
  int colonyPopulation;
}

const int kSpacePhaseMinPopulation = 500000;

class SpaceSystem {
  const SpaceSystem();

  bool checkSpaceTrigger({
    required int population,
    required bool spaceportBuilt,
    required bool spaceportResearched,
  }) =>
      population >= kSpacePhaseMinPopulation &&
      spaceportBuilt &&
      spaceportResearched;

  SpacePhaseState tick({
    required SpacePhaseState state,
    required int currentTick,
  }) {
    if (!state.spacePhaseActive) return state;

    final completed = state.activeMissions.where((m) => m.isComplete(currentTick)).toList();
    for (final mission in completed) {
      state.rareEarthStockpile += mission.type.rareEarthYield;
    }
    state.activeMissions.removeWhere((m) => m.isComplete(currentTick));

    return state;
  }

  double hightechDemandBonus({required double rareEarth}) =>
      (rareEarth / 1000).clamp(0, 2.0);
}
