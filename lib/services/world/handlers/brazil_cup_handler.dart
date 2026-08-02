part of '../game_state.dart';

extension BrazilCupHandler on GameState {
  void _bootstrapBrazilCupForSeason() {
    _brazilCupFixtures.clear();

    final serieA = List<String>.from(
      _clubIdsByDiv[DivisionId.brA] ?? const <String>[],
    );

    final serieB = List<String>.from(
      _clubIdsByDiv[DivisionId.brB] ?? const <String>[],
    );

    final serieC = List<String>.from(
      _clubIdsByDiv[DivisionId.brC] ?? const <String>[],
    );

    final serieD = List<String>.from(
      _clubIdsByDiv[DivisionId.brD] ?? const <String>[],
    );

    if (serieA.length != 20 ||
        serieB.length != 20 ||
        serieC.length != 20 ||
        serieD.length != 20) {
      _insertNewsIfNew(
        'Copa Brasileira — Não foi possível montar a copa: divisões incompletas.',
      );
      return;
    }

    final topD = _topSerieDForBrazilCup(serieD);

    final qualified = <String>[
      ...serieA,
      ...serieB,
      ...serieC,
      ...topD,
    ];

    if (qualified.length != 64) {
      _insertNewsIfNew(
        'Copa Brasileira — Não foi possível montar a copa: eram esperados 64 clubes, mas foram encontrados ${qualified.length}.',
      );
      return;
    }

    final fixtures = _cupService.buildNextPhase(
      seasonYear: _seasonYear,
      phase: 1,
      phaseLabel: 'Fase 1',
      qualifiedClubIds: qualified,
      dates: _brazilCupPhaseDates(1),
      rng: _rng,
      twoLegs: _brazilCupPhaseHasTwoLegs(1),
    );

    _brazilCupFixtures.addAll(fixtures);

    if (_brazilCupFixtures.isEmpty) {
      _insertNewsIfNew(
        'Copa Brasileira — A competição foi criada, mas nenhum confronto foi sorteado.',
      );
      return;
    }

    _applyBrazilCupPhasePrizeIfUserIsInPhase(phase: 1);
    _insertBrazilCupDrawNews(phase: 1);
  }

  List<String> _topSerieDForBrazilCup(List<String> serieD) {
    final sorted = List<String>.from(serieD);

    sorted.sort((a, b) {
      final bp = clubCpuPower10(b).compareTo(clubCpuPower10(a));
      if (bp != 0) return bp;

      return clubName(a).compareTo(clubName(b));
    });

    return sorted.take(4).toList();
  }

  void _simulateBrazilCupBetweenDates({
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    if (_brazilCupFixtures.isEmpty) return;

    final indexesToPlay = <int>[];

    for (int i = 0; i < _brazilCupFixtures.length; i++) {
      final fx = _brazilCupFixtures[i];

      if (fx.isPlayed) continue;

      final isAfterFrom = fx.date.isAfter(fromDate);
      final isUntilTo = !fx.date.isAfter(toDate);

      if (isAfterFrom && isUntilTo) {
        indexesToPlay.add(i);
      }
    }

    if (indexesToPlay.isEmpty) return;

    final playedFixtures = <CupFixture>[];
    final resolvedTies = <CupTieUpdate>[];

    for (final index in indexesToPlay) {
      final fx = _brazilCupFixtures[index];

      final result = _simulateCupFixture(fx);

      final penaltyWinner = result.homeGoals == result.awayGoals
          ? _pickPenaltyWinnerForFixture(fx)
          : null;

      final update = _cupService.applyKnockoutFixtureResult(
        fixtures: _brazilCupFixtures,
        fixture: fx,
        homeGoals: result.homeGoals,
        awayGoals: result.awayGoals,
        rng: _rng,
        penaltyWinnerClubId: penaltyWinner,
      );

      for (final updatedFixture in update.fixtures) {
        final idx = _brazilCupFixtures.indexWhere(
          (item) => item.id == updatedFixture.id,
        );

        if (idx >= 0) {
          _brazilCupFixtures[idx] = updatedFixture;
        }
      }

      final played = _brazilCupFixtures.firstWhere(
        (item) => item.id == fx.id,
        orElse: () => fx,
      );

      playedFixtures.add(played);

      if (update.tieResolved) {
        resolvedTies.add(update);
      }

      _recordBrazilCupMatchInDirectorCareer(played);

      _applyBrazilCupMatchPrizeIfUserPlayed(played);

      _insertUserCupResultNews(
        fixture: played,
        tieUpdate: update,
      );
    }

    _insertBrazilCupResultsBulletin(
      playedFixtures: playedFixtures,
      resolvedTies: resolvedTies,
    );

    _maybeBuildNextBrazilCupPhase();
  }

  void _recordBrazilCupMatchInDirectorCareer(
    CupFixture fixture,
  ) {
    final homeGoals = fixture.homeGoals;
    final awayGoals = fixture.awayGoals;

    if (homeGoals == null || awayGoals == null) return;

    final userPlayed =
        fixture.homeClubId == userClubId || fixture.awayClubId == userClubId;

    if (!userPlayed) return;

    final userGoals = fixture.homeClubId == userClubId ? homeGoals : awayGoals;

    final opponentGoals =
        fixture.homeClubId == userClubId ? awayGoals : homeGoals;

    _recordDirectorOfficialMatch(
      goalsFor: userGoals,
      goalsAgainst: opponentGoals,
    );
  }

  void _registerBrazilCupDirectorTrophy() {
    _ensureDirectorCareerForCurrentSeason();

    final career = _directorCareer;
    if (career == null) return;

    _directorCareer = career.registerTrophy(
      competitionId: 'CBR',
      competitionName: 'Copa Brasileira',
      seasonYear: _seasonYear,
      clubId: userClubId,
      clubName: userClubName,
    );
  }

  MatchResult _simulateCupFixture(CupFixture fx) {
    final pseudoFixture = Fixture(
      round: 0,
      homeClubId: fx.homeClubId,
      awayClubId: fx.awayClubId,
    );

    return _simulateMatch(pseudoFixture);
  }

  String? _pickPenaltyWinnerForFixture(CupFixture fx) {
    final homePower = _penaltyShootoutPower(fx.homeClubId);
    final awayPower = _penaltyShootoutPower(fx.awayClubId);

    final homeRoll = homePower + _rng.rangeInt(0, 18);
    final awayRoll = awayPower + _rng.rangeInt(0, 18);

    if (homeRoll > awayRoll) return fx.homeClubId;
    if (awayRoll > homeRoll) return fx.awayClubId;

    return _rng.nextInt(2) == 0 ? fx.homeClubId : fx.awayClubId;
  }

  int _penaltyShootoutPower(String clubId) {
    final basePower = (clubPower10(clubId) * 10).round();

    if (clubId != userClubId) {
      return basePower;
    }

    final squad = _proSquads[userClubId] ?? const <Player>[];

    if (squad.isEmpty) return basePower;

    var totalPenalti = 0;
    var totalConsistencia = 0;

    for (final p in squad) {
      totalPenalti += p.penalti;
      totalConsistencia += p.consistencia;
    }

    final avgPenalti10 = totalPenalti / squad.length;
    final avgConsistencia10 = totalConsistencia / squad.length;

    final penaltyComponent = (avgPenalti10 * 10).round();
    final consistencyComponent = (avgConsistencia10 * 10).round();

    final value = (basePower * 0.45) +
        (penaltyComponent * 0.35) +
        (consistencyComponent * 0.20);

    return value.round().clamp(1, 100);
  }

  void _applyBrazilCupMatchPrizeIfUserPlayed(CupFixture fx) {
    if (fx.homeGoals == null || fx.awayGoals == null) return;

    final userPlayed =
        fx.homeClubId == userClubId || fx.awayClubId == userClubId;

    if (!userPlayed) return;

    final userGoals =
        fx.homeClubId == userClubId ? fx.homeGoals! : fx.awayGoals!;

    final oppGoals =
        fx.homeClubId == userClubId ? fx.awayGoals! : fx.homeGoals!;

    final prize = _competitionPrizeService.copaBrasilMatchPrize(
      goalsFor: userGoals,
      goalsAgainst: oppGoals,
    );

    if (prize <= 0) return;

    final current = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.applyRestrictedRevenue(
      current: current,
      value: prize,
    );

    _insertNewsIfNew(
      'FINANÇAS — A Copa Brasileira rendeu ${MoneyFormatter.formatCurrency(prize)} ao $userClubName pelo resultado da partida.',
    );
  }

  void _applyBrazilCupPhasePrizeIfUserIsInPhase({
    required int phase,
  }) {
    final userIsInPhase = _brazilCupFixtures.any(
      (fx) =>
          fx.phase == phase &&
          (fx.homeClubId == userClubId || fx.awayClubId == userClubId),
    );

    if (!userIsInPhase) return;

    final prize = _competitionPrizeService.copaBrasilPhasePrizeByPhase(phase);

    if (prize <= 0) return;

    final current = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.applyRestrictedRevenue(
      current: current,
      value: prize,
    );

    _insertNewsIfNew(
      'FINANÇAS — Pela presença na ${_brazilCupPhaseLabel(phase)}, o $userClubName recebeu ${MoneyFormatter.formatCurrency(prize)} da Copa Brasileira.',
    );
  }

  void _applyBrazilCupFinalPrizeIfUserPlayed(CupFixture fx) {
    if (fx.phase != 6) return;
    if (fx.winnerClubId == null) return;

    final userPlayed =
        fx.homeClubId == userClubId || fx.awayClubId == userClubId;

    if (!userPlayed) return;

    final champion = fx.winnerClubId == userClubId;

    final prize = _competitionPrizeService.copaBrasilFinalPrize(
      champion: champion,
    );

    if (prize <= 0) return;

    final current = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.applyRestrictedRevenue(
      current: current,
      value: prize,
    );

    _insertNewsIfNew(
      champion
          ? 'FINANÇAS — O título da Copa Brasileira rendeu ${MoneyFormatter.formatCurrency(prize)} ao $userClubName.'
          : 'FINANÇAS — O vice-campeonato da Copa Brasileira rendeu ${MoneyFormatter.formatCurrency(prize)} ao $userClubName.',
    );
  }

  void _insertUserCupResultNews({
    required CupFixture fixture,
    required CupTieUpdate tieUpdate,
  }) {
    if (fixture.homeGoals == null || fixture.awayGoals == null) return;

    final userPlayed =
        fixture.homeClubId == userClubId || fixture.awayClubId == userClubId;

    if (!userPlayed) return;

    final homeName = clubName(fixture.homeClubId);
    final awayName = clubName(fixture.awayClubId);
    final opponentName = fixture.homeClubId == userClubId ? awayName : homeName;

    lastUserMatch =
        '$homeName ${fixture.homeGoals} x ${fixture.awayGoals} $awayName';

    if (!tieUpdate.tieResolved || tieUpdate.winnerClubId == null) {
      _insertNewsIfNew(
        'Copa Brasileira — $lastUserMatch pela ${fixture.phaseLabel}. A decisão segue aberta para o jogo de volta.',
      );
      return;
    }

    final userWon = tieUpdate.winnerClubId == userClubId;
    final penaltyText = tieUpdate.decidedByPenalties ? ' nos pênaltis' : '';

    if (fixture.phase == 6) {
      _applyBrazilCupFinalPrizeIfUserPlayed(fixture);

      if (userWon) {
        _registerBrazilCupDirectorTrophy();
      }

      _insertNewsIfNew(
        userWon
            ? 'Copa Brasileira — O $userClubName é campeão! O clube venceu $opponentName$penaltyText e levantou a taça nacional.'
            : 'Copa Brasileira — O $userClubName ficou com o vice-campeonato após a decisão contra $opponentName$penaltyText.',
      );

      return;
    }

    _insertNewsIfNew(
      userWon
          ? 'Copa Brasileira — O $userClubName avançou na ${fixture.phaseLabel} após superar $opponentName$penaltyText.'
          : 'Copa Brasileira — O $userClubName foi eliminado na ${fixture.phaseLabel} por $opponentName$penaltyText.',
    );
  }

  void _insertBrazilCupResultsBulletin({
    required List<CupFixture> playedFixtures,
    required List<CupTieUpdate> resolvedTies,
  }) {
    if (playedFixtures.isEmpty) return;

    final phase = playedFixtures.first.phase;
    final label = _brazilCupPhaseLabel(phase);

    if (phase == 6) {
      _insertBrazilCupFinalBulletin(
        fixture: playedFixtures.first,
        tieUpdate: resolvedTies.isNotEmpty ? resolvedTies.first : null,
      );
      return;
    }

    final phaseFixtures =
        playedFixtures.where((fx) => fx.phase == phase).toList();

    if (phaseFixtures.isEmpty) return;

    final buffer = StringBuffer();

    buffer.writeln('Notícias do Mundo — Copa Brasileira: jogos da $label');
    buffer.writeln('');

    for (final fx in phaseFixtures) {
      if (fx.homeGoals == null || fx.awayGoals == null) continue;

      final legLabel =
          _brazilCupPhaseHasTwoLegs(fx.phase) ? 'ida ${fx.leg}' : 'jogo único';

      buffer.writeln(
        '${clubName(fx.homeClubId)} ${fx.homeGoals} x ${fx.awayGoals} ${clubName(fx.awayClubId)} ($legLabel)',
      );
    }

    final winners = resolvedTies
        .map((tie) => tie.winnerClubId)
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .map(clubName)
        .toList();

    if (winners.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('Classificados: ${winners.join(', ')}.');
    }

    final penaltyWinners = resolvedTies
        .where((tie) => tie.decidedByPenalties)
        .map((tie) => tie.winnerClubId)
        .whereType<String>()
        .map(clubName)
        .toList();

    if (penaltyWinners.isNotEmpty) {
      buffer.writeln(
        'Decidido nos pênaltis: ${penaltyWinners.join(', ')}.',
      );
    }

    _insertNewsIfNew(buffer.toString().trim());
  }

  void _insertBrazilCupFinalBulletin({
    required CupFixture fixture,
    required CupTieUpdate? tieUpdate,
  }) {
    if (fixture.homeGoals == null || fixture.awayGoals == null) return;

    final homeName = clubName(fixture.homeClubId);
    final awayName = clubName(fixture.awayClubId);
    final championId = tieUpdate?.winnerClubId ?? fixture.winnerClubId;
    final championName = championId == null ? null : clubName(championId);
    final penaltyText = tieUpdate != null && tieUpdate.decidedByPenalties
        ? ' nos pênaltis'
        : '';

    if (championName == null) {
      _insertNewsIfNew(
        'Notícias do Mundo — Copa Brasileira: final\n\n'
        '$homeName ${fixture.homeGoals} x ${fixture.awayGoals} $awayName.\n\n'
        'A decisão terminou indefinida.',
      );
      return;
    }

    _insertNewsIfNew(
      'Notícias do Mundo — Copa Brasileira: campeão definido\n\n'
      '$homeName ${fixture.homeGoals} x ${fixture.awayGoals} $awayName.\n\n'
      '$championName sagrou-se campeão da Copa Brasileira$penaltyText e levantou a taça nacional.',
    );
  }

  void _maybeBuildNextBrazilCupPhase() {
    for (int phase = 1; phase <= 5; phase++) {
      if (!_cupService.isPhaseResolved(
        fixtures: _brazilCupFixtures,
        phase: phase,
      )) {
        continue;
      }

      final nextPhase = phase + 1;

      final alreadyHasNextPhase = _brazilCupFixtures.any(
        (fx) => fx.phase == nextPhase,
      );

      if (alreadyHasNextPhase) continue;

      final winners = _cupService.winnersOfPhase(
        fixtures: _brazilCupFixtures,
        phase: phase,
      );

      if (winners.length < 2) return;

      final nextFixtures = _cupService.buildNextPhase(
        seasonYear: _seasonYear,
        phase: nextPhase,
        phaseLabel: _brazilCupPhaseLabel(nextPhase),
        qualifiedClubIds: winners,
        dates: _brazilCupPhaseDates(nextPhase),
        rng: _rng,
        twoLegs: _brazilCupPhaseHasTwoLegs(nextPhase),
      );

      _brazilCupFixtures.addAll(nextFixtures);

      _applyBrazilCupPhasePrizeIfUserIsInPhase(phase: nextPhase);
      _insertBrazilCupDrawNews(phase: nextPhase);

      return;
    }
  }

  bool _brazilCupPhaseHasTwoLegs(int phase) {
    return phase >= 1 && phase <= 5;
  }

  List<DateTime> _brazilCupPhaseDates(int phase) {
    return switch (phase) {
      1 => <DateTime>[
          DateTime(_seasonYear, 2, 2),
          DateTime(_seasonYear, 2, 9),
        ],
      2 => <DateTime>[
          DateTime(_seasonYear, 3, 2),
          DateTime(_seasonYear, 3, 9),
        ],
      3 => <DateTime>[
          DateTime(_seasonYear, 4, 2),
          DateTime(_seasonYear, 4, 9),
        ],
      4 => <DateTime>[
          DateTime(_seasonYear, 5, 2),
          DateTime(_seasonYear, 5, 9),
        ],
      5 => <DateTime>[
          DateTime(_seasonYear, 6, 2),
          DateTime(_seasonYear, 6, 9),
        ],
      6 => <DateTime>[
          DateTime(_seasonYear, 7, 2),
        ],
      _ => <DateTime>[
          DateTime(_seasonYear, 2, 2),
        ],
    };
  }

  String _brazilCupPhaseLabel(int phase) {
    return switch (phase) {
      1 => 'Fase 1',
      2 => 'Fase 2',
      3 => 'Oitavas de final',
      4 => 'Quartas de final',
      5 => 'Semifinal',
      6 => 'Final',
      _ => 'Fase $phase',
    };
  }

  void _insertBrazilCupDrawNews({
    required int phase,
  }) {
    final phaseFixtures = _brazilCupFixtures
        .where((fx) => fx.phase == phase && fx.leg == 1)
        .toList();

    if (phaseFixtures.isEmpty) return;

    final buffer = StringBuffer();

    buffer.writeln(
      'Copa Brasileira — Sorteio da ${_brazilCupPhaseLabel(phase)}',
    );
    buffer.writeln('');

    final legInfo = _brazilCupPhaseHasTwoLegs(phase)
        ? 'Confrontos em ida e volta.'
        : 'Final em jogo único.';

    buffer.writeln(legInfo);
    buffer.writeln('');

    for (final fx in phaseFixtures) {
      buffer.writeln(
        '${clubName(fx.homeClubId)} x ${clubName(fx.awayClubId)}',
      );
    }

    final userFixture = phaseFixtures.where(
      (fx) => fx.homeClubId == userClubId || fx.awayClubId == userClubId,
    );

    if (userFixture.isNotEmpty) {
      final fx = userFixture.first;
      final opponent = fx.homeClubId == userClubId
          ? clubName(fx.awayClubId)
          : clubName(fx.homeClubId);

      buffer.writeln('');
      buffer.writeln(
        'Briefing: o $userClubName enfrenta $opponent. Cada fase vale premiação e pressão esportiva.',
      );
    }

    _insertNewsIfNew(buffer.toString().trim());
  }
}
