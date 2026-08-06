class DirectorCareer {
  final DirectorSeasonStats activeSeason;
  final List<DirectorSeasonStats> seasonHistory;
  final List<DirectorClubSpell> clubSpells;
  final List<DirectorTrophy> trophies;

  const DirectorCareer({
    required this.activeSeason,
    this.seasonHistory = const <DirectorSeasonStats>[],
    this.clubSpells = const <DirectorClubSpell>[],
    this.trophies = const <DirectorTrophy>[],
  });

  factory DirectorCareer.initial({
    required int seasonYear,
    required String clubId,
    required String clubName,
  }) {
    return DirectorCareer(
      activeSeason: DirectorSeasonStats(
        seasonYear: seasonYear,
        clubId: clubId,
        clubName: clubName,
      ),
    );
  }

  int get totalMatches {
    var total = activeSeason.matches;

    for (final season in seasonHistory) {
      total += season.matches;
    }

    return total;
  }

  int get totalWins {
    var total = activeSeason.wins;

    for (final season in seasonHistory) {
      total += season.wins;
    }

    return total;
  }

  int get totalDraws {
    var total = activeSeason.draws;

    for (final season in seasonHistory) {
      total += season.draws;
    }

    return total;
  }

  int get totalLosses {
    var total = activeSeason.losses;

    for (final season in seasonHistory) {
      total += season.losses;
    }

    return total;
  }

  int get completedSeasons => seasonHistory.length;

  int get totalCareerSeasons {
    if (activeSeason.matches > 0) {
      return seasonHistory.length + 1;
    }

    return seasonHistory.length;
  }

  int get totalPoints {
    return (totalWins * 3) + totalDraws;
  }

  double get overallPerformancePercentage {
    if (totalMatches <= 0) return 0;

    final possiblePoints = totalMatches * 3;

    return (totalPoints / possiblePoints) * 100;
  }

  DirectorCareer registerMatch({
    required int goalsFor,
    required int goalsAgainst,
  }) {
    return copyWith(
      activeSeason: activeSeason.registerMatch(
        goalsFor: goalsFor,
        goalsAgainst: goalsAgainst,
      ),
    );
  }

  DirectorCareer closeActiveSeason() {
    if (activeSeason.matches <= 0) {
      return this;
    }

    final alreadyRegistered = seasonHistory.any((season) {
      return season.seasonYear == activeSeason.seasonYear &&
          season.clubId == activeSeason.clubId;
    });

    if (alreadyRegistered) {
      return this;
    }

    return copyWith(
      seasonHistory: <DirectorSeasonStats>[
        ...seasonHistory,
        activeSeason,
      ],
    );
  }

  DirectorCareer startNewSeason({
    required int seasonYear,
    required String clubId,
    required String clubName,
  }) {
    final closedCareer = closeActiveSeason();

    return closedCareer.copyWith(
      activeSeason: DirectorSeasonStats(
        seasonYear: seasonYear,
        clubId: clubId,
        clubName: clubName,
      ),
    );
  }

  DirectorCareer registerTrophy({
    required String competitionId,
    required String competitionName,
    required int seasonYear,
    required String clubId,
    required String clubName,
  }) {
    final normalizedCompetitionId = competitionId.trim();
    final normalizedClubId = clubId.trim();

    if (normalizedCompetitionId.isEmpty || normalizedClubId.isEmpty) {
      return this;
    }

    final alreadyRegistered = trophies.any((trophy) {
      return trophy.competitionId == normalizedCompetitionId &&
          trophy.seasonYear == seasonYear &&
          trophy.clubId == normalizedClubId;
    });

    if (alreadyRegistered) {
      return this;
    }

    return copyWith(
      trophies: <DirectorTrophy>[
        ...trophies,
        DirectorTrophy(
          competitionId: normalizedCompetitionId,
          competitionName: competitionName.trim(),
          seasonYear: seasonYear,
          clubId: normalizedClubId,
          clubName: clubName.trim(),
        ),
      ],
    );
  }

  DirectorCareer openClubSpell({
    required String clubId,
    required String clubName,
    required int startYear,
  }) {
    final normalizedClubId = clubId.trim();

    if (normalizedClubId.isEmpty) {
      return this;
    }

    final hasOpenSpell = clubSpells.any((spell) => spell.isActive);

    if (hasOpenSpell) {
      return this;
    }

    return copyWith(
      clubSpells: <DirectorClubSpell>[
        ...clubSpells,
        DirectorClubSpell(
          clubId: normalizedClubId,
          clubName: clubName.trim(),
          startYear: startYear,
          boardPrestige: 1,
        ),
      ],
    );
  }

  DirectorCareer closeActiveClubSpell({
    required int endYear,
  }) {
    final index = clubSpells.lastIndexWhere((spell) => spell.isActive);

    if (index < 0) {
      return this;
    }

    final updatedSpells = List<DirectorClubSpell>.from(clubSpells);

    final currentSpell = updatedSpells[index];
    final spellStats = statsForClubSpell(currentSpell);

    updatedSpells[index] = currentSpell.copyWith(
      endYear: endYear,
      matches: spellStats.matches,
      wins: spellStats.wins,
      draws: spellStats.draws,
      losses: spellStats.losses,
      trophyCount: trophies.where((trophy) {
        return trophy.clubId == currentSpell.clubId &&
            trophy.seasonYear >= currentSpell.startYear &&
            trophy.seasonYear <= endYear;
      }).length,
    );

    return copyWith(
      clubSpells: updatedSpells,
    );
  }

  DirectorCareer updateActiveClubSpellBoardPrestige(
    int boardPrestige,
  ) {
    final index = clubSpells.lastIndexWhere((spell) => spell.isActive);

    if (index < 0) {
      return this;
    }

    final normalizedBoardPrestige = boardPrestige.clamp(1, 10).toInt();
    final currentSpell = clubSpells[index];

    if (currentSpell.boardPrestige == normalizedBoardPrestige) {
      return this;
    }

    final updatedSpells = List<DirectorClubSpell>.from(clubSpells);

    updatedSpells[index] = currentSpell.copyWith(
      boardPrestige: normalizedBoardPrestige,
    );

    return copyWith(
      clubSpells: updatedSpells,
    );
  }

  DirectorCareerStats statsForClubSpell(DirectorClubSpell spell) {
    var matches = 0;
    var wins = 0;
    var draws = 0;
    var losses = 0;

    final seasons = <DirectorSeasonStats>[
      ...seasonHistory,
      activeSeason,
    ];

    for (final season in seasons) {
      if (season.clubId != spell.clubId) continue;
      if (season.seasonYear < spell.startYear) continue;

      final endYear = spell.endYear;

      if (endYear != null && season.seasonYear > endYear) {
        continue;
      }

      matches += season.matches;
      wins += season.wins;
      draws += season.draws;
      losses += season.losses;
    }

    return DirectorCareerStats(
      matches: matches,
      wins: wins,
      draws: draws,
      losses: losses,
    );
  }

  DirectorCareerStats statsForClub(String clubId) {
    final normalizedClubId = clubId.trim();

    var matches = 0;
    var wins = 0;
    var draws = 0;
    var losses = 0;

    final seasons = <DirectorSeasonStats>[
      ...seasonHistory,
      activeSeason,
    ];

    for (final season in seasons) {
      if (season.clubId != normalizedClubId) continue;

      matches += season.matches;
      wins += season.wins;
      draws += season.draws;
      losses += season.losses;
    }

    return DirectorCareerStats(
      matches: matches,
      wins: wins,
      draws: draws,
      losses: losses,
    );
  }

  DirectorCareer copyWith({
    DirectorSeasonStats? activeSeason,
    List<DirectorSeasonStats>? seasonHistory,
    List<DirectorClubSpell>? clubSpells,
    List<DirectorTrophy>? trophies,
  }) {
    return DirectorCareer(
      activeSeason: activeSeason ?? this.activeSeason,
      seasonHistory: List<DirectorSeasonStats>.unmodifiable(
        seasonHistory ?? this.seasonHistory,
      ),
      clubSpells: List<DirectorClubSpell>.unmodifiable(
        clubSpells ?? this.clubSpells,
      ),
      trophies: List<DirectorTrophy>.unmodifiable(
        trophies ?? this.trophies,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'activeSeason': activeSeason.toMap(),
      'seasonHistory':
          seasonHistory.map((season) => season.toMap()).toList(growable: false),
      'clubSpells':
          clubSpells.map((spell) => spell.toMap()).toList(growable: false),
      'trophies':
          trophies.map((trophy) => trophy.toMap()).toList(growable: false),
    };
  }

  factory DirectorCareer.fromMap(Map<String, dynamic> map) {
    final activeSeasonMap = _readMap(map['activeSeason']);

    return DirectorCareer(
      activeSeason: activeSeasonMap == null
          ? const DirectorSeasonStats(
              seasonYear: 2026,
              clubId: '',
              clubName: '',
            )
          : DirectorSeasonStats.fromMap(activeSeasonMap),
      seasonHistory: _readMapList(map['seasonHistory'])
          .map(DirectorSeasonStats.fromMap)
          .toList(growable: false),
      clubSpells: _readMapList(map['clubSpells'])
          .map(DirectorClubSpell.fromMap)
          .toList(growable: false),
      trophies: _readMapList(map['trophies'])
          .map(DirectorTrophy.fromMap)
          .toList(growable: false),
    );
  }

  static Map<String, dynamic>? _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), item),
      );
    }

    return null;
  }

  static List<Map<String, dynamic>> _readMapList(dynamic value) {
    if (value is! Iterable) {
      return const <Map<String, dynamic>>[];
    }

    final result = <Map<String, dynamic>>[];

    for (final item in value) {
      final map = _readMap(item);

      if (map != null) {
        result.add(map);
      }
    }

    return result;
  }
}

class DirectorSeasonStats {
  final int seasonYear;
  final String clubId;
  final String clubName;
  final int matches;
  final int wins;
  final int draws;
  final int losses;

  const DirectorSeasonStats({
    required this.seasonYear,
    required this.clubId,
    required this.clubName,
    this.matches = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
  });

  int get points => (wins * 3) + draws;

  double get performancePercentage {
    if (matches <= 0) return 0;

    return (points / (matches * 3)) * 100;
  }

  double get winPercentage {
    if (matches <= 0) return 0;

    return (wins / matches) * 100;
  }

  double get drawPercentage {
    if (matches <= 0) return 0;

    return (draws / matches) * 100;
  }

  double get lossPercentage {
    if (matches <= 0) return 0;

    return (losses / matches) * 100;
  }

  bool get isConsistent {
    return matches == wins + draws + losses;
  }

  DirectorSeasonStats registerMatch({
    required int goalsFor,
    required int goalsAgainst,
  }) {
    var nextWins = wins;
    var nextDraws = draws;
    var nextLosses = losses;

    if (goalsFor > goalsAgainst) {
      nextWins += 1;
    } else if (goalsFor < goalsAgainst) {
      nextLosses += 1;
    } else {
      nextDraws += 1;
    }

    return copyWith(
      matches: matches + 1,
      wins: nextWins,
      draws: nextDraws,
      losses: nextLosses,
    );
  }

  DirectorSeasonStats copyWith({
    int? seasonYear,
    String? clubId,
    String? clubName,
    int? matches,
    int? wins,
    int? draws,
    int? losses,
  }) {
    return DirectorSeasonStats(
      seasonYear: seasonYear ?? this.seasonYear,
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      matches: matches ?? this.matches,
      wins: wins ?? this.wins,
      draws: draws ?? this.draws,
      losses: losses ?? this.losses,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'seasonYear': seasonYear,
      'clubId': clubId.trim(),
      'clubName': clubName.trim(),
      'matches': matches,
      'wins': wins,
      'draws': draws,
      'losses': losses,
    };
  }

  factory DirectorSeasonStats.fromMap(Map<String, dynamic> map) {
    return DirectorSeasonStats(
      seasonYear: _readInt(map['seasonYear'], fallback: 2026),
      clubId: _readString(map['clubId']),
      clubName: _readString(map['clubName']),
      matches: _readNonNegativeInt(map['matches']),
      wins: _readNonNegativeInt(map['wins']),
      draws: _readNonNegativeInt(map['draws']),
      losses: _readNonNegativeInt(map['losses']),
    );
  }
}

class DirectorClubSpell {
  final String clubId;
  final String clubName;
  final int startYear;
  final int? endYear;
  final int matches;
  final int wins;
  final int draws;
  final int losses;
  final int trophyCount;
  final int boardPrestige;

  const DirectorClubSpell({
    required this.clubId,
    required this.clubName,
    required this.startYear,
    this.endYear,
    this.matches = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.trophyCount = 0,
    this.boardPrestige = 1,
  });

  bool get isActive => endYear == null;

  int get points => (wins * 3) + draws;

  double get performancePercentage {
    if (matches <= 0) return 0;

    return (points / (matches * 3)) * 100;
  }

  String get periodLabel {
    if (endYear == null) {
      return '$startYear — Atual';
    }

    if (endYear == startYear) {
      return '$startYear';
    }

    return '$startYear — $endYear';
  }

  DirectorClubSpell copyWith({
    String? clubId,
    String? clubName,
    int? startYear,
    int? endYear,
    bool clearEndYear = false,
    int? matches,
    int? wins,
    int? draws,
    int? losses,
    int? trophyCount,
    int? boardPrestige,
  }) {
    return DirectorClubSpell(
      clubId: clubId ?? this.clubId,
      clubName: clubName ?? this.clubName,
      startYear: startYear ?? this.startYear,
      endYear: clearEndYear ? null : endYear ?? this.endYear,
      matches: matches ?? this.matches,
      wins: wins ?? this.wins,
      draws: draws ?? this.draws,
      losses: losses ?? this.losses,
      trophyCount: trophyCount ?? this.trophyCount,
      boardPrestige: (boardPrestige ?? this.boardPrestige).clamp(1, 10).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'clubId': clubId.trim(),
      'clubName': clubName.trim(),
      'startYear': startYear,
      'endYear': endYear,
      'matches': matches,
      'wins': wins,
      'draws': draws,
      'losses': losses,
      'trophyCount': trophyCount,
      'boardPrestige': boardPrestige.clamp(1, 10).toInt(),
    };
  }

  factory DirectorClubSpell.fromMap(Map<String, dynamic> map) {
    final rawEndYear = map['endYear'];

    return DirectorClubSpell(
      clubId: _readString(map['clubId']),
      clubName: _readString(map['clubName']),
      startYear: _readInt(map['startYear'], fallback: 2026),
      endYear: rawEndYear == null ? null : _readInt(rawEndYear, fallback: 2026),
      matches: _readNonNegativeInt(map['matches']),
      wins: _readNonNegativeInt(map['wins']),
      draws: _readNonNegativeInt(map['draws']),
      losses: _readNonNegativeInt(map['losses']),
      trophyCount: _readNonNegativeInt(map['trophyCount']),
      boardPrestige:
          _readInt(map['boardPrestige'], fallback: 1).clamp(1, 10).toInt(),
    );
  }
}

class DirectorTrophy {
  final String competitionId;
  final String competitionName;
  final int seasonYear;
  final String clubId;
  final String clubName;

  const DirectorTrophy({
    required this.competitionId,
    required this.competitionName,
    required this.seasonYear,
    required this.clubId,
    required this.clubName,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'competitionId': competitionId.trim(),
      'competitionName': competitionName.trim(),
      'seasonYear': seasonYear,
      'clubId': clubId.trim(),
      'clubName': clubName.trim(),
    };
  }

  factory DirectorTrophy.fromMap(Map<String, dynamic> map) {
    return DirectorTrophy(
      competitionId: _readString(map['competitionId']),
      competitionName: _readString(map['competitionName']),
      seasonYear: _readInt(map['seasonYear'], fallback: 2026),
      clubId: _readString(map['clubId']),
      clubName: _readString(map['clubName']),
    );
  }
}

class DirectorCareerStats {
  final int matches;
  final int wins;
  final int draws;
  final int losses;

  const DirectorCareerStats({
    required this.matches,
    required this.wins,
    required this.draws,
    required this.losses,
  });

  int get points => (wins * 3) + draws;

  double get performancePercentage {
    if (matches <= 0) return 0;

    return (points / (matches * 3)) * 100;
  }
}

String _readString(dynamic value) {
  if (value is String) {
    return value.trim();
  }

  return '';
}

int _readInt(
  dynamic value, {
  required int fallback,
}) {
  if (value is int) return value;
  if (value is num) return value.toInt();

  if (value is String) {
    return int.tryParse(value.trim()) ?? fallback;
  }

  return fallback;
}

int _readNonNegativeInt(dynamic value) {
  final result = _readInt(value, fallback: 0);

  if (result < 0) {
    return 0;
  }

  return result;
}
