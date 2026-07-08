class CupFixture {
  final String id;
  final String competitionId;
  final int seasonYear;

  final int phase;
  final String phaseLabel;

  final int leg;
  final String homeClubId;
  final String awayClubId;

  final DateTime date;

  final int? homeGoals;
  final int? awayGoals;

  final bool resolved;
  final String? winnerClubId;

  const CupFixture({
    required this.id,
    required this.competitionId,
    required this.seasonYear,
    required this.phase,
    required this.phaseLabel,
    required this.leg,
    required this.homeClubId,
    required this.awayClubId,
    required this.date,
    this.homeGoals,
    this.awayGoals,
    this.resolved = false,
    this.winnerClubId,
  });

  bool get isFirstLeg => leg == 1;
  bool get isSecondLeg => leg == 2;
  bool get isPlayed => homeGoals != null && awayGoals != null;

  CupFixture copyWith({
    String? id,
    String? competitionId,
    int? seasonYear,
    int? phase,
    String? phaseLabel,
    int? leg,
    String? homeClubId,
    String? awayClubId,
    DateTime? date,
    int? homeGoals,
    int? awayGoals,
    bool? resolved,
    String? winnerClubId,
  }) {
    return CupFixture(
      id: id ?? this.id,
      competitionId: competitionId ?? this.competitionId,
      seasonYear: seasonYear ?? this.seasonYear,
      phase: phase ?? this.phase,
      phaseLabel: phaseLabel ?? this.phaseLabel,
      leg: leg ?? this.leg,
      homeClubId: homeClubId ?? this.homeClubId,
      awayClubId: awayClubId ?? this.awayClubId,
      date: date ?? this.date,
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
      resolved: resolved ?? this.resolved,
      winnerClubId: winnerClubId ?? this.winnerClubId,
    );
  }
}
