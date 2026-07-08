class AtlasChampionsClubGroupTableRow {
  final String clubId;

  final int played;
  final int wins;
  final int draws;
  final int losses;

  final int goalsFor;
  final int goalsAgainst;
  final int points;

  const AtlasChampionsClubGroupTableRow({
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

  AtlasChampionsClubGroupTableRow applyMatch({
    required int goalsScored,
    required int goalsConceded,
  }) {
    final isWin = goalsScored > goalsConceded;
    final isDraw = goalsScored == goalsConceded;
    final isLoss = goalsScored < goalsConceded;

    return AtlasChampionsClubGroupTableRow(
      clubId: clubId,
      played: played + 1,
      wins: wins + (isWin ? 1 : 0),
      draws: draws + (isDraw ? 1 : 0),
      losses: losses + (isLoss ? 1 : 0),
      goalsFor: goalsFor + goalsScored,
      goalsAgainst: goalsAgainst + goalsConceded,
      points: points +
          (isWin
              ? 3
              : isDraw
                  ? 1
                  : 0),
    );
  }
}

class AtlasChampionsClubGroupTable {
  final String groupId;
  final List<AtlasChampionsClubGroupTableRow> rows;

  const AtlasChampionsClubGroupTable({
    required this.groupId,
    required this.rows,
  });

  List<AtlasChampionsClubGroupTableRow> get standings {
    final ordered = [...rows];

    ordered.sort((a, b) {
      final pointsCompare = b.points.compareTo(a.points);
      if (pointsCompare != 0) return pointsCompare;

      final gdCompare = b.goalDifference.compareTo(a.goalDifference);
      if (gdCompare != 0) return gdCompare;

      final gfCompare = b.goalsFor.compareTo(a.goalsFor);
      if (gfCompare != 0) return gfCompare;

      return a.clubId.compareTo(b.clubId);
    });

    return List.unmodifiable(ordered);
  }

  AtlasChampionsClubGroupTable applyFixture({
    required String homeClubId,
    required String awayClubId,
    required int homeGoals,
    required int awayGoals,
  }) {
    return AtlasChampionsClubGroupTable(
      groupId: groupId,
      rows: rows.map((row) {
        if (row.clubId == homeClubId) {
          return row.applyMatch(
            goalsScored: homeGoals,
            goalsConceded: awayGoals,
          );
        }

        if (row.clubId == awayClubId) {
          return row.applyMatch(
            goalsScored: awayGoals,
            goalsConceded: homeGoals,
          );
        }

        return row;
      }).toList(growable: false),
    );
  }
}
