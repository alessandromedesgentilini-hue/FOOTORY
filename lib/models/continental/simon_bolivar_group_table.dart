class SimonBolivarGroupTableEntry {
  final String clubId;

  int played;
  int wins;
  int draws;
  int losses;
  int goalsFor;
  int goalsAgainst;
  int points;

  SimonBolivarGroupTableEntry({
    required this.clubId,
    this.played = 0,
    this.wins = 0,
    this.draws = 0,
    this.losses = 0,
    this.goalsFor = 0,
    this.goalsAgainst = 0,
    this.points = 0,
  });

  int get goalDifference => goalsFor - goalsAgainst;

  void applyMatch({
    required int goalsForClub,
    required int goalsAgainstClub,
  }) {
    played += 1;
    goalsFor += goalsForClub;
    goalsAgainst += goalsAgainstClub;

    if (goalsForClub > goalsAgainstClub) {
      wins += 1;
      points += 3;
    } else if (goalsForClub == goalsAgainstClub) {
      draws += 1;
      points += 1;
    } else {
      losses += 1;
    }
  }
}

class SimonBolivarGroupTable {
  final String groupId;
  final Map<String, SimonBolivarGroupTableEntry> _entries =
      <String, SimonBolivarGroupTableEntry>{};

  SimonBolivarGroupTable({
    required this.groupId,
    required List<String> clubIds,
  }) {
    for (final clubId in clubIds) {
      _entries[clubId] = SimonBolivarGroupTableEntry(clubId: clubId);
    }
  }

  List<SimonBolivarGroupTableEntry> get entries {
    return List.unmodifiable(_entries.values);
  }

  SimonBolivarGroupTableEntry ensureClub(String clubId) {
    return _entries.putIfAbsent(
      clubId,
      () => SimonBolivarGroupTableEntry(clubId: clubId),
    );
  }

  void applyMatch({
    required String homeClubId,
    required String awayClubId,
    required int homeGoals,
    required int awayGoals,
  }) {
    ensureClub(homeClubId).applyMatch(
      goalsForClub: homeGoals,
      goalsAgainstClub: awayGoals,
    );

    ensureClub(awayClubId).applyMatch(
      goalsForClub: awayGoals,
      goalsAgainstClub: homeGoals,
    );
  }

  List<SimonBolivarGroupTableEntry> sorted() {
    final list = _entries.values.toList();

    list.sort((a, b) {
      final pts = b.points.compareTo(a.points);
      if (pts != 0) return pts;

      final gd = b.goalDifference.compareTo(a.goalDifference);
      if (gd != 0) return gd;

      final gf = b.goalsFor.compareTo(a.goalsFor);
      if (gf != 0) return gf;

      final wins = b.wins.compareTo(a.wins);
      if (wins != 0) return wins;

      return a.clubId.compareTo(b.clubId);
    });

    return List.unmodifiable(list);
  }

  List<String> topClubIds(int count) {
    return sorted().take(count).map((e) => e.clubId).toList();
  }
}
