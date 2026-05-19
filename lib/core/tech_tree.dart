enum TechNode {
  solarPower,
  asphaltRoads,
  school,
  nuclearPower,
  university,
  railSignaling,
  spaceportPrep,
  hightechIndustry,
  subway;

  Set<TechNode> get dependencies => switch (this) {
        TechNode.solarPower => const {},
        TechNode.asphaltRoads => const {},
        TechNode.school => const {},
        TechNode.nuclearPower => {TechNode.solarPower, TechNode.school},
        TechNode.university => {TechNode.school},
        TechNode.railSignaling => {TechNode.asphaltRoads},
        TechNode.spaceportPrep => {TechNode.nuclearPower, TechNode.university},
        TechNode.hightechIndustry => {TechNode.university},
        TechNode.subway => {TechNode.railSignaling, TechNode.university},
      };

  int get researchCost => switch (this) {
        TechNode.solarPower => 500,
        TechNode.asphaltRoads => 300,
        TechNode.school => 400,
        TechNode.nuclearPower => 2000,
        TechNode.university => 1000,
        TechNode.railSignaling => 800,
        TechNode.spaceportPrep => 5000,
        TechNode.hightechIndustry => 1500,
        TechNode.subway => 3000,
      };

  int get minPopulation => switch (this) {
        TechNode.solarPower => 0,
        TechNode.asphaltRoads => 0,
        TechNode.school => 100,
        TechNode.nuclearPower => 5000,
        TechNode.university => 1000,
        TechNode.railSignaling => 500,
        TechNode.spaceportPrep => 50000,
        TechNode.hightechIndustry => 2000,
        TechNode.subway => 10000,
      };
}

class TechTreeState {
  TechTreeState({
    Set<TechNode>? researched,
    Map<TechNode, double>? progress,
    this.researchPoints = 0,
  })  : researched = researched ?? {},
        progress = progress ?? {};

  final Set<TechNode> researched;
  final Map<TechNode, double> progress;
  double researchPoints;

  bool isResearched(TechNode node) => researched.contains(node);

  bool canResearch(TechNode node, int population) {
    if (isResearched(node)) return false;
    if (population < node.minPopulation) return false;
    return node.dependencies.every(isResearched);
  }

  bool startResearch(TechNode node, int population) {
    if (!canResearch(node, population)) return false;
    if (!progress.containsKey(node)) {
      progress[node] = 0;
    }
    return true;
  }

  void tickResearch(double pointsGenerated) {
    researchPoints += pointsGenerated;
    final inProgress = progress.keys.toList();
    for (final node in inProgress) {
      final cost = node.researchCost.toDouble();
      final current = progress[node]!;
      if (current + researchPoints >= cost) {
        researchPoints -= (cost - current);
        progress.remove(node);
        researched.add(node);
      } else {
        progress[node] = current + researchPoints;
        researchPoints = 0;
        break;
      }
    }
  }

  double researchPointsGenerated({
    required double educationIndex,
    required int universityCount,
  }) =>
      educationIndex * (1 + universityCount * 0.5);
}
