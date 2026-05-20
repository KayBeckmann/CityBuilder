import 'package:city_builder/core/economy.dart';
import 'package:city_builder/core/population_model.dart';
import 'package:city_builder/core/satisfaction_system.dart';
import 'package:city_builder/core/tile_map.dart';

class InfraStats {
  const InfraStats({
    this.buildings = 0,
    this.roadPct = 0,
    this.powerPct = 0,
    this.waterPct = 0,
    this.parks = 0,
    this.policeStations = 0,
    this.hospitals = 0,
    this.schools = 0,
  });

  final int buildings;
  final int roadPct;
  final int powerPct;
  final int waterPct;
  final int parks;
  final int policeStations;
  final int hospitals;
  final int schools;
}

class GameModel {
  const GameModel({
    required this.tileMap,
    required this.budget,
    required this.tick,
    this.taxRates = const TaxRates(),
    this.lastEconomy = const EconomyResult(taxIncome: 0, operatingCosts: 0),
    this.population = const PopulationStats(total: 0, capacity: 0, history: []),
    this.satisfaction = const SatisfactionFactors(),
    this.approvalRating = 0.5,
    this.loan = 0.0,
    this.infraStats = const InfraStats(),
    this.budgetHistory = const [],
    this.cityName = 'Neustadt',
  });

  final TileMap tileMap;
  final double budget;
  final int tick;
  final TaxRates taxRates;
  final EconomyResult lastEconomy;
  final PopulationStats population;
  final SatisfactionFactors satisfaction;
  final double approvalRating;
  final double loan;
  final InfraStats infraStats;
  final List<double> budgetHistory;
  final String cityName;

  static const int ticksPerYear = 20;

  int get year => (tick / ticksPerYear).floor() + 1;

  static const double loanInterestRate = 0.005; // 0.5% per tick
  static const double maxLoan = 50000.0;
  static const double loanChunkSize = 10000.0;

  static const double startingBudget = 100000.0;
  static const double gameOverBudgetThreshold = -5000.0;
  static const double gameOverApprovalThreshold = 0.15;

  bool get isBankrupt => budget < gameOverBudgetThreshold;
  bool get isApprovalTooLow =>
      tick > 20 && approvalRating < gameOverApprovalThreshold;
  bool get isGameOver => isBankrupt || isApprovalTooLow;

  GameModel copyWith({
    TileMap? tileMap,
    double? budget,
    int? tick,
    TaxRates? taxRates,
    EconomyResult? lastEconomy,
    PopulationStats? population,
    SatisfactionFactors? satisfaction,
    double? approvalRating,
    double? loan,
    InfraStats? infraStats,
    List<double>? budgetHistory,
    String? cityName,
  }) =>
      GameModel(
        tileMap: tileMap ?? this.tileMap,
        budget: budget ?? this.budget,
        tick: tick ?? this.tick,
        taxRates: taxRates ?? this.taxRates,
        lastEconomy: lastEconomy ?? this.lastEconomy,
        population: population ?? this.population,
        satisfaction: satisfaction ?? this.satisfaction,
        approvalRating: approvalRating ?? this.approvalRating,
        loan: loan ?? this.loan,
        infraStats: infraStats ?? this.infraStats,
        budgetHistory: budgetHistory ?? this.budgetHistory,
        cityName: cityName ?? this.cityName,
      );
}
