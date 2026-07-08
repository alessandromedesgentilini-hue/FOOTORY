class TableEntry {
  final String clubId;

  int played = 0;
  int wins = 0;
  int draws = 0;
  int losses = 0;

  int goalsFor = 0;
  int goalsAgainst = 0;

  int points = 0;

  TableEntry({required this.clubId});

  int get goalDiff => goalsFor - goalsAgainst;

  void reset() {
    played = 0;
    wins = 0;
    draws = 0;
    losses = 0;
    goalsFor = 0;
    goalsAgainst = 0;
    points = 0;
  }
}

class LeagueTable {
  final Map<String, TableEntry> _entries = <String, TableEntry>{};

  void initialize(List<String> clubIds) {
    _entries.clear();

    for (final id in clubIds) {
      _entries[id] = TableEntry(clubId: id);
    }
  }

  void resetAll() {
    _entries.clear();
  }

  void ensureClub(String clubId) {
    _entries.putIfAbsent(clubId, () => TableEntry(clubId: clubId));
  }

  void resetStats() {
    for (final e in _entries.values) {
      e.reset();
    }
  }

  TableEntry? getEntry(String clubId) => _entries[clubId];

  List<TableEntry> getSorted() {
    final list = _entries.values.toList();
    list.sort((a, b) {
      final p = b.points.compareTo(a.points);
      if (p != 0) return p;

      final gd = b.goalDiff.compareTo(a.goalDiff);
      if (gd != 0) return gd;

      final gf = b.goalsFor.compareTo(a.goalsFor);
      if (gf != 0) return gf;

      return a.clubId.compareTo(b.clubId);
    });
    return list;
  }

  bool get isEmpty => _entries.isEmpty;
}
