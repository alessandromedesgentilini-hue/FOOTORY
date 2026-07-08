import 'package:footory26/models/player.dart';

class AutoLineupResult {
  final List<Player> starters;
  final List<Player> reserves;
  final String formation;

  final double startersPower10;
  final double reservesPower10;
  final double matchPower10;

  const AutoLineupResult({
    required this.starters,
    required this.reserves,
    required this.formation,
    required this.startersPower10,
    required this.reservesPower10,
    required this.matchPower10,
  });

  List<Player> get matchPlayers {
    return List.unmodifiable([
      ...starters,
      ...reserves,
    ]);
  }

  /// Pool simples para eventos:
  /// - titular entra 3x
  /// - reserva entra 1x
  ///
  /// Isso gera algo próximo de 75% titulares / 25% reservas,
  /// sem precisar simular substituição real.
  List<Player> get weightedEventPool {
    final pool = <Player>[];

    for (final p in starters) {
      pool.add(p);
      pool.add(p);
      pool.add(p);
    }

    for (final p in reserves) {
      pool.add(p);
    }

    if (pool.isEmpty) {
      return matchPlayers;
    }

    return List.unmodifiable(pool);
  }
}

class AutoLineupService {
  const AutoLineupService();

  AutoLineupResult build({
    required List<Player> squad,
    required String formation,
    int maxBenchSize = 7,
  }) {
    final players = List<Player>.from(squad);
    final usedIds = <String>{};
    final starters = <Player>[];

    final slots = formationSlots(formation);

    for (final slot in slots) {
      final picked = _pickBestPlayerForSlot(
        players: players,
        slot: slot,
        usedIds: usedIds,
      );

      if (picked == null) continue;

      usedIds.add(picked.id);
      starters.add(picked);
    }

    if (starters.length < 11) {
      final remaining = players.where((p) => !usedIds.contains(p.id)).toList()
        ..sort(_comparePlayersByOverall);

      for (final p in remaining) {
        if (starters.length >= 11) break;
        usedIds.add(p.id);
        starters.add(p);
      }
    }

    final reserves = _buildBench(
      players: players,
      usedIds: usedIds,
      maxBenchSize: maxBenchSize,
    );

    final startersPower = power10FromPlayers(starters);
    final reservesPower =
        reserves.isEmpty ? startersPower : power10FromPlayers(reserves);

    /// Força real da partida:
    /// - 90% titulares
    /// - 10% banco
    ///
    /// Isso evita o elenco inteiro inflar/derrubar demais o MatchEngine,
    /// mas ainda deixa o banco interferir levemente na força do time.
    final matchPower = _clamp10(
      (startersPower * 0.90) + (reservesPower * 0.10),
    );

    return AutoLineupResult(
      starters: List.unmodifiable(starters),
      reserves: List.unmodifiable(reserves),
      formation: formation,
      startersPower10: startersPower,
      reservesPower10: reservesPower,
      matchPower10: matchPower,
    );
  }

  double power10FromPlayers(List<Player> players) {
    if (players.isEmpty) return 1.0;

    double sum = 0;

    for (final p in players) {
      sum += p.rating10;
    }

    return _clamp10(sum / players.length);
  }

  double _clamp10(double v) {
    if (v.isNaN || v.isInfinite) return 1.0;
    if (v < 1.0) return 1.0;
    if (v > 10.0) return 10.0;
    return v;
  }

  List<PosDet> formationSlots(String formation) {
    final normalized = formation.trim().toLowerCase();

    switch (normalized) {
      case '4-3-3':
        return const [
          PosDet.gol,
          PosDet.le,
          PosDet.zag,
          PosDet.zag,
          PosDet.ld,
          PosDet.vol,
          PosDet.mc,
          PosDet.mc,
          PosDet.pe,
          PosDet.ca,
          PosDet.pd,
        ];

      case '4-4-2':
        return const [
          PosDet.gol,
          PosDet.le,
          PosDet.zag,
          PosDet.zag,
          PosDet.ld,
          PosDet.pe,
          PosDet.mc,
          PosDet.mc,
          PosDet.pd,
          PosDet.ca,
          PosDet.ca,
        ];

      case '4-2-3-1':
        return const [
          PosDet.gol,
          PosDet.le,
          PosDet.zag,
          PosDet.zag,
          PosDet.ld,
          PosDet.vol,
          PosDet.vol,
          PosDet.pe,
          PosDet.mei,
          PosDet.pd,
          PosDet.ca,
        ];

      case '4-1-4-1':
        return const [
          PosDet.gol,
          PosDet.le,
          PosDet.zag,
          PosDet.zag,
          PosDet.ld,
          PosDet.vol,
          PosDet.pe,
          PosDet.mc,
          PosDet.mc,
          PosDet.pd,
          PosDet.ca,
        ];

      case '3-5-2':
        return const [
          PosDet.gol,
          PosDet.zag,
          PosDet.zag,
          PosDet.zag,
          PosDet.le,
          PosDet.vol,
          PosDet.mc,
          PosDet.mc,
          PosDet.ld,
          PosDet.ca,
          PosDet.ca,
        ];

      case '3-4-3':
        return const [
          PosDet.gol,
          PosDet.zag,
          PosDet.zag,
          PosDet.zag,
          PosDet.le,
          PosDet.mc,
          PosDet.mc,
          PosDet.ld,
          PosDet.pe,
          PosDet.ca,
          PosDet.pd,
        ];

      case '4-3-1-2':
        return const [
          PosDet.gol,
          PosDet.le,
          PosDet.zag,
          PosDet.zag,
          PosDet.ld,
          PosDet.mc,
          PosDet.mc,
          PosDet.mc,
          PosDet.mei,
          PosDet.ca,
          PosDet.ca,
        ];

      default:
        return const [
          PosDet.gol,
          PosDet.le,
          PosDet.zag,
          PosDet.zag,
          PosDet.ld,
          PosDet.vol,
          PosDet.mc,
          PosDet.mc,
          PosDet.pe,
          PosDet.ca,
          PosDet.pd,
        ];
    }
  }

  List<Player> _buildBench({
    required List<Player> players,
    required Set<String> usedIds,
    required int maxBenchSize,
  }) {
    final bench = <Player>[];
    final benchIds = <String>{};

    List<Player> available() {
      return players
          .where((p) => !usedIds.contains(p.id) && !benchIds.contains(p.id))
          .toList();
    }

    void addBestWhere(bool Function(Player p) test) {
      if (bench.length >= maxBenchSize) return;

      final candidates = available().where(test).toList()
        ..sort(_comparePlayersByOverall);

      if (candidates.isEmpty) return;

      final picked = candidates.first;
      bench.add(picked);
      benchIds.add(picked.id);
    }

    addBestWhere((p) => p.posDet == PosDet.gol);
    addBestWhere((p) => p.posMacro == PosMacro.def);
    addBestWhere((p) => p.posMacro == PosMacro.mei);
    addBestWhere((p) => p.posMacro == PosMacro.ata);

    while (bench.length < maxBenchSize) {
      final candidates = available()..sort(_comparePlayersByOverall);
      if (candidates.isEmpty) break;

      final picked = candidates.first;
      bench.add(picked);
      benchIds.add(picked.id);
    }

    return bench;
  }

  Player? _pickBestPlayerForSlot({
    required List<Player> players,
    required PosDet slot,
    required Set<String> usedIds,
  }) {
    Player? best;
    int bestScore = -999999;

    for (final p in players) {
      if (usedIds.contains(p.id)) continue;

      final compatibility = _slotCompatibility(
        playerPos: p.posDet,
        slot: slot,
      );

      if (compatibility <= 0) continue;

      final score = (compatibility * 10000) +
          (p.ovrCheio * 100) +
          p.consistencia -
          _ageTiebreakPenalty(p);

      if (score > bestScore) {
        bestScore = score;
        best = p;
      }
    }

    return best;
  }

  int _slotCompatibility({
    required PosDet playerPos,
    required PosDet slot,
  }) {
    if (playerPos == slot) return 4;

    if (slot == PosDet.gol) return 0;
    if (playerPos == PosDet.gol) return 0;

    switch (slot) {
      case PosDet.gol:
        return 0;

      case PosDet.ld:
        if (playerPos == PosDet.le) return 3;
        if (playerPos == PosDet.zag || playerPos == PosDet.vol) return 2;
        if (playerPos == PosDet.mc) return 1;
        return 0;

      case PosDet.le:
        if (playerPos == PosDet.ld) return 3;
        if (playerPos == PosDet.zag || playerPos == PosDet.vol) return 2;
        if (playerPos == PosDet.mc) return 1;
        return 0;

      case PosDet.zag:
        if (playerPos == PosDet.vol) return 2;
        if (playerPos == PosDet.ld || playerPos == PosDet.le) return 1;
        return 0;

      case PosDet.vol:
        if (playerPos == PosDet.mc) return 3;
        if (playerPos == PosDet.zag || playerPos == PosDet.mei) return 2;
        return 0;

      case PosDet.mc:
        if (playerPos == PosDet.vol || playerPos == PosDet.mei) return 3;
        if (playerPos == PosDet.pd || playerPos == PosDet.pe) return 1;
        return 0;

      case PosDet.mei:
        if (playerPos == PosDet.mc) return 3;
        if (playerPos == PosDet.pd || playerPos == PosDet.pe) return 2;
        if (playerPos == PosDet.vol || playerPos == PosDet.ca) return 1;
        return 0;

      case PosDet.pd:
        if (playerPos == PosDet.pe) return 3;
        if (playerPos == PosDet.mei || playerPos == PosDet.ca) return 2;
        if (playerPos == PosDet.mc) return 1;
        return 0;

      case PosDet.pe:
        if (playerPos == PosDet.pd) return 3;
        if (playerPos == PosDet.mei || playerPos == PosDet.ca) return 2;
        if (playerPos == PosDet.mc) return 1;
        return 0;

      case PosDet.ca:
        if (playerPos == PosDet.pd || playerPos == PosDet.pe) return 2;
        if (playerPos == PosDet.mei) return 1;
        return 0;
    }
  }

  int _ageTiebreakPenalty(Player p) {
    if (p.idade <= 23) return 0;
    if (p.idade <= 30) return 1;
    if (p.idade <= 34) return 2;
    return 3;
  }

  int _comparePlayersByOverall(Player a, Player b) {
    final byOverall = b.ovrCheio.compareTo(a.ovrCheio);
    if (byOverall != 0) return byOverall;

    final byConsistency = b.consistencia.compareTo(a.consistencia);
    if (byConsistency != 0) return byConsistency;

    return a.idade.compareTo(b.idade);
  }
}
