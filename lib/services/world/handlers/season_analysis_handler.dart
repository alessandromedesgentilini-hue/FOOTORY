part of '../game_state.dart';

extension SeasonAnalysisHandler on GameState {
  void _applyPromotionAndRelegation() {
    final tabA = _tableByDiv[DivisionId.brA];
    final tabB = _tableByDiv[DivisionId.brB];
    final tabC = _tableByDiv[DivisionId.brC];
    final tabD = _tableByDiv[DivisionId.brD];

    if (tabA == null || tabB == null || tabC == null || tabD == null) return;

    List<String> top4(LeagueTable t) {
      return t.getSorted().take(4).map((e) => e.clubId).toList();
    }

    List<String> bottom4(LeagueTable t) {
      final sorted = t.getSorted();
      final start = (sorted.length - 4).clamp(0, sorted.length);
      return sorted.skip(start).take(4).map((e) => e.clubId).toList();
    }

    final oldDiv = _userDiv();

    _swapBetweenDivs(
      upper: DivisionId.brC,
      lower: DivisionId.brD,
      upperBottom: bottom4(tabC),
      lowerTop: top4(tabD),
    );

    _swapBetweenDivs(
      upper: DivisionId.brB,
      lower: DivisionId.brC,
      upperBottom: bottom4(tabB),
      lowerTop: top4(tabC),
    );

    _swapBetweenDivs(
      upper: DivisionId.brA,
      lower: DivisionId.brB,
      upperBottom: bottom4(tabA),
      lowerTop: top4(tabB),
    );

    final newDiv = _findUserDivision();
    divisionId = _toDivisionStr(newDiv);

    _insertNewsIfNew(
      'Virada de temporada — promoções e rebaixamentos aplicados.',
    );

    final movementLine = _buildUserDivisionMovementLine(
      oldDiv: oldDiv,
      newDiv: newDiv,
    );

    if (movementLine.isNotEmpty) {
      _insertNewsIfNew(movementLine);
    }
  }

  void _swapBetweenDivs({
    required DivisionId upper,
    required DivisionId lower,
    required List<String> upperBottom,
    required List<String> lowerTop,
  }) {
    final upperList =
        List<String>.from(_clubIdsByDiv[upper] ?? const <String>[]);
    final lowerList =
        List<String>.from(_clubIdsByDiv[lower] ?? const <String>[]);

    upperList.removeWhere(
      (id) => upperBottom.contains(id) || lowerTop.contains(id),
    );

    lowerList.removeWhere(
      (id) => lowerTop.contains(id) || upperBottom.contains(id),
    );

    upperList.addAll(lowerTop);
    lowerList.addAll(upperBottom);

    final upperUnique = upperList.toSet().toList();
    final lowerUnique = lowerList.toSet().toList();

    if (upperUnique.length != 20 || lowerUnique.length != 20) {
      debugPrint(
        '!!! swapBetweenDivs gerou listas inválidas: '
        '$upper=${upperUnique.length}, $lower=${lowerUnique.length}',
      );
    }

    _clubIdsByDiv[upper] = upperUnique;
    _clubIdsByDiv[lower] = lowerUnique;
  }

  DivisionId _findUserDivision() {
    for (final div in DivisionId.values) {
      final list = _clubIdsByDiv[div] ?? const <String>[];

      if (list.contains(userClubId)) {
        return div;
      }
    }

    return DivisionId.brD;
  }

  void _afterRoundUpdates({
    required int roundJustFinished,
  }) {
    final pos = _userPositionOrNull();
    if (pos == null) return;

    final sorted = table.getSorted();
    final idx = sorted.indexWhere((e) => e.clubId == userClubId);

    if (idx < 0) return;

    final points = sorted[idx].points;
    final snap = _expectations;

    if (snap == null) return;

    if (!_checkpointService.isCheckpointRound(
      roundJustFinished,
      maxRound: _maxRound,
    )) {
      return;
    }

    final cp = _checkpointService.build(
      round: roundJustFinished,
      maxRound: _maxRound,
      position: pos,
      points: points,
      snap: snap,
    );

    _insertNewsIfNew(
      '${cp.title} — ${cp.body}',
    );

    final emotionalLine = _buildMidSeasonEmotionalLine(
      round: roundJustFinished,
      position: pos,
      points: points,
    );

    if (emotionalLine.isNotEmpty) {
      _insertNewsIfNew(emotionalLine);
    }

    _pendingCheckpoint = cp;
  }

  void _pushEndSeasonLine() {
    final pos = _userPositionOrNull();
    if (pos == null) return;

    final sorted = table.getSorted();
    final idx = sorted.indexWhere((e) => e.clubId == userClubId);

    if (idx < 0) return;

    final points = sorted[idx].points;

    if (_expectations == null) {
      _rebuildSeasonExpectations(
        userTablePosition: pos,
      );
    }

    final snap = _expectations;
    if (snap == null) return;

    final prize = _applyLeagueFinalPositionPrize(
      position: pos,
    );

    final div = _userDiv();

    if (pos == 1) {
      _registerDirectorLeagueTrophy(
        division: div,
      );
    }

    _ensureDirectorCareerForCurrentSeason();

    var boardPrestige = 1;

    final careerBeforePrestigeUpdate = _directorCareer;

    if (careerBeforePrestigeUpdate != null) {
      DirectorClubSpell? activeClubSpell;

      for (final spell in careerBeforePrestigeUpdate.clubSpells.reversed) {
        if (spell.isActive) {
          activeClubSpell = spell;
          break;
        }
      }

      final currentBoardPrestige = activeClubSpell?.boardPrestige ?? 1;

      var boardPrestigeChange = 1;

      if (snap.isStrongAbove) {
        boardPrestigeChange += 1;
      } else if (snap.isStrongBelow) {
        boardPrestigeChange -= 1;
      }

      final wonTitleThisSeason = careerBeforePrestigeUpdate.trophies.any(
        (trophy) {
          return trophy.seasonYear == _seasonYear &&
              trophy.clubId == userClubId;
        },
      );

      if (wonTitleThisSeason) {
        boardPrestigeChange += 1;
      }

      boardPrestige =
          (currentBoardPrestige + boardPrestigeChange).clamp(1, 10).toInt();

      _directorCareer =
          careerBeforePrestigeUpdate.updateActiveClubSpellBoardPrestige(
        boardPrestige,
      );
    }

    final context = SeasonNarrativeContext(
      clubName: userClubName,
      division: div,
      finalPosition: pos,
      points: points,
      promoted: _isPromotionPosition(
        division: div,
        position: pos,
      ),
      relegated: _isRelegationPosition(
        division: div,
        position: pos,
      ),
      clubStatus: userClubStatus,
      expectation: snap,
      legacyPoints: userLegacyPoints,
      initialPower10: snap.initialUserPower10,
      currentPower10: clubPower10(userClubId),
    );

    final analysis = _seasonNarrativeAnalyzer.analyze(
      context,
    );

    final texts = _narrativeWriterService.writeEndSeasonNarrative(
      context: context,
      analysis: analysis,
      boardPrestige: boardPrestige,
    );

    final msg = 'Fim de temporada — $posº lugar com $points pts. '
        'Expectativa inicial: ${snap.initialExpectedLabel}. '
        'Status atual: $userClubStatusLabel.';

    _insertNewsIfNew(msg);

    final contextLine = texts.contextLine;

    if (contextLine != null && contextLine.isNotEmpty) {
      _insertNewsIfNew(contextLine);
    }

    if (texts.seasonLine.isNotEmpty) {
      _insertNewsIfNew(texts.seasonLine);
    }

    if (texts.supporterLine.isNotEmpty) {
      _insertNewsIfNew(texts.supporterLine);
    }

    if (texts.boardLine.isNotEmpty) {
      _insertNewsIfNew(texts.boardLine);
    }

    if (texts.pressLine.isNotEmpty) {
      _insertNewsIfNew(texts.pressLine);
    }

    if (prize > 0) {
      _insertNewsIfNew(
        'FINANÇAS — Pela campanha na liga, o clube recebeu '
        '${MoneyFormatter.formatCurrency(prize)} em premiação final.',
      );
    }

    final financialReport = _seasonFinancialReportService.build(
      start: _seasonStartFinanceSnapshot,
      end: userFinance,
    );

    for (final line in financialReport.lines) {
      _insertNewsIfNew(line);
    }

    final currentSquad = _proSquads[userClubId] ?? const <Player>[];

    lastSeasonReport = _seasonReportBuilder.build(
      oldSquad: _seasonStartSnapshot,
      newSquad: currentSquad,
      clubName: userClubName,
      finalPosition: pos,
      points: points,
      newsFeed: _newsFeed,
    );

    _insertNewsIfNew(
      'Relatório da temporada disponível.',
    );

    _pendingCheckpoint = SeasonCheckpoint(
      round: _maxRound,
      phase: 'end',
      title: 'Fim de temporada',
      body: '$msg\n\n'
          '${texts.emotionLabel}\n\n'
          '${userClubStatus.narrativeContext}\n\n'
          '${texts.supporterLine}\n\n'
          '${texts.boardLine}\n\n'
          '${texts.pressLine}',
      tag: analysis.checkpointTag,
    );
  }

  void _registerDirectorLeagueTrophy({
    required DivisionId division,
  }) {
    _ensureDirectorCareerForCurrentSeason();

    final career = _directorCareer;
    if (career == null) return;

    _directorCareer = career.registerTrophy(
      competitionId: _leagueCompetitionId(division),
      competitionName: _leagueCompetitionName(division),
      seasonYear: _seasonYear,
      clubId: userClubId,
      clubName: userClubName,
    );
  }

  String _leagueCompetitionId(
    DivisionId division,
  ) {
    switch (division) {
      case DivisionId.brA:
        return 'BRA';

      case DivisionId.brB:
        return 'BRB';

      case DivisionId.brC:
        return 'BRC';

      case DivisionId.brD:
        return 'BRD';
    }
  }

  String _leagueCompetitionName(
    DivisionId division,
  ) {
    switch (division) {
      case DivisionId.brA:
        return 'Liga BR A';

      case DivisionId.brB:
        return 'Liga BR B';

      case DivisionId.brC:
        return 'Liga BR C';

      case DivisionId.brD:
        return 'Liga BR D';
    }
  }

  int _applyLeagueFinalPositionPrize({
    required int position,
  }) {
    if (userClubId.isEmpty) return 0;

    final prize = _competitionPrizeService.leagueFinalPositionPrize(
      division: _userDiv(),
      position: position,
    );

    if (prize <= 0) return 0;

    final current = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.applyRestrictedRevenue(
      current: current,
      value: prize,
    );

    return prize;
  }

  void _rebuildSeasonExpectations({
    required int userTablePosition,
  }) {
    final div = _parseDivisionId(divisionId) ?? DivisionId.brD;

    final userPower = clubPower10(userClubId);
    final previous = _expectations;

    final divisionIds = _clubIdsByDiv[div] ?? const <String>[];

    final divisionPowers = <double>[];

    for (final id in divisionIds) {
      if (id == userClubId) continue;

      divisionPowers.add(
        clubCpuPower10(id),
      );
    }

    divisionPowers.add(userPower);

    _expectations = _seasonExpectationService.buildSnapshot(
      division: div,
      divisionPowers: divisionPowers,
      userPower10: userPower,
      userTablePosition: userTablePosition.clamp(1, 20),
      teamPowerService: _teamPowerService,
      previous: previous,
    );
  }

  int _estimatePreSeasonUserTablePosition() {
    final div = _userDiv();
    final ids = _clubIdsByDiv[div] ?? const <String>[];

    if (ids.isEmpty) return 10;

    final powers = <double>[];

    for (final id in ids) {
      powers.add(
        id == userClubId ? clubPower10(id) : clubCpuPower10(id),
      );
    }

    powers.sort(
      (a, b) => b.compareTo(a),
    );

    final userPower = clubPower10(userClubId);
    final idx = powers.indexOf(userPower);

    if (idx < 0) return 10;

    return (idx + 1).clamp(1, 20);
  }

  int? _userPositionOrNull() {
    final sorted = table.getSorted();

    final idx = sorted.indexWhere(
      (e) => e.clubId == userClubId,
    );

    if (idx < 0) return null;

    return idx + 1;
  }

  List<Player> _cloneSquad(
    List<Player> squad,
  ) {
    return squad.map((p) => p.copyWith()).toList();
  }

  String _buildUserDivisionMovementLine({
    required DivisionId oldDiv,
    required DivisionId newDiv,
  }) {
    final tier = userClubStatusTier;

    if (oldDiv == newDiv) {
      if (tier == ClubStatusTier.big || tier == ClubStatusTier.giant) {
        return 'TEMPORADA — O $userClubName permanece na '
            '${_divisionShortLabel(newDiv)}, mas pelo tamanho atual do '
            'clube a cobrança por protagonismo aumenta.';
      }

      return 'TEMPORADA — O $userClubName permanece na '
          '${_divisionShortLabel(newDiv)} para o próximo ano.';
    }

    if (_divisionRank(newDiv) < _divisionRank(oldDiv)) {
      if (tier == ClubStatusTier.tiny || tier == ClubStatusTier.small) {
        return 'TEMPORADA HISTÓRICA — O $userClubName conquista o '
            'acesso e transforma a percepção sobre o tamanho do projeto.';
      }

      return 'TEMPORADA HISTÓRICA — O $userClubName conquista o acesso '
          'e disputará a ${_divisionShortLabel(newDiv)} na próxima temporada.';
    }

    if (tier == ClubStatusTier.big || tier == ClubStatusTier.giant) {
      return 'TEMPORADA CRÍTICA — O $userClubName sofre rebaixamento, '
          'resultado pesado para um clube tratado como '
          '${userClubStatusLabel.toLowerCase()}.';
    }

    return 'TEMPORADA DURA — O $userClubName sofre o rebaixamento e '
        'disputará a ${_divisionShortLabel(newDiv)} na próxima temporada.';
  }

  String _buildMidSeasonEmotionalLine({
    required int round,
    required int position,
    required int points,
  }) {
    final phase = round >= 30
        ? 'reta final'
        : round >= 18
            ? 'segunda metade'
            : 'primeira metade';

    final tier = userClubStatusTier;
    final snap = _expectations;

    if (snap != null && snap.isStrongAbove) {
      return 'ATMOSFERA — Na $phase da liga, o $userClubName começa a '
          'transformar uma expectativa inicial de '
          '${snap.initialExpectedLabel.toLowerCase()} em uma campanha '
          'muito acima do esperado.';
    }

    if (snap != null && snap.isStrongBelow) {
      return 'ATMOSFERA — Na $phase da liga, a pressão aumenta: '
          'a campanha está muito abaixo da régua inicial de '
          '${snap.initialExpectedLabel.toLowerCase()}.';
    }

    if (position <= 4) {
      if (tier == ClubStatusTier.tiny || tier == ClubStatusTier.small) {
        return 'ATMOSFERA — Na $phase da liga, a torcida do '
            '$userClubName começa a tratar o G4 como um sonho possível '
            'e histórico.';
      }

      if (tier == ClubStatusTier.giant) {
        return 'ATMOSFERA — Na $phase da liga, o $userClubName segue '
            'no G4, mas a torcida ainda cobra briga direta por título.';
      }

      return 'ATMOSFERA — Na $phase da liga, a torcida do '
          '$userClubName começa a sonhar alto com a campanha no G4.';
    }

    if (position <= 8) {
      if (tier == ClubStatusTier.big || tier == ClubStatusTier.giant) {
        return 'ATMOSFERA — Na $phase da liga, o $userClubName está '
            'competitivo, mas o tamanho atual do clube aumenta a '
            'cobrança por mais.';
      }

      return 'ATMOSFERA — Na $phase da liga, o $userClubName se mantém '
          'competitivo e alimenta expectativa de brigar na parte de cima.';
    }

    if (position <= 12) {
      if (tier == ClubStatusTier.big || tier == ClubStatusTier.giant) {
        return 'ATMOSFERA — Na $phase da liga, a campanha mediana '
            'incomoda porque já não combina com o status atual do '
            '$userClubName.';
      }

      return 'ATMOSFERA — Na $phase da liga, o $userClubName vive uma '
          'campanha de equilíbrio, ainda procurando transformar '
          'regularidade em ambição.';
    }

    if (position <= 16) {
      if (tier == ClubStatusTier.tiny || tier == ClubStatusTier.small) {
        return 'ATMOSFERA — Na $phase da liga, o clima é de tensão, '
            'mas sobreviver ainda faz parte do processo de crescimento.';
      }

      return 'ATMOSFERA — Na $phase da liga, o clima é de atenção: '
          'o $userClubName precisa pontuar para afastar qualquer risco.';
    }

    if (tier == ClubStatusTier.big || tier == ClubStatusTier.giant) {
      return 'ATMOSFERA — Na $phase da liga, a pressão explode: '
          'um clube desse tamanho não pode normalizar risco de rebaixamento.';
    }

    return 'ATMOSFERA — Na $phase da liga, a pressão aumenta: '
        'o $userClubName entra em estado de alerta contra o rebaixamento.';
  }

  bool _isPromotionPosition({
    required DivisionId division,
    required int position,
  }) {
    if (division == DivisionId.brA) return false;

    return position <= 4;
  }

  bool _isRelegationPosition({
    required DivisionId division,
    required int position,
  }) {
    if (division == DivisionId.brD) return false;

    return position >= 17;
  }

  int _divisionRank(
    DivisionId div,
  ) {
    switch (div) {
      case DivisionId.brA:
        return 1;

      case DivisionId.brB:
        return 2;

      case DivisionId.brC:
        return 3;

      case DivisionId.brD:
        return 4;
    }
  }

  String _divisionShortLabel(
    DivisionId div,
  ) {
    switch (div) {
      case DivisionId.brA:
        return 'Série A';

      case DivisionId.brB:
        return 'Série B';

      case DivisionId.brC:
        return 'Série C';

      case DivisionId.brD:
        return 'Série D';
    }
  }
}
