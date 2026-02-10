class TableRowEntry {
  final String clubId;
  final String clubName;
  int played = 0;
  int wins = 0;
  int draws = 0;
  int losses = 0;
  int gf = 0;
  int ga = 0;

  TableRowEntry({required this.clubId, required this.clubName});

  int get points => wins * 3 + draws;
  int get gd => gf - ga;

  void applyMatch(
      {required bool isHome,
      required int goalsFor,
      required int goalsAgainst}) {
    played += 1;
    gf += goalsFor;
    ga += goalsAgainst;
    if (goalsFor > goalsAgainst) {
      wins += 1;
    } else if (goalsFor == goalsAgainst) {
      draws += 1;
    } else {
      losses += 1;
    }
  }
}

class LeagueTable {
  final String divisionId; // "A"|"B"|"C"|"D"
  final Map<String, TableRowEntry> _rows; // clubId -> entry

  LeagueTable({required this.divisionId, required List<TableRowEntry> initial})
      : _rows = {for (final r in initial) r.clubId: r};

  List<TableRowEntry> get rowsSorted {
    final list = _rows.values.toList();
    list.sort((a, b) {
      // pontos DESC, vitórias DESC, saldo DESC, gols pró DESC, jogados ASC, nome ASC
      final p = b.points.compareTo(a.points);
      if (p != 0) return p;
      final w = b.wins.compareTo(a.wins);
      if (w != 0) return w;
      final g = b.gd.compareTo(a.gd);
      if (g != 0) return g;
      final gf = b.gf.compareTo(a.gf);
      if (gf != 0) return gf;
      final pj = a.played.compareTo(b.played);
      if (pj != 0) return pj;
      return a.clubName.compareTo(b.clubName);
    });
    return list;
  }

  TableRowEntry rowOf(String clubId) => _rows[clubId]!;
}
