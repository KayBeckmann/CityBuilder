class SatisfactionFactors {
  const SatisfactionFactors({
    this.employment = 0.5,
    this.housing = 0.5,
    this.services = 0.5,
  })  : assert(employment >= 0 && employment <= 1),
        assert(housing >= 0 && housing <= 1),
        assert(services >= 0 && services <= 1);

  final double employment;
  final double housing;
  final double services;

  SatisfactionFactors copyWith({
    double? employment,
    double? housing,
    double? services,
  }) =>
      SatisfactionFactors(
        employment: employment ?? this.employment,
        housing: housing ?? this.housing,
        services: services ?? this.services,
      );
}

double calculateSatisfaction(SatisfactionFactors factors) {
  const weights = (employment: 0.4, housing: 0.4, services: 0.2);
  return (factors.employment * weights.employment +
          factors.housing * weights.housing +
          factors.services * weights.services)
      .clamp(0, 1);
}

double calculateApprovalRating({
  required double residentSatisfaction,
  required double commercialSatisfaction,
  required double industrialSatisfaction,
}) {
  return (residentSatisfaction * 0.5 +
          commercialSatisfaction * 0.3 +
          industrialSatisfaction * 0.2)
      .clamp(0, 1);
}
