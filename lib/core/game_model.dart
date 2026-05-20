import 'package:city_builder/core/economy.dart';
import 'package:city_builder/core/population_model.dart';
import 'package:city_builder/core/satisfaction_system.dart';
import 'package:city_builder/core/tile_map.dart';

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
      );
}
