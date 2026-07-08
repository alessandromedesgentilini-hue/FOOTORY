class SimonBolivarSeasonResult {
  final int seasonYear;
  final String championClubId;
  final String runnerUpClubId;
  final List<String> fallbackQualifiedClubIds;

  const SimonBolivarSeasonResult({
    required this.seasonYear,
    required this.championClubId,
    required this.runnerUpClubId,
    this.fallbackQualifiedClubIds = const [],
  });

  List<String> get qualificationOrder {
    return List.unmodifiable([
      championClubId,
      runnerUpClubId,
      ...fallbackQualifiedClubIds,
    ]);
  }

  Map<String, dynamic> toJson() {
    return {
      'seasonYear': seasonYear,
      'championClubId': championClubId,
      'runnerUpClubId': runnerUpClubId,
      'fallbackQualifiedClubIds': fallbackQualifiedClubIds,
    };
  }

  factory SimonBolivarSeasonResult.fromJson(Map<String, dynamic> json) {
    return SimonBolivarSeasonResult(
      seasonYear: (json['seasonYear'] as num?)?.toInt() ?? 2026,
      championClubId: json['championClubId'] as String? ?? '',
      runnerUpClubId: json['runnerUpClubId'] as String? ?? '',
      fallbackQualifiedClubIds: (json['fallbackQualifiedClubIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
