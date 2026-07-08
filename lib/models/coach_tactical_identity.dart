class CoachTacticalIdentity {
  final String id;

  final String name;

  final String shortDescription;
  final String philosophyDescription;

  final String mainFormation;

  final List<String> secondaryFormations;

  final double pressureBias;
  final double possessionBias;
  final double transitionBias;
  final double setPieceBias;

  const CoachTacticalIdentity({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.philosophyDescription,
    required this.mainFormation,
    required this.secondaryFormations,
    required this.pressureBias,
    required this.possessionBias,
    required this.transitionBias,
    required this.setPieceBias,
  });

  bool get isHighPressure => pressureBias >= 0.75;

  bool get isPossessionStyle => possessionBias >= 0.75;
}
