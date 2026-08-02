part of '../game_state.dart';

extension SimonBolivarHandler on GameState {
  void _bootstrapSimonBolivarForSeason({
    List<String>? brazilQualifiedOverride,
  }) {
    _simonBolivarGroupFixtures.clear();
    _simonBolivarKnockoutFixtures.clear();

    final brazilQualifiedIds =
        brazilQualifiedOverride ?? _buildBrazilSimonBolivarQualifiedIds();

    final qualified =
        _competitionQualificationService.buildSimonBolivarQualifiedClubs(
      brazilQualifiedIds: brazilQualifiedIds,
      defendingChampionIsBrazilian: brazilQualifiedIds.length > 5,
    );

    if (qualified.length != 32) {
      throw StateError(
        'Simón Bolívar precisa de 32 clubes. Recebido: ${qualified.length}',
      );
    }

    final groupFixtures = _simonBolivarService.buildGroupStage(
      seasonYear: _seasonYear,
      qualifiedClubIds: qualified,
      rng: _rng,
    );

    _simonBolivarGroupFixtures.addAll(groupFixtures);

    _insertNewsIfNew(
      'Taça Simón Bolívar — A fase de grupos foi sorteada com 32 clubes sul-americanos.',
    );
  }

  List<String> _buildBrazilSimonBolivarQualifiedIds() {
    final qualified = <String>[];
    final seen = <String>{};

    void addQualified(String? clubId) {
      final id = clubId?.trim();
      if (id == null || id.isEmpty) return;
      if (seen.contains(id)) return;

      seen.add(id);
      qualified.add(id);
    }

    final serieATable = _tableByDiv[DivisionId.brA];

    if (serieATable != null && !serieATable.isEmpty) {
      final sorted = serieATable.getSorted();
      final hasRealTable = sorted.any((e) => e.played > 0);

      if (hasRealTable) {
        for (final entry in sorted.take(4)) {
          addQualified(entry.clubId);
        }
      }
    }

    if (qualified.length < 4) {
      final serieA = List<String>.from(
        _clubIdsByDiv[DivisionId.brA] ?? const <String>[],
      );

      if (serieA.length < 5) {
        throw StateError(
          'Brasil precisa de pelo menos 5 clubes na Série A para montar a Simón Bolívar.',
        );
      }

      serieA.sort((a, b) {
        final power = clubCpuPower10(b).compareTo(
          clubCpuPower10(a),
        );

        if (power != 0) return power;

        return clubName(a).compareTo(
          clubName(b),
        );
      });

      for (final clubId in serieA) {
        if (qualified.length >= 4) break;
        addQualified(clubId);
      }
    }

    final brazilCupChampion = _resolveBrazilCupChampionId();
    addQualified(brazilCupChampion);

    if (qualified.length < 5) {
      final serieAOrder = _currentSerieAOrderForQualification();

      for (final clubId in serieAOrder) {
        if (qualified.length >= 5) break;
        addQualified(clubId);
      }
    }

    final simonChampion = _simonBolivarService.resolveChampion(
      knockoutFixtures: _simonBolivarKnockoutFixtures,
    );

    if (simonChampion != null && _isBrazilianClubId(simonChampion)) {
      addQualified(simonChampion);
    }

    return List.unmodifiable(qualified);
  }

  List<String> _currentSerieAOrderForQualification() {
    final serieATable = _tableByDiv[DivisionId.brA];

    if (serieATable != null && !serieATable.isEmpty) {
      final sorted = serieATable.getSorted();
      final hasRealTable = sorted.any((e) => e.played > 0);

      if (hasRealTable) {
        return sorted.map((e) => e.clubId).toList();
      }
    }

    final serieA = List<String>.from(
      _clubIdsByDiv[DivisionId.brA] ?? const <String>[],
    );

    serieA.sort((a, b) {
      final power = clubCpuPower10(b).compareTo(clubCpuPower10(a));
      if (power != 0) return power;

      return clubName(a).compareTo(clubName(b));
    });

    return serieA;
  }

  String? _resolveBrazilCupChampionId() {
    final finals = _brazilCupFixtures.where((fx) => fx.phase == 6).toList();

    if (finals.isEmpty) return null;

    final finalFixture = finals.first;

    if (finalFixture.resolved &&
        finalFixture.winnerClubId != null &&
        finalFixture.winnerClubId!.trim().isNotEmpty) {
      return finalFixture.winnerClubId;
    }

    if (finalFixture.homeGoals == null || finalFixture.awayGoals == null) {
      return null;
    }

    if (finalFixture.homeGoals! > finalFixture.awayGoals!) {
      return finalFixture.homeClubId;
    }

    if (finalFixture.awayGoals! > finalFixture.homeGoals!) {
      return finalFixture.awayClubId;
    }

    return finalFixture.winnerClubId;
  }

  bool _isBrazilianClubId(String clubId) {
    return (_clubIdsByDiv[DivisionId.brA] ?? const <String>[])
            .contains(clubId) ||
        (_clubIdsByDiv[DivisionId.brB] ?? const <String>[]).contains(clubId) ||
        (_clubIdsByDiv[DivisionId.brC] ?? const <String>[]).contains(clubId) ||
        (_clubIdsByDiv[DivisionId.brD] ?? const <String>[]).contains(clubId);
  }

  void _simulateSimonBolivarBetweenDates({
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    _simulateSimonBolivarGroupBetweenDates(
      fromDate: fromDate,
      toDate: toDate,
    );

    _maybeBuildSimonBolivarRoundOf16();

    _simulateSimonBolivarKnockoutBetweenDates(
      fromDate: fromDate,
      toDate: toDate,
    );

    _maybeAdvanceSimonBolivarKnockout();

    _maybeFinishSimonBolivar();
  }

  void _simulateSimonBolivarGroupBetweenDates({
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    if (_simonBolivarGroupFixtures.isEmpty) return;

    final indexesToPlay = <int>[];

    for (int i = 0; i < _simonBolivarGroupFixtures.length; i++) {
      final fx = _simonBolivarGroupFixtures[i];

      if (fx.isPlayed) continue;

      final isAfterFrom = fx.date.isAfter(fromDate);
      final isUntilTo = !fx.date.isAfter(toDate);

      if (isAfterFrom && isUntilTo) {
        indexesToPlay.add(i);
      }
    }

    if (indexesToPlay.isEmpty) return;

    final playedFixtures = <SimonBolivarGroupFixture>[];

    for (final index in indexesToPlay) {
      final fx = _simonBolivarGroupFixtures[index];

      final result = _simulateSimonBolivarGroupFixture(fx);

      final updated = fx.copyWith(
        homeGoals: result.homeGoals,
        awayGoals: result.awayGoals,
      );

      _simonBolivarGroupFixtures[index] = updated;

      playedFixtures.add(updated);

      _recordSimonBolivarGroupMatchInDirectorCareer(updated);
      _insertUserSimonBolivarResultNews(updated);
    }

    _insertSimonBolivarGroupRoundBulletin(playedFixtures);
  }

  void _recordSimonBolivarGroupMatchInDirectorCareer(
    SimonBolivarGroupFixture fixture,
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

  MatchResult _simulateSimonBolivarGroupFixture(
    SimonBolivarGroupFixture fx,
  ) {
    final pseudoFixture = Fixture(
      round: 0,
      homeClubId: fx.homeClubId,
      awayClubId: fx.awayClubId,
    );

    return _simulateMatch(pseudoFixture);
  }

  void _simulateSimonBolivarKnockoutBetweenDates({
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    if (_simonBolivarKnockoutFixtures.isEmpty) return;

    final indexesToPlay = <int>[];

    for (int i = 0; i < _simonBolivarKnockoutFixtures.length; i++) {
      final fx = _simonBolivarKnockoutFixtures[i];

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
      final fx = _simonBolivarKnockoutFixtures[index];

      final result = _simulateSimonBolivarKnockoutFixture(fx);

      final penaltyWinner = _pickPenaltyWinnerForFixture(fx);

      final update = _cupService.applyKnockoutFixtureResult(
        fixtures: _simonBolivarKnockoutFixtures,
        fixture: fx,
        homeGoals: result.homeGoals,
        awayGoals: result.awayGoals,
        rng: _rng,
        penaltyWinnerClubId: penaltyWinner,
      );

      for (final updatedFixture in update.fixtures) {
        final idx = _simonBolivarKnockoutFixtures.indexWhere(
          (item) => item.id == updatedFixture.id,
        );

        if (idx >= 0) {
          _simonBolivarKnockoutFixtures[idx] = updatedFixture;
        }
      }

      final played = _simonBolivarKnockoutFixtures.firstWhere(
        (item) => item.id == fx.id,
        orElse: () => fx,
      );

      playedFixtures.add(played);

      if (update.tieResolved) {
        resolvedTies.add(update);
      }

      _recordSimonBolivarKnockoutMatchInDirectorCareer(played);

      _insertUserSimonBolivarKnockoutResultNews(
        fixture: played,
        tieUpdate: update,
      );
    }

    _insertSimonBolivarKnockoutBulletin(
      playedFixtures: playedFixtures,
      resolvedTies: resolvedTies,
    );
  }

  void _recordSimonBolivarKnockoutMatchInDirectorCareer(
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

  void _registerSimonBolivarDirectorTrophy() {
    _ensureDirectorCareerForCurrentSeason();

    final career = _directorCareer;
    if (career == null) return;

    _directorCareer = career.registerTrophy(
      competitionId: 'SBV',
      competitionName: 'Taça Simón Bolívar',
      seasonYear: _seasonYear,
      clubId: userClubId,
      clubName: userClubName,
    );
  }

  MatchResult _simulateSimonBolivarKnockoutFixture(
    CupFixture fx,
  ) {
    final pseudoFixture = Fixture(
      round: 0,
      homeClubId: fx.homeClubId,
      awayClubId: fx.awayClubId,
    );

    return _simulateMatch(pseudoFixture);
  }

  void _maybeBuildSimonBolivarRoundOf16() {
    if (_simonBolivarKnockoutFixtures.isNotEmpty) return;

    final resolved = _simonBolivarService.isGroupStageResolved(
      fixtures: _simonBolivarGroupFixtures,
    );

    if (!resolved) return;

    final roundOf16 = _simonBolivarService.buildRoundOf16(
      seasonYear: _seasonYear,
      groupFixtures: _simonBolivarGroupFixtures,
    );

    if (roundOf16.isEmpty) {
      _insertNewsIfNew(
        'Taça Simón Bolívar — A fase de grupos terminou, mas houve erro ao montar as oitavas.',
      );
      return;
    }

    _simonBolivarKnockoutFixtures.addAll(roundOf16);

    final qualified = _simonBolivarService.qualifiedFromGroups(
      fixtures: _simonBolivarGroupFixtures,
    );

    final names = qualified.map(clubName).toList();

    _insertNewsIfNew(
      'Taça Simón Bolívar — Fase de grupos encerrada. Classificados às oitavas: ${names.join(', ')}.',
    );

    _insertSimonBolivarRoundOf16DrawNews();
  }

  void _maybeAdvanceSimonBolivarKnockout() {
    if (_simonBolivarKnockoutFixtures.isEmpty) return;

    final nextFixtures = _simonBolivarService.buildNextKnockoutPhase(
      seasonYear: _seasonYear,
      knockoutFixtures: _simonBolivarKnockoutFixtures,
    );

    if (nextFixtures.isEmpty) return;

    final alreadyExists = _simonBolivarKnockoutFixtures.any(
      (fx) => fx.phase == nextFixtures.first.phase,
    );

    if (alreadyExists) return;

    _simonBolivarKnockoutFixtures.addAll(nextFixtures);

    _insertSimonBolivarKnockoutDrawNews(nextFixtures);
  }

  void _maybeFinishSimonBolivar() {
    final championId = _simonBolivarService.resolveChampion(
      knockoutFixtures: _simonBolivarKnockoutFixtures,
    );

    if (championId == null) return;

    if (championId == userClubId) {
      _registerSimonBolivarDirectorTrophy();
    }

    final championName = clubName(championId);

    final alreadyAnnounced = _newsFeed.any((line) {
      final text = line.toLowerCase();

      return text.contains('taça simón bolívar') &&
          text.contains(championName.toLowerCase()) &&
          text.contains('grande campeão continental');
    });

    if (alreadyAnnounced) return;

    _insertNewsIfNew(
      'Taça Simón Bolívar — $championName é o grande campeão continental da temporada!',
    );
  }

  void _insertSimonBolivarRoundOf16DrawNews() {
    final fixtures = _simonBolivarKnockoutFixtures
        .where((fx) => fx.phase == 1 && fx.leg == 1)
        .toList();

    if (fixtures.isEmpty) return;

    final buffer = StringBuffer();

    buffer.writeln('Taça Simón Bolívar — Sorteio das oitavas de final');
    buffer.writeln('');
    buffer.writeln('Confrontos em ida e volta.');
    buffer.writeln('');

    for (final fx in fixtures) {
      buffer.writeln(
        '${clubName(fx.homeClubId)} x ${clubName(fx.awayClubId)}',
      );
    }

    _insertNewsIfNew(buffer.toString().trim());
  }

  void _insertSimonBolivarKnockoutDrawNews(
    List<CupFixture> fixtures,
  ) {
    if (fixtures.isEmpty) return;

    final phaseLabel = _simonBolivarService.knockoutPhaseLabel(
      fixtures.first.phase,
    );

    final firstLegs = fixtures.where((fx) => fx.leg == 1).toList();

    final buffer = StringBuffer();

    buffer.writeln('Taça Simón Bolívar — $phaseLabel definidos');
    buffer.writeln('');

    if (_simonBolivarService.knockoutPhaseHasTwoLegs(fixtures.first.phase)) {
      buffer.writeln('Confrontos em ida e volta.');
    } else {
      buffer.writeln('Confronto em jogo único.');
    }

    buffer.writeln('');

    for (final fx in firstLegs) {
      buffer.writeln(
        '${clubName(fx.homeClubId)} x ${clubName(fx.awayClubId)}',
      );
    }

    _insertNewsIfNew(buffer.toString().trim());
  }

  void _insertUserSimonBolivarResultNews(
    SimonBolivarGroupFixture fixture,
  ) {
    if (fixture.homeGoals == null || fixture.awayGoals == null) return;

    final userPlayed =
        fixture.homeClubId == userClubId || fixture.awayClubId == userClubId;

    if (!userPlayed) return;

    final homeName = clubName(fixture.homeClubId);
    final awayName = clubName(fixture.awayClubId);

    lastUserMatch =
        '$homeName ${fixture.homeGoals} x ${fixture.awayGoals} $awayName';

    _insertNewsIfNew(
      'Taça Simón Bolívar — $lastUserMatch pelo Grupo ${fixture.groupId}.',
    );
  }

  void _insertUserSimonBolivarKnockoutResultNews({
    required CupFixture fixture,
    required CupTieUpdate tieUpdate,
  }) {
    if (fixture.homeGoals == null || fixture.awayGoals == null) return;

    final userPlayed =
        fixture.homeClubId == userClubId || fixture.awayClubId == userClubId;

    if (!userPlayed) return;

    final homeName = clubName(fixture.homeClubId);
    final awayName = clubName(fixture.awayClubId);
    final phaseLabel = _simonBolivarService.knockoutPhaseLabel(fixture.phase);

    lastUserMatch =
        '$homeName ${fixture.homeGoals} x ${fixture.awayGoals} $awayName';

    if (!tieUpdate.tieResolved || tieUpdate.winnerClubId == null) {
      _insertNewsIfNew(
        'Taça Simón Bolívar — $lastUserMatch pelo $phaseLabel. O confronto segue aberto.',
      );
      return;
    }

    final userWon = tieUpdate.winnerClubId == userClubId;
    final penaltyText = tieUpdate.decidedByPenalties ? ' nos pênaltis' : '';
    final opponentName = _opponentNameFromCupFixture(fixture);

    if (fixture.phase == 4) {
      if (userWon) {
        _registerSimonBolivarDirectorTrophy();
      }

      _insertNewsIfNew(
        userWon
            ? 'Taça Simón Bolívar — O $userClubName é campeão continental! Vitória sobre $opponentName$penaltyText na grande final.'
            : 'Taça Simón Bolívar — O $userClubName fica com o vice continental após a final contra $opponentName$penaltyText.',
      );

      return;
    }

    _insertNewsIfNew(
      userWon
          ? 'Taça Simón Bolívar — O $userClubName avançou no $phaseLabel após superar $opponentName$penaltyText.'
          : 'Taça Simón Bolívar — O $userClubName foi eliminado no $phaseLabel por $opponentName$penaltyText.',
    );
  }

  String _opponentNameFromCupFixture(CupFixture fixture) {
    if (fixture.homeClubId == userClubId) {
      return clubName(fixture.awayClubId);
    }

    if (fixture.awayClubId == userClubId) {
      return clubName(fixture.homeClubId);
    }

    return 'o adversário';
  }

  void _insertSimonBolivarGroupRoundBulletin(
    List<SimonBolivarGroupFixture> playedFixtures,
  ) {
    if (playedFixtures.isEmpty) return;

    final round = playedFixtures.first.round;

    final fixtures = playedFixtures.where((fx) => fx.round == round).toList();

    if (fixtures.isEmpty) return;

    final buffer = StringBuffer();

    buffer.writeln(
      'Notícias do Mundo — Taça Simón Bolívar: rodada $round da fase de grupos',
    );
    buffer.writeln('');

    for (final fx in fixtures) {
      if (fx.homeGoals == null || fx.awayGoals == null) continue;

      buffer.writeln(
        'Grupo ${fx.groupId}: ${clubName(fx.homeClubId)} ${fx.homeGoals} x ${fx.awayGoals} ${clubName(fx.awayClubId)}',
      );
    }

    _insertNewsIfNew(buffer.toString().trim());
  }

  void _insertSimonBolivarKnockoutBulletin({
    required List<CupFixture> playedFixtures,
    required List<CupTieUpdate> resolvedTies,
  }) {
    if (playedFixtures.isEmpty) return;

    final phase = playedFixtures.first.phase;
    final leg = playedFixtures.first.leg;
    final phaseLabel = _simonBolivarService.knockoutPhaseLabel(phase);

    final fixtures = playedFixtures
        .where((fx) => fx.phase == phase && fx.leg == leg)
        .toList();

    if (fixtures.isEmpty) return;

    final buffer = StringBuffer();

    buffer.writeln(
      'Notícias do Mundo — Taça Simón Bolívar: $phaseLabel, jogo $leg',
    );
    buffer.writeln('');

    for (final fx in fixtures) {
      if (fx.homeGoals == null || fx.awayGoals == null) continue;

      buffer.writeln(
        '${clubName(fx.homeClubId)} ${fx.homeGoals} x ${fx.awayGoals} ${clubName(fx.awayClubId)}',
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

  bool get hasSimonBolivarGroupStage => _simonBolivarGroupFixtures.isNotEmpty;

  bool get hasSimonBolivarKnockout => _simonBolivarKnockoutFixtures.isNotEmpty;
}
