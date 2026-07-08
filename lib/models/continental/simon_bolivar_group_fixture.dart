class SimonBolivarGroupFixture {
  final String id;
  final String competitionId;
  final int seasonYear;

  final String groupId;
  final int round;

  final String homeClubId;
  final String awayClubId;

  final DateTime date;

  final int? homeGoals;
  final int? awayGoals;

  const SimonBolivarGroupFixture({
    required this.id,
    required this.competitionId,
    required this.seasonYear,
    required this.groupId,
    required this.round,
    required this.homeClubId,
    required this.awayClubId,
    required this.date,
    this.homeGoals,
    this.awayGoals,
  });

  bool get isPlayed => homeGoals != null && awayGoals != null;

  SimonBolivarGroupFixture copyWith({
    String? id,
    String? competitionId,
    int? seasonYear,
    String? groupId,
    int? round,
    String? homeClubId,
    String? awayClubId,
    DateTime? date,
    int? homeGoals,
    int? awayGoals,
  }) {
    return SimonBolivarGroupFixture(
      id: id ?? this.id,
      competitionId: competitionId ?? this.competitionId,
      seasonYear: seasonYear ?? this.seasonYear,
      groupId: groupId ?? this.groupId,
      round: round ?? this.round,
      homeClubId: homeClubId ?? this.homeClubId,
      awayClubId: awayClubId ?? this.awayClubId,
      date: date ?? this.date,
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
    );
  }
}
