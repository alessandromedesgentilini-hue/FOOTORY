class WorldTournamentResult {
  final String competitionId;
  final String competitionName;
  final int seasonYear;
  final String championClubId;
  final String runnerUpClubId;

  const WorldTournamentResult({
    required this.competitionId,
    required this.competitionName,
    required this.seasonYear,
    required this.championClubId,
    required this.runnerUpClubId,
  });

  Map<String, dynamic> toJson() {
    return {
      'competitionId': competitionId,
      'competitionName': competitionName,
      'seasonYear': seasonYear,
      'championClubId': championClubId,
      'runnerUpClubId': runnerUpClubId,
    };
  }

  factory WorldTournamentResult.fromJson(Map<String, dynamic> json) {
    return WorldTournamentResult(
      competitionId: json['competitionId'] as String? ?? '',
      competitionName: json['competitionName'] as String? ?? '',
      seasonYear: (json['seasonYear'] as num?)?.toInt() ?? 2026,
      championClubId: json['championClubId'] as String? ?? '',
      runnerUpClubId: json['runnerUpClubId'] as String? ?? '',
    );
  }
}
