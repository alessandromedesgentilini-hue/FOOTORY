part of '../game_state.dart';

class UserMatchPlayerEvent {
  final String playerId;
  final String playerName;
  final PosDet posDet;

  const UserMatchPlayerEvent({
    required this.playerId,
    required this.playerName,
    required this.posDet,
  });
}

class UserMatchSummary {
  final List<UserMatchPlayerEvent> scorers;
  final List<UserMatchPlayerEvent> assisters;
  final UserMatchPlayerEvent? highlightPlayer;
  final String? highlightReason;

  const UserMatchSummary({
    required this.scorers,
    required this.assisters,
    required this.highlightPlayer,
    required this.highlightReason,
  });
}

extension RuntimeHelperHandler on GameState {
  MatchResult _simulateMatch(Fixture fx) {
    final homeId = fx.homeClubId;
    final awayId = fx.awayClubId;

    final isUserInMatch = homeId == userClubId || awayId == userClubId;
    final isUserHome = homeId == userClubId;

    final homeCoach =
        (homeId == userClubId) ? userCoachLevel : clubCpuCoachLevel(homeId);
    final awayCoach =
        (awayId == userClubId) ? userCoachLevel : clubCpuCoachLevel(awayId);

    return _matchEngine.simulate(
      homeBasePower: clubMatchPower(homeId),
      awayBasePower: clubMatchPower(awayId),
      homeCoachLevel: homeCoach,
      awayCoachLevel: awayCoach,
      homeStadiumLevel: clubStadiumLevel(homeId),
      applyUserHomeBonus: isUserInMatch && isUserHome,
      rng: _rng,
    );
  }

  void _updateUserStreak(int goalsFor, int goalsAgainst) {
    if (goalsFor > goalsAgainst) {
      userWinStreak++;
      userLoseStreak = 0;
      userDrawStreak = 0;
      return;
    }

    if (goalsFor < goalsAgainst) {
      userLoseStreak++;
      userWinStreak = 0;
      userDrawStreak = 0;
      return;
    }

    userDrawStreak++;
    userWinStreak = 0;
    userLoseStreak = 0;
  }

  void _addGeneratedNews(List<String> generatedNews) {
    for (final item in generatedNews.reversed) {
      if (_isRelevantGeneratedNews(item)) {
        _newsFeed.insert(0, item);
      }
    }
  }

  bool _isRelevantGeneratedNews(String line) {
    final normalized = line.trim().toLowerCase();
    if (normalized.isEmpty) return false;

    final userClub = userClubName.trim().toLowerCase();
    if (userClub.isNotEmpty && normalized.contains(userClub)) {
      return true;
    }

    final squad = _proSquads[userClubId] ?? const <Player>[];
    for (final p in squad) {
      final name = p.nome.trim().toLowerCase();
      if (name.isNotEmpty && normalized.contains(name)) {
        return true;
      }
    }

    return false;
  }

  UserMatchSummary _processUserMatchPlayerStats({
    required int goalsFor,
    required int goalsAgainst,
    required bool isSpecialRound,
  }) {
    final matchPlayers = _userMatchPlayers();
    final eventPool = _userMatchEventPool();

    if (matchPlayers.isEmpty) {
      return const UserMatchSummary(
        scorers: [],
        assisters: [],
        highlightPlayer: null,
        highlightReason: null,
      );
    }

    final scorers = <UserMatchPlayerEvent>[];
    final assisters = <UserMatchPlayerEvent>[];

    for (int i = 0; i < goalsFor; i++) {
      final scorer =
          _pickGoalScorer(eventPool.isEmpty ? matchPlayers : eventPool);

      scorers.add(
        UserMatchPlayerEvent(
          playerId: scorer.id,
          playerName: scorer.nome,
          posDet: scorer.posDet,
        ),
      );

      final assist = _pickPossibleAssister(
        squad: eventPool.isEmpty ? matchPlayers : eventPool,
        scorerId: scorer.id,
      );

      if (assist != null) {
        assisters.add(
          UserMatchPlayerEvent(
            playerId: assist.id,
            playerName: assist.nome,
            posDet: assist.posDet,
          ),
        );
      }
    }

    final highlight = isSpecialRound
        ? _pickHighlightPlayer(
            squad: matchPlayers,
            scorers: scorers,
            assisters: assisters,
            goalsFor: goalsFor,
            goalsAgainst: goalsAgainst,
          )
        : null;

    final highlightReason = highlight == null
        ? null
        : _buildHighlightReason(
            player: highlight,
            goalsFor: goalsFor,
            goalsAgainst: goalsAgainst,
          );

    _applySeasonStatsToUserSquad(
      matchPlayers: matchPlayers,
      scorers: scorers,
      assisters: assisters,
      highlightPlayerId: highlight?.playerId,
    );

    return UserMatchSummary(
      scorers: scorers,
      assisters: assisters,
      highlightPlayer: highlight,
      highlightReason: highlightReason,
    );
  }

  void _applySeasonStatsToUserSquad({
    required List<Player> matchPlayers,
    required List<UserMatchPlayerEvent> scorers,
    required List<UserMatchPlayerEvent> assisters,
    required String? highlightPlayerId,
  }) {
    final squad = List<Player>.from(_proSquads[userClubId] ?? const <Player>[]);
    if (squad.isEmpty) return;

    final matchPlayerIds = matchPlayers.map((p) => p.id).toSet();

    final goalsById = <String, int>{};
    final assistsById = <String, int>{};

    for (final item in scorers) {
      goalsById[item.playerId] = (goalsById[item.playerId] ?? 0) + 1;
    }

    for (final item in assisters) {
      assistsById[item.playerId] = (assistsById[item.playerId] ?? 0) + 1;
    }

    final updated = <Player>[];

    for (final player in squad) {
      if (!matchPlayerIds.contains(player.id)) {
        updated.add(player);
        continue;
      }

      final goals = goalsById[player.id] ?? 0;
      final assists = assistsById[player.id] ?? 0;
      final isHighlight =
          highlightPlayerId != null && player.id == highlightPlayerId;

      var next = player.addJogo(foiDestaque: isHighlight);

      if (goals > 0) {
        next = next.addGol(quantidade: goals);
      }

      if (assists > 0) {
        next = next.addAssistencia(quantidade: assists);
      }

      updated.add(next);
    }

    _proSquads[userClubId] = updated;
  }

  Player _pickGoalScorer(List<Player> squad) {
    final weighted = <Player>[];

    for (final p in squad) {
      final weight = _goalWeightForPlayer(p);
      for (int i = 0; i < weight; i++) {
        weighted.add(p);
      }
    }

    if (weighted.isEmpty) {
      return squad[_rng.nextInt(squad.length)];
    }

    return weighted[_rng.nextInt(weighted.length)];
  }

  Player? _pickPossibleAssister({
    required List<Player> squad,
    required String scorerId,
  }) {
    final shouldHaveAssist = _rng.nextInt(100) < 72;
    if (!shouldHaveAssist) return null;

    final eligible = squad.where((p) => p.id != scorerId).toList();
    if (eligible.isEmpty) return null;

    final weighted = <Player>[];

    for (final p in eligible) {
      final weight = _assistWeightForPlayer(p);
      for (int i = 0; i < weight; i++) {
        weighted.add(p);
      }
    }

    if (weighted.isEmpty) {
      return eligible[_rng.nextInt(eligible.length)];
    }

    return weighted[_rng.nextInt(weighted.length)];
  }

  UserMatchPlayerEvent? _pickHighlightPlayer({
    required List<Player> squad,
    required List<UserMatchPlayerEvent> scorers,
    required List<UserMatchPlayerEvent> assisters,
    required int goalsFor,
    required int goalsAgainst,
  }) {
    final candidateIds = <String>{};

    for (final s in scorers) {
      candidateIds.add(s.playerId);
    }

    for (final a in assisters) {
      candidateIds.add(a.playerId);
    }

    final topOverall = List<Player>.from(squad)
      ..sort((a, b) => b.ovrCheio.compareTo(a.ovrCheio));

    for (final p in topOverall.take(2)) {
      candidateIds.add(p.id);
    }

    if (goalsFor == 0) {
      final defensive = squad.where((p) {
        return p.posDet == PosDet.gol ||
            p.posDet == PosDet.zag ||
            p.posDet == PosDet.ld ||
            p.posDet == PosDet.le ||
            p.posDet == PosDet.vol;
      }).toList();

      defensive.sort((a, b) => b.ovrCheio.compareTo(a.ovrCheio));
      if (defensive.isNotEmpty) {
        candidateIds.add(defensive.first.id);
      }
    }

    final candidates = squad.where((p) => candidateIds.contains(p.id)).toList();
    if (candidates.isEmpty) return null;

    final weighted = <Player>[];

    for (final p in candidates) {
      var weight = 1;

      final goals = scorers.where((e) => e.playerId == p.id).length;
      final assists = assisters.where((e) => e.playerId == p.id).length;

      weight += goals * 5;
      weight += assists * 3;
      weight += (p.ovrCheio / 20).floor().clamp(0, 5);

      if (goalsFor == 0 &&
          (p.posDet == PosDet.gol ||
              p.posDet == PosDet.zag ||
              p.posDet == PosDet.vol)) {
        weight += 3;
      }

      for (int i = 0; i < weight; i++) {
        weighted.add(p);
      }
    }

    final chosen = weighted[_rng.nextInt(weighted.length)];

    return UserMatchPlayerEvent(
      playerId: chosen.id,
      playerName: chosen.nome,
      posDet: chosen.posDet,
    );
  }

  String _buildHighlightReason({
    required UserMatchPlayerEvent player,
    required int goalsFor,
    required int goalsAgainst,
  }) {
    switch (player.posDet) {
      case PosDet.gol:
        return _pickOne([
          'fez defesas importantes e transmitiu segurança ao time.',
          'segurou o resultado em momentos-chave da partida.',
          'apareceu bem quando o time mais precisou.',
        ]);

      case PosDet.ld:
      case PosDet.le:
        return _pickOne([
          'apoiou com intensidade e sustentou bem o corredor.',
          'deu profundidade pelo lado e ajudou bastante no equilíbrio do time.',
          'foi importante no apoio e na recomposição durante a partida.',
        ]);

      case PosDet.zag:
        return _pickOne([
          'venceu duelos importantes e protegeu bem a área.',
          'foi firme na cobertura defensiva e sustentou o sistema atrás.',
          'segurou bem a pressão adversária nos momentos mais delicados.',
        ]);

      case PosDet.vol:
        return _pickOne([
          'equilibrou o meio-campo e venceu duelos importantes.',
          'protegeu bem a entrada da área e deu sustentação ao time.',
          'foi importante sem a bola e ajudou a manter o controle do setor.',
        ]);

      case PosDet.mc:
      case PosDet.mei:
        return _pickOne([
          'organizou as jogadas e deu ritmo às ações do time.',
          'conectou os setores com qualidade e participou bem da criação.',
          'acelerou a construção ofensiva e foi importante com a bola.',
        ]);

      case PosDet.pd:
      case PosDet.pe:
        return _pickOne([
          'atacou os espaços com perigo e empurrou o time para frente.',
          'foi agressivo no último terço e incomodou bastante a defesa rival.',
          'deu profundidade ao ataque e apareceu bem nas ações ofensivas.',
        ]);

      case PosDet.ca:
        if (goalsFor > goalsAgainst) {
          return _pickOne([
            'foi agressivo no último terço e teve peso grande no resultado.',
            'sustentou bem a presença ofensiva e foi decisivo na frente.',
            'deu profundidade ao ataque e participou dos lances mais perigosos.',
          ]);
        }

        return _pickOne([
          'brigou bastante na frente e tentou sustentar o ataque do time.',
          'foi uma das referências ofensivas e lutou para manter o time vivo no jogo.',
          'tentou empurrar o setor ofensivo e participou dos momentos mais perigosos.',
        ]);
    }
  }

  int _goalWeightForPlayer(Player p) {
    final ovrBonus = (p.ovrCheio / 20).floor().clamp(0, 5);
    final consistencyBonus = (p.consistencia / 4).floor().clamp(0, 3);

    switch (p.posDet) {
      case PosDet.ca:
        return 12 + ovrBonus + consistencyBonus;
      case PosDet.pd:
      case PosDet.pe:
        return 8 + ovrBonus + consistencyBonus;
      case PosDet.mei:
      case PosDet.mc:
        return 6 + ovrBonus + consistencyBonus;
      case PosDet.vol:
        return 3 + ovrBonus + consistencyBonus;
      case PosDet.ld:
      case PosDet.le:
        return 2 + ovrBonus;
      case PosDet.zag:
        return 2 + ovrBonus;
      case PosDet.gol:
        return 1;
    }
  }

  int _assistWeightForPlayer(Player p) {
    final ovrBonus = (p.ovrCheio / 25).floor().clamp(0, 4);
    final consistencyBonus = (p.consistencia / 5).floor().clamp(0, 2);

    switch (p.posDet) {
      case PosDet.mei:
      case PosDet.mc:
        return 10 + ovrBonus + consistencyBonus;
      case PosDet.pd:
      case PosDet.pe:
        return 8 + ovrBonus + consistencyBonus;
      case PosDet.ld:
      case PosDet.le:
        return 7 + ovrBonus;
      case PosDet.vol:
        return 5 + ovrBonus + consistencyBonus;
      case PosDet.ca:
        return 4 + ovrBonus + consistencyBonus;
      case PosDet.zag:
        return 1 + ovrBonus;
      case PosDet.gol:
        return 1;
    }
  }

  String _pickOne(List<String> options) {
    if (options.isEmpty) return '';
    return options[_rng.nextInt(options.length)];
  }

  DivisionId _userDiv() => _parseDivisionId(divisionId) ?? DivisionId.brD;

  DivisionId? _parseDivisionId(String v) {
    switch (v.trim().toUpperCase()) {
      case 'BR-A':
        return DivisionId.brA;
      case 'BR-B':
        return DivisionId.brB;
      case 'BR-C':
        return DivisionId.brC;
      case 'BR-D':
        return DivisionId.brD;
      default:
        return null;
    }
  }

  String _toDivisionStr(DivisionId d) {
    switch (d) {
      case DivisionId.brA:
        return 'BR-A';
      case DivisionId.brB:
        return 'BR-B';
      case DivisionId.brC:
        return 'BR-C';
      case DivisionId.brD:
        return 'BR-D';
    }
  }

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/${d.year}';
  }
}
