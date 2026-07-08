class AtlasClubFixture {
  final String id;
  final int seasonYear;
  final String stage;

  final String homeClubId;
  final String awayClubId;

  final int? homeGoals;
  final int? awayGoals;

  final String? winnerClubId;

  const AtlasClubFixture({
    required this.id,
    required this.seasonYear,
    required this.stage,
    required this.homeClubId,
    required this.awayClubId,
    this.homeGoals,
    this.awayGoals,
    this.winnerClubId,
  });

  bool get isPlayed => winnerClubId != null;

  AtlasClubFixture copyWith({
    int? homeGoals,
    int? awayGoals,
    String? winnerClubId,
  }) {
    return AtlasClubFixture(
      id: id,
      seasonYear: seasonYear,
      stage: stage,
      homeClubId: homeClubId,
      awayClubId: awayClubId,
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
      winnerClubId: winnerClubId ?? this.winnerClubId,
    );
  }
}
