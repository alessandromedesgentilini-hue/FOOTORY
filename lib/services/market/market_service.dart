import 'dart:math' as math;

import 'package:footory26/core/seeded_rng.dart';
import 'package:footory26/models/player.dart';
import 'package:footory26/models/scout/scout_target.dart';
import 'package:footory26/services/player_factory.dart';

class MarketService {
  final SeededRng rng;
  final PlayerFactory playerFactory;

  final List<Player> _freeAgents = <Player>[];
  final List<Player> _transferPlayers = <Player>[];
  final List<Player> _loanPlayers = <Player>[];

  MarketService({
    required this.rng,
    required this.playerFactory,
  });

  List<Player> get freeAgents => List.unmodifiable(_freeAgents);
  List<Player> get transferPlayers => List.unmodifiable(_transferPlayers);
  List<Player> get loanPlayers => List.unmodifiable(_loanPlayers);

  // ============================================================
  // POOLS INICIAIS
  // ============================================================

  void generateInitialPool({
    required int total,
    required String defaultNationality,
  }) {
    _freeAgents.clear();

    if (total <= 0) return;

    for (var i = 0; i < total; i++) {
      _freeAgents.add(
        _createMarketPlayer(
          defaultNationality: defaultNationality,
          profile: MarketPoolProfile.free,
        ),
      );
    }
  }

  void generateInitialPools({
    required int transferTotal,
    required int loanTotal,
    required int freeTotal,
    required String defaultNationality,
  }) {
    _transferPlayers.clear();
    _loanPlayers.clear();
    _freeAgents.clear();

    for (var i = 0; i < transferTotal; i++) {
      _transferPlayers.add(
        _createMarketPlayer(
          defaultNationality: defaultNationality,
          profile: MarketPoolProfile.transfer,
        ),
      );
    }

    for (var i = 0; i < loanTotal; i++) {
      _loanPlayers.add(
        _createMarketPlayer(
          defaultNationality: defaultNationality,
          profile: MarketPoolProfile.loan,
        ),
      );
    }

    for (var i = 0; i < freeTotal; i++) {
      _freeAgents.add(
        _createMarketPlayer(
          defaultNationality: defaultNationality,
          profile: MarketPoolProfile.free,
        ),
      );
    }
  }

  Player _createMarketPlayer({
    required String defaultNationality,
    required MarketPoolProfile profile,
  }) {
    final pos = _pickWeightedPos();
    final nac = _pickMarketNationality(fallback: defaultNationality);
    final roll = rng.rangeInt(1, 100);

    late final int minOvr;
    late final int maxOvr;
    late final int idadeMin;
    late final int idadeMax;

    switch (profile) {
      case MarketPoolProfile.transfer:
        if (roll <= 45) {
          minOvr = 45;
          maxOvr = 60;
          idadeMin = 18;
          idadeMax = 32;
        } else if (roll <= 78) {
          minOvr = 61;
          maxOvr = 70;
          idadeMin = 18;
          idadeMax = 30;
        } else if (roll <= 94) {
          minOvr = 71;
          maxOvr = 78;
          idadeMin = 18;
          idadeMax = 29;
        } else {
          minOvr = 79;
          maxOvr = 84;
          idadeMin = 18;
          idadeMax = 28;
        }
        break;

      case MarketPoolProfile.loan:
        if (roll <= 55) {
          minOvr = 42;
          maxOvr = 58;
          idadeMin = 17;
          idadeMax = 24;
        } else if (roll <= 88) {
          minOvr = 59;
          maxOvr = 68;
          idadeMin = 17;
          idadeMax = 25;
        } else {
          minOvr = 69;
          maxOvr = 74;
          idadeMin = 17;
          idadeMax = 26;
        }
        break;

      case MarketPoolProfile.free:
        if (roll <= 50) {
          minOvr = 35;
          maxOvr = 55;
          idadeMin = 18;
          idadeMax = 34;
        } else if (roll <= 80) {
          minOvr = 56;
          maxOvr = 66;
          idadeMin = 18;
          idadeMax = 33;
        } else if (roll <= 95) {
          minOvr = 67;
          maxOvr = 75;
          idadeMin = 18;
          idadeMax = 32;
        } else {
          minOvr = 76;
          maxOvr = 82;
          idadeMin = 18;
          idadeMax = 31;
        }
        break;
    }

    return playerFactory.criarJogadorComOvrCheioTarget(
      posDet: pos,
      nacionalidade: nac,
      idadeMin: idadeMin,
      idadeMax: idadeMax,
      minOvrCheio: minOvr,
      maxOvrCheio: maxOvr,
      maxTries: 45,
    );
  }

  // ============================================================
  // CRUD - FREE AGENT
  // ============================================================

  Player? removeFreeAgent(String jogadorId) {
    final idx = _freeAgents.indexWhere((j) => j.id == jogadorId);
    if (idx < 0) return null;
    return _freeAgents.removeAt(idx);
  }

  void addFreeAgent(Player player) {
    final exists = _freeAgents.any((j) => j.id == player.id);
    if (exists) return;
    _freeAgents.add(player);
  }

  void addManyFreeAgents(List<Player> players) {
    for (final player in players) {
      addFreeAgent(player);
    }
  }

  bool containsFreeAgent(String jogadorId) {
    return _freeAgents.any((j) => j.id == jogadorId);
  }

  // ============================================================
  // CRUD - TRANSFER
  // ============================================================

  Player? removeTransferPlayer(String jogadorId) {
    final idx = _transferPlayers.indexWhere((j) => j.id == jogadorId);
    if (idx < 0) return null;
    return _transferPlayers.removeAt(idx);
  }

  void addTransferPlayer(Player player) {
    final exists = _transferPlayers.any((j) => j.id == player.id);
    if (exists) return;
    _transferPlayers.add(player);
  }

  void addManyTransferPlayers(List<Player> players) {
    for (final player in players) {
      addTransferPlayer(player);
    }
  }

  bool containsTransferPlayer(String jogadorId) {
    return _transferPlayers.any((j) => j.id == jogadorId);
  }

  // ============================================================
  // CRUD - LOAN
  // ============================================================

  Player? removeLoanPlayer(String jogadorId) {
    final idx = _loanPlayers.indexWhere((j) => j.id == jogadorId);
    if (idx < 0) return null;
    return _loanPlayers.removeAt(idx);
  }

  void addLoanPlayer(Player player) {
    final exists = _loanPlayers.any((j) => j.id == player.id);
    if (exists) return;
    _loanPlayers.add(player);
  }

  void addManyLoanPlayers(List<Player> players) {
    for (final player in players) {
      addLoanPlayer(player);
    }
  }

  bool containsLoanPlayer(String jogadorId) {
    return _loanPlayers.any((j) => j.id == jogadorId);
  }

  // ============================================================
  // HELPERS POR TIPO DE LISTA
  // ============================================================

  List<Player> playersByListType(MarketListType listType) {
    switch (listType) {
      case MarketListType.free:
        return freeAgents;
      case MarketListType.transfer:
        return transferPlayers;
      case MarketListType.loan:
        return loanPlayers;
    }
  }

  Player? findPlayerByListType({
    required String jogadorId,
    required MarketListType listType,
  }) {
    final source = playersByListType(listType);

    for (final player in source) {
      if (player.id == jogadorId) return player;
    }

    return null;
  }

  Player? removePlayerByListType({
    required String jogadorId,
    required MarketListType listType,
  }) {
    switch (listType) {
      case MarketListType.free:
        return removeFreeAgent(jogadorId);
      case MarketListType.transfer:
        return removeTransferPlayer(jogadorId);
      case MarketListType.loan:
        return removeLoanPlayer(jogadorId);
    }
  }

  void addPlayerByListType({
    required Player player,
    required MarketListType listType,
  }) {
    switch (listType) {
      case MarketListType.free:
        addFreeAgent(player);
        break;
      case MarketListType.transfer:
        addTransferPlayer(player);
        break;
      case MarketListType.loan:
        addLoanPlayer(player);
        break;
    }
  }

  bool containsPlayerByListType({
    required String jogadorId,
    required MarketListType listType,
  }) {
    switch (listType) {
      case MarketListType.free:
        return containsFreeAgent(jogadorId);
      case MarketListType.transfer:
        return containsTransferPlayer(jogadorId);
      case MarketListType.loan:
        return containsLoanPlayer(jogadorId);
    }
  }

  void clearMarket() {
    _freeAgents.clear();
    _transferPlayers.clear();
    _loanPlayers.clear();
  }

  // ============================================================
  // REFILL
  // ============================================================

  void refillFreeAgents({
    required int desiredTotal,
    required String defaultNationality,
  }) {
    if (desiredTotal <= 0) return;
    if (_freeAgents.length >= desiredTotal) return;

    final missing = desiredTotal - _freeAgents.length;
    for (var i = 0; i < missing; i++) {
      addFreeAgent(
        _createMarketPlayer(
          defaultNationality: defaultNationality,
          profile: MarketPoolProfile.free,
        ),
      );
    }
  }

  void refillTransferPlayers({
    required int desiredTotal,
    required String defaultNationality,
  }) {
    if (desiredTotal <= 0) return;
    if (_transferPlayers.length >= desiredTotal) return;

    final missing = desiredTotal - _transferPlayers.length;
    for (var i = 0; i < missing; i++) {
      addTransferPlayer(
        _createMarketPlayer(
          defaultNationality: defaultNationality,
          profile: MarketPoolProfile.transfer,
        ),
      );
    }
  }

  void refillLoanPlayers({
    required int desiredTotal,
    required String defaultNationality,
  }) {
    if (desiredTotal <= 0) return;
    if (_loanPlayers.length >= desiredTotal) return;

    final missing = desiredTotal - _loanPlayers.length;
    for (var i = 0; i < missing; i++) {
      addLoanPlayer(
        _createMarketPlayer(
          defaultNationality: defaultNationality,
          profile: MarketPoolProfile.loan,
        ),
      );
    }
  }

  // ============================================================
  // CPU MARKET
  // ============================================================

  Player? tryCpuSignFreeAgent({
    required String divisionId,
    required double clubPower10,
    int financeLevel = 5,
  }) {
    if (_freeAgents.isEmpty) return null;

    final eligible = _freeAgents.where((p) {
      return _isEligibleForDivision(
        divisionId: divisionId,
        ovr: p.ovrCheio,
      );
    }).toList();

    final opportunity = _freeAgents.where((p) {
      return _isOpportunityForDivision(
        divisionId: divisionId,
        ovr: p.ovrCheio,
      );
    }).toList();

    final pool = <Player>[...eligible];

    final opportunityChance = _opportunityChanceByFinance(financeLevel);
    if (opportunity.isNotEmpty && rng.nextDouble() <= opportunityChance) {
      for (final p in opportunity) {
        if (!pool.any((item) => item.id == p.id)) {
          pool.add(p);
        }
      }
    }

    if (pool.isEmpty) return null;

    final sorted = List<Player>.from(pool)
      ..sort((a, b) {
        final scoreA = _cpuScorePlayer(
          player: a,
          clubPower10: clubPower10,
          divisionId: divisionId,
        );
        final scoreB = _cpuScorePlayer(
          player: b,
          clubPower10: clubPower10,
          divisionId: divisionId,
        );
        return scoreB.compareTo(scoreA);
      });

    final topN = math.min(5, sorted.length);
    if (topN <= 0) return null;

    final chosen = sorted[rng.nextInt(topN)];
    return removeFreeAgent(chosen.id);
  }

  // ============================================================
  // FILTROS
  // ============================================================

  bool _isEligibleForDivision({
    required String divisionId,
    required int ovr,
  }) {
    switch (divisionId.trim().toUpperCase()) {
      case 'BR-A':
        return ovr >= 68;
      case 'BR-B':
        return ovr >= 60 && ovr <= 75;
      case 'BR-C':
        return ovr >= 50 && ovr <= 68;
      case 'BR-D':
        return ovr <= 62;
      default:
        return false;
    }
  }

  bool _isOpportunityForDivision({
    required String divisionId,
    required int ovr,
  }) {
    switch (divisionId.trim().toUpperCase()) {
      case 'BR-A':
        return ovr >= 63 && ovr <= 67;
      case 'BR-B':
        return ovr >= 76 && ovr <= 79;
      case 'BR-C':
        return ovr >= 69 && ovr <= 72;
      case 'BR-D':
        return ovr >= 40 && ovr <= 49;
      default:
        return false;
    }
  }

  double _opportunityChanceByFinance(int financeLevel) {
    switch (financeLevel.clamp(1, 10)) {
      case 1:
      case 2:
        return 0.04;
      case 3:
      case 4:
        return 0.06;
      case 5:
      case 6:
        return 0.08;
      case 7:
      case 8:
        return 0.10;
      case 9:
      case 10:
        return 0.12;
      default:
        return 0.08;
    }
  }

  double _cpuScorePlayer({
    required Player player,
    required double clubPower10,
    required String divisionId,
  }) {
    final targetOvr = (clubPower10 * 10).round().clamp(35, 90);
    final diff = (player.ovrCheio - targetOvr).abs();

    double score = 100 - diff.toDouble();

    if (player.idade <= 21) {
      score += 6;
    } else if (player.idade <= 24) {
      score += 4;
    } else if (player.idade <= 28) {
      score += 2;
    } else if (player.idade >= 33) {
      score -= 4;
    }

    if (_isEligibleForDivision(
      divisionId: divisionId,
      ovr: player.ovrCheio,
    )) {
      score += 8;
    }

    return score;
  }

  // ============================================================
  // POS
  // ============================================================

  PosDet _pickWeightedPos() {
    final roll = rng.rangeInt(1, 100);

    if (roll <= 10) return PosDet.gol;
    if (roll <= 20) return PosDet.ld;
    if (roll <= 30) return PosDet.le;
    if (roll <= 46) return PosDet.zag;
    if (roll <= 58) return PosDet.vol;
    if (roll <= 70) return PosDet.mc;
    if (roll <= 78) return PosDet.mei;
    if (roll <= 86) return PosDet.pd;
    if (roll <= 94) return PosDet.pe;
    return PosDet.ca;
  }

  // ============================================================
  // NACIONALIDADE
  // ============================================================

  String _pickMarketNationality({required String fallback}) {
    final roll = rng.rangeInt(1, 100);

    if (roll <= 65) return 'BR';
    if (roll <= 82) return _pickSouthAmericanNationality();
    if (roll <= 90) return _pickEuropeanNationality();
    if (roll <= 94) return _pickAfricanNationality();
    if (roll <= 98) return _pickAsianNationality();

    return _pickNorthAmericanNationality();
  }

  String _pickSouthAmericanNationality() {
    const pool = <String>[
      'AR',
      'AR',
      'UY',
      'UY',
      'PY',
      'PY',
      'CL',
      'CO',
      'PE',
      'BO',
      'VE',
      'EC',
    ];
    return pool[rng.nextInt(pool.length)];
  }

  String _pickEuropeanNationality() {
    const pool = <String>[
      'IT',
      'IT',
      'PT',
      'ES',
      'FR',
      'DE',
      'NL',
      'HR',
      'RS',
      'ENG',
    ];
    return pool[rng.nextInt(pool.length)];
  }

  String _pickAfricanNationality() {
    const pool = <String>[
      'NG',
      'CI',
      'SN',
      'GH',
      'CM',
      'ML',
    ];
    return pool[rng.nextInt(pool.length)];
  }

  String _pickAsianNationality() {
    const pool = <String>[
      'JP',
      'KR',
      'CN',
    ];
    return pool[rng.nextInt(pool.length)];
  }

  String _pickNorthAmericanNationality() {
    const pool = <String>[
      'US',
      'MX',
      'CR',
    ];
    return pool[rng.nextInt(pool.length)];
  }
}

enum MarketPoolProfile {
  transfer,
  loan,
  free,
}
