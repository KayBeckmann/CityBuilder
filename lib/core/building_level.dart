enum BuildingLevel {
  empty,
  small,
  medium,
  large;

  bool get hasBuilding => this != BuildingLevel.empty;

  String get label => switch (this) {
        BuildingLevel.empty => 'Leer',
        BuildingLevel.small => 'Klein',
        BuildingLevel.medium => 'Mittel',
        BuildingLevel.large => 'Groß',
      };

  double get operatingCost => switch (this) {
        BuildingLevel.empty => 0,
        BuildingLevel.small => 10,
        BuildingLevel.medium => 25,
        BuildingLevel.large => 60,
      };

  int get capacity => switch (this) {
        BuildingLevel.empty => 0,
        BuildingLevel.small => 10,
        BuildingLevel.medium => 50,
        BuildingLevel.large => 200,
      };

  BuildingLevel get next => switch (this) {
        BuildingLevel.empty => BuildingLevel.small,
        BuildingLevel.small => BuildingLevel.medium,
        BuildingLevel.medium => BuildingLevel.large,
        BuildingLevel.large => BuildingLevel.large,
      };
}
