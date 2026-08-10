part of '../game_state.dart';

extension SeasonFlowHandler on GameState {
  Future<void> _autoSaveIfPossible() async {
    try {
      final storage = SaveStorageService();
      final slotId = await storage.loadLastActiveSlotId();

      if (slotId == null || slotId.isEmpty) return;
      if (!isInitialized) return;
      if (userClubId.isEmpty || userClubName.isEmpty) return;

      await storage.saveFromGameState(
        slotId: slotId,
        gs: this,
      );
    } catch (e, st) {
      debugPrint('!!! GameState.autosave ERROR: $e');
      debugPrint('$st');
    }
  }

  void _startSeasonInternal({
    required String division,
    required int seed,
    required String userClubId,
    required String userClubName,
  }) {
    isInitialized = false;
    initError = null;

    try {
      divisionId = division.trim().toUpperCase();
      this.seed = seed;

      this.userClubId = userClubId;
      this.userClubName = userClubName;

      _seasonYear = 2026;
      _rng = SeededRng(seed);

      _playerFactory = PlayerFactory(_rng);
      _marketService = MarketService(
        rng: _rng,
        playerFactory: _playerFactory,
      );
      _scoutService = ScoutService(_rng);

      _newsFeed.clear();
      _newsCategoryByText.clear();

      _departmentMessages.clear();
      _resetUnreadState();

      _observedPlayers.clear();
      _futureArrivals.clear();
      _financeByClub.clear();
      _clubLegacy.clear();

      _scoutTransfers.clear();
      _scoutLoans.clear();
      _scoutFrees.clear();

      _proSquads.clear();
      _clubs.clear();
      _clubNames.clear();
      _cpuClubPower10.clear();
      _seasonByDiv.clear();
      _tableByDiv.clear();

      fixtures.clear();
      table.resetAll();

      _brazilCupFixtures.clear();
      _simonBolivarGroupFixtures.clear();
      _simonBolivarKnockoutFixtures.clear();

      lastUserMatch = null;
      lastUserMatchHomeClubName = null;
      lastUserMatchAwayClubName = null;
      _lastUserMatchSummary = null;
      _lastUserMatchLiveEvents.clear();

      _pendingCheckpoint = null;
      _pendingTransferOffer = null;
      lastSeasonReport = null;
      _expectations = null;
      _seasonStartSnapshot = <Player>[];
      _processedEvolutionMonths.clear();

      userWinStreak = 0;
      userLoseStreak = 0;
      userDrawStreak = 0;

      _annualYouthProcessed = false;

      // Um novo jogo começa com uma carreira limpa.
      //
      // No carregamento, o GameStateSaveHandler restaurará a carreira
      // persistida depois que o mundo-base for reconstruído.
      _directorCareer = null;

      _bootstrapWorldFromCatalog();

      _userCoachLevel = clubCpuCoachLevel(userClubId).clamp(1, 10);

      _userClubStructures = _clampStructuresByComplexo(
        ClubStructuresCatalog.byId(userClubId),
      );

      _bootstrapUserSquadPowerAware();
      _materializeObservedPlayersForClub(userClubId);

      _seasonStartSnapshot = _cloneSquad(
        _proSquads[userClubId] ?? const <Player>[],
      );

      _bootstrapWorldLeagues();
      _initializeTablesForAllDivisions();

      _bootstrapBrazilCupForSeason();
      _bootstrapSimonBolivarForSeason();

      _refreshMarketAndScoutForTransferWindow(
        month: 1,
        announce: false,
      );

      roundIndex = 1;
      seasonEnded = false;

      final userDiv = _userDiv();
      final season = _seasonByDiv[userDiv]!;
      _maxRound = season.totalRounds;

      _currentDate = season.roundDates[1] ?? DateTime(_seasonYear, 1, 2);

      dateStr = _formatDate(_currentDate);

      _syncUserDivisionViews();

      _rebuildSeasonExpectations(
        userTablePosition: _estimatePreSeasonUserTablePosition(),
      );

      final snap = _expectations;

      if (snap != null) {
        _pendingCheckpoint = SeasonCheckpoint(
          round: 1,
          phase: 'preSeason',
          title: 'Briefing da diretoria',
          body:
              'Expectativa da temporada: ${snap.expectedLabel}.\n\n${_buildPreSeasonLegacyContext()}',
          tag: 'neutral',
        );

        _insertNewsIfNew(
          'Cíntia Sánchez, Presidente — Definimos a expectativa da temporada como ${snap.expectedLabel}. Seu trabalho será transformar esse potencial em uma campanha concreta.',
          category: GameMessageCategory.board,
        );

        _insertNewsIfNew(
          _buildPreSeasonLegacyNewsLine(),
          category: GameMessageCategory.legacy,
        );
      }

      isInitialized = true;
    } catch (e, st) {
      initError = 'Falha ao iniciar temporada: $e';

      debugPrint('!!! GameState.startSeason ERROR: $e');
      debugPrint('$st');

      isInitialized = false;
    } finally {
      notifyListeners();
    }
  }

  void _simulateRoundInternal() {
    if (!isInitialized) return;
    if (_maxRound <= 0) return;
    if (seasonEnded) return;

    if (roundIndex < 1) {
      roundIndex = 1;
    }

    _lastUserMatchLiveEvents.clear();

    final currentRound = roundIndex;

    final isSpecialRound = _isSpecialNarrativeRound(currentRound);

    final matchNarrativeService =
        isSpecialRound ? MatchNarrativeService() : null;

    String? specialStyleNarrative;
    String? regularMatchDetailLine;

    UserMatchSummary? userMatchSummary;

    for (final div in DivisionId.values) {
      final season = _seasonByDiv[div];

      if (season == null) continue;

      final roundFixtures = season.fixturesOfRound(currentRound);

      if (roundFixtures.isEmpty) continue;

      final tab = _tableByDiv.putIfAbsent(div, () {
        final table = LeagueTable();

        table.initialize(
          _clubIdsByDiv[div] ?? const <String>[],
        );

        return table;
      });

      for (final fx in roundFixtures) {
        if (fx.played) continue;

        final result = _simulateMatch(fx);

        _markLeagueFixtureAsPlayed(
          division: div,
          fixture: fx,
          homeGoals: result.homeGoals,
          awayGoals: result.awayGoals,
        );

        _tableService.applyMatchResult(
          table: tab,
          homeId: fx.homeClubId,
          awayId: fx.awayClubId,
          homeGoals: result.homeGoals,
          awayGoals: result.awayGoals,
        );

        if (fx.homeClubId == userClubId || fx.awayClubId == userClubId) {
          final isUserHome = fx.homeClubId == userClubId;

          final userGoals = isUserHome ? result.homeGoals : result.awayGoals;
          final oppGoals = isUserHome ? result.awayGoals : result.homeGoals;

          final homeName = clubName(fx.homeClubId);
          final awayName = clubName(fx.awayClubId);

          lastUserMatchHomeClubName = homeName;
          lastUserMatchAwayClubName = awayName;

          lastUserMatch =
              '$homeName ${result.homeGoals} x ${result.awayGoals} $awayName';

          _lastUserMatchLiveEvents = _matchLiveNarrativeService.buildEvents(
            homeClubName: homeName,
            awayClubName: awayName,
            result: result,
            userClubId: userClubId,
            homeClubId: fx.homeClubId,
            awayClubId: fx.awayClubId,
            userTacticalIdentityId:
                selectedCoachStaffOrFallback.tacticalIdentityId,
            userSquad: _userMatchEventPool(),
          );

          _recordDirectorOfficialMatch(
            goalsFor: userGoals,
            goalsAgainst: oppGoals,
          );

          _updateUserStreak(
            userGoals,
            oppGoals,
          );

          _applyLeagueMatchPrize(
            goalsFor: userGoals,
            goalsAgainst: oppGoals,
          );

          userMatchSummary = _processUserMatchPlayerStats(
            goalsFor: userGoals,
            goalsAgainst: oppGoals,
            isSpecialRound: isSpecialRound,
          );

          if (isUserHome) {
            _applyTicketRevenueForHomeMatch();
          }

          if (isSpecialRound && matchNarrativeService != null) {
            specialStyleNarrative = matchNarrativeService.build(
              clubName: userClubName,
              tacticalIdentityId:
                  selectedCoachStaffOrFallback.tacticalIdentityId,
              coachLevel: userCoachLevel,
              isHome: isUserHome,
              goalsFor: userGoals,
              goalsAgainst: oppGoals,
            );

            if (userMatchSummary.highlightPlayer != null &&
                userMatchSummary.highlightReason != null) {
              final highlightName =
                  userMatchSummary.highlightPlayer!.playerName;

              final reason = userMatchSummary.highlightReason!.trim();

              if (reason.isNotEmpty) {
                specialStyleNarrative =
                    '$specialStyleNarrative Destaque do jogo: $highlightName, que $reason';
              }
            }
          } else {
            regularMatchDetailLine = _buildRegularMatchPlayerDetailLine(
              summary: userMatchSummary,
            );
          }
        }
      }
    }

    final userDiv = _userDiv();
    final userSeason = _seasonByDiv[userDiv]!;

    final previousDate = _currentDate;

    _currentDate = userSeason.roundDates[currentRound] ?? _currentDate;

    dateStr = _formatDate(_currentDate);

    _syncUserDivisionViews();

    _afterRoundUpdates(
      roundJustFinished: currentRound,
    );

    _maybeApplyQuarterEvolution();

    if (_shouldTryGenerateTransferOffer(currentRound)) {
      _maybeGenerateTransferOffer();
    }

    if (_shouldTryGenerateMarketOpportunity(currentRound)) {
      _tryGenerateMarketOpportunity();
    }

    _processNarrativeAfterRound(
      roundJustFinished: currentRound,
      styleNarrative: specialStyleNarrative,
    );

    _mergeRegularMatchDetailIntoLatestNews(
      regularMatchDetailLine,
    );

    if (currentRound >= _maxRound) {
      seasonEnded = true;
      roundIndex = _maxRound;

      _tryRunWorldTournamentsAtSeasonEnd();

      final legacyResult = _legacyRuntimeService.processSeasonEnd(
        clubId: userClubId,
        clubName: userClubName,
        divisionId: _userDiv(),
        tablesByDivision: _tableByDiv,
        legacyMap: _clubLegacy,
      );

      _insertNewsIfNew(
        legacyResult.summaryLine,
        category: GameMessageCategory.legacy,
      );

      _insertNewsIfNew(
        _buildLegacyImpactNewsLine(legacyResult),
        category: GameMessageCategory.legacy,
      );

      _pushEndSeasonLine();

      notifyListeners();
      _autoSaveIfPossible();

      return;
    }

    roundIndex = currentRound + 1;

    final nextDate = userSeason.roundDates[roundIndex] ?? _currentDate;

    _simulateBrazilCupBetweenDates(
      fromDate: previousDate,
      toDate: nextDate,
    );

    _simulateSimonBolivarBetweenDates(
      fromDate: previousDate,
      toDate: nextDate,
    );

    _maybeProcessMonthlyFinance(
      fromDate: previousDate,
      toDate: nextDate,
    );

    _currentDate = nextDate;
    dateStr = _formatDate(_currentDate);

    _maybeRefreshJulyMarketAndScout(
      fromDate: previousDate,
      toDate: nextDate,
    );

    _syncUserDivisionViews();

    notifyListeners();
    _autoSaveIfPossible();
  }

  void _markLeagueFixtureAsPlayed({
    required DivisionId division,
    required Fixture fixture,
    required int homeGoals,
    required int awayGoals,
  }) {
    final season = _seasonByDiv[division];
    if (season == null) return;

    final updatedFixtures = List<Fixture>.from(season.fixtures);

    final index = updatedFixtures.indexWhere((fx) {
      return fx.round == fixture.round &&
          fx.homeClubId == fixture.homeClubId &&
          fx.awayClubId == fixture.awayClubId;
    });

    if (index < 0) return;

    updatedFixtures[index] = updatedFixtures[index].copyWith(
      homeGoals: homeGoals,
      awayGoals: awayGoals,
    );

    _seasonByDiv[division] = season.copyWith(
      fixtures: updatedFixtures,
    );
  }

  void _applyLeagueMatchPrize({
    required int goalsFor,
    required int goalsAgainst,
  }) {
    if (userClubId.isEmpty) return;

    final prize = _competitionPrizeService.leagueMatchPrize(
      division: _userDiv(),
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
    );

    if (prize <= 0) return;

    final current = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.applyRestrictedRevenue(
      current: current,
      value: prize,
    );

    _insertNewsIfNew(
      'FINANÇAS — O clube recebeu ${MoneyFormatter.formatCurrency(prize)} em premiação pelo resultado da rodada.',
      category: GameMessageCategory.finance,
    );
  }

  void _applyTicketRevenueForHomeMatch() {
    if (userClubId.isEmpty) return;

    final result = _ticketRevenueService.calculate(
      divisionId: divisionId,
      stadiumLevel: userStadiumLevel,
      marketingLevel: userMarketingLevel,
      winStreak: userWinStreak,
      drawStreak: userDrawStreak,
      loseStreak: userLoseStreak,
      rng: _rng,
    );

    if (result.amount <= 0) return;

    final current = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.applyFullRevenue(
      current: current,
      value: result.amount,
    );

    _insertNewsIfNew(
      'FINANÇAS — ${result.message}',
      category: GameMessageCategory.finance,
    );
  }

  void _startNextSeasonInternal() {
    if (!isInitialized) return;

    try {
      processEndOfSeasonLoans();

      _tryRunWorldTournamentsAtSeasonEnd();

      final simonBolivarBrazilQualified =
          _buildBrazilSimonBolivarQualifiedIds();

      _applyPromotionAndRelegation();

      final nextSeasonYear = _seasonYear + 1;

      _advanceDirectorCareerToNextSeason(
        nextSeasonYear: nextSeasonYear,
      );

      _seasonYear = nextSeasonYear;

      _ageFootballDirector();

      seed = seed + 1;

      _rng = SeededRng(seed);

      _playerFactory = PlayerFactory(_rng);

      _marketService = MarketService(
        rng: _rng,
        playerFactory: _playerFactory,
      );

      _scoutService = ScoutService(_rng);

      roundIndex = 1;
      seasonEnded = false;

      lastUserMatch = null;
      lastUserMatchHomeClubName = null;
      lastUserMatchAwayClubName = null;
      _lastUserMatchSummary = null;
      _lastUserMatchLiveEvents.clear();

      _newsFeed.clear();
      _newsCategoryByText.clear();

      _departmentMessages.clear();

      _resetUnreadState();

      _scoutTransfers.clear();
      _scoutLoans.clear();
      _scoutFrees.clear();

      _brazilCupFixtures.clear();
      _simonBolivarGroupFixtures.clear();
      _simonBolivarKnockoutFixtures.clear();

      _pendingCheckpoint = null;
      _pendingTransferOffer = null;

      _processedEvolutionMonths.clear();

      lastSeasonReport = null;

      userWinStreak = 0;
      userLoseStreak = 0;
      userDrawStreak = 0;

      _annualYouthProcessed = false;

      _runAnnualYouthIntakeIfNeeded();
      _ageObservedPlayers();

      _userCoachLevel = _userCoachLevel.clamp(1, 10);

      _userClubStructures = _clampStructuresByComplexo(
        _userClubStructures,
      );

      _bootstrapWorldLeagues();

      _initializeTablesForAllDivisions();

      _bootstrapBrazilCupForSeason();

      _bootstrapSimonBolivarForSeason(
        brazilQualifiedOverride: simonBolivarBrazilQualified,
      );

      _refreshMarketAndScoutForTransferWindow(
        month: 1,
        announce: false,
      );

      final userDiv = _userDiv();
      final userSeason = _seasonByDiv[userDiv]!;

      _maxRound = userSeason.totalRounds;

      _currentDate = userSeason.roundDates[1] ?? DateTime(_seasonYear, 1, 2);

      dateStr = _formatDate(_currentDate);

      _processFutureArrivalsForCurrentWindow();

      _runCpuTransferWindow();

      _seasonStartSnapshot = _cloneSquad(
        _proSquads[userClubId] ?? const <Player>[],
      );

      final squad = List<Player>.from(
        _proSquads[userClubId] ?? const <Player>[],
      );

      if (squad.isNotEmpty) {
        _proSquads[userClubId] =
            squad.map((p) => p.resetSeasonStats()).toList();
      }

      _recalculateMonthlyWageForClub(
        userClubId,
      );

      _syncUserDivisionViews();

      _rebuildSeasonExpectations(
        userTablePosition: _estimatePreSeasonUserTablePosition(),
      );

      final snap = _expectations;

      if (snap != null) {
        _pendingCheckpoint = SeasonCheckpoint(
          round: 1,
          phase: 'preSeason',
          title: 'Briefing da diretoria',
          body:
              'Expectativa da temporada: ${snap.expectedLabel}.\n\n${_buildPreSeasonLegacyContext()}',
          tag: 'neutral',
        );

        _insertNewsIfNew(
          'Nova temporada — A diretoria inicia o ano com expectativa de ${snap.expectedLabel}. Agora é hora de provar isso em campo.',
          category: GameMessageCategory.board,
        );

        _insertNewsIfNew(
          _buildPreSeasonLegacyNewsLine(),
          category: GameMessageCategory.legacy,
        );
      }

      notifyListeners();
      _autoSaveIfPossible();
    } catch (e, st) {
      debugPrint(
        '!!! GameState.startNextSeason ERROR: $e',
      );

      debugPrint('$st');

      _insertNewsIfNew(
        'Erro ao iniciar nova temporada: $e',
        category: GameMessageCategory.system,
      );

      notifyListeners();
    }
  }

  void _ensureDirectorCareerForCurrentSeason() {
    if (_directorCareer != null) return;

    final normalizedClubId = userClubId.trim();
    final normalizedClubName = userClubName.trim();

    if (normalizedClubId.isEmpty || normalizedClubName.isEmpty) {
      return;
    }

    _directorCareer = DirectorCareer.initial(
      seasonYear: _seasonYear,
      clubId: normalizedClubId,
      clubName: normalizedClubName,
    ).openClubSpell(
      clubId: normalizedClubId,
      clubName: normalizedClubName,
      startYear: _seasonYear,
    );
  }

  void _recordDirectorOfficialMatch({
    required int goalsFor,
    required int goalsAgainst,
  }) {
    _ensureDirectorCareerForCurrentSeason();

    final career = _directorCareer;
    if (career == null) return;

    _directorCareer = career.registerMatch(
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
    );
  }

  void _advanceDirectorCareerToNextSeason({
    required int nextSeasonYear,
  }) {
    _ensureDirectorCareerForCurrentSeason();

    final career = _directorCareer;
    if (career == null) return;

    _directorCareer = career.startNewSeason(
      seasonYear: nextSeasonYear,
      clubId: userClubId,
      clubName: userClubName,
    );
  }

  void _ageFootballDirector() {
    final director = _footballDirector;
    if (director == null) return;

    _footballDirector = director.copyWith(
      age: director.age + 1,
    );
  }

  void _tryRunWorldTournamentsAtSeasonEnd() {
    try {
      _ensureSimonBolivarCompletedForSeason();

      final simonChampion = _simonBolivarService.resolveChampion(
        knockoutFixtures: _simonBolivarKnockoutFixtures,
      );

      if (simonChampion != null) {
        _recordSimonBolivarSeasonResultIfNeeded(simonChampion);
      }

      _runWorldTournamentsForSeasonEnd();
    } catch (e, st) {
      debugPrint('!!! GameState.worldTournaments ERROR: $e');
      debugPrint('$st');

      _insertNewsIfNew(
        'ATLAS — Erro ao executar torneios mundiais: $e',
        category: GameMessageCategory.system,
      );
    }
  }

  void _initializeTablesForAllDivisions() {
    _tableByDiv.clear();

    for (final div in DivisionId.values) {
      final clubIds = List<String>.from(
        _clubIdsByDiv[div] ?? const <String>[],
      );

      if (clubIds.isEmpty) continue;

      final season = _seasonByDiv[div];

      if (season == null) {
        final table = LeagueTable();
        table.initialize(clubIds);
        _tableByDiv[div] = table;
        continue;
      }

      _tableByDiv[div] = _tableService.buildFromFixtures(
        clubIds: clubIds,
        fixtures: season.fixtures,
      );
    }
  }

  void _insertNewsIfNew(
    String? line, {
    GameMessageCategory category = GameMessageCategory.season,
  }) {
    if (line == null) return;

    final text = line.trim();

    if (text.isEmpty) return;

    if (_newsFeed.isNotEmpty && _newsFeed.first.trim() == text) {
      _newsCategoryByText[text] = category;
      return;
    }

    _newsFeed.insert(0, text);
    _newsCategoryByText[text] = category;
  }

  void _mergeRegularMatchDetailIntoLatestNews(
    String? detailLine,
  ) {
    if (detailLine == null) return;

    final detail = detailLine.trim();

    if (detail.isEmpty) return;

    if (lastUserMatch == null || lastUserMatch!.trim().isEmpty) {
      return;
    }

    final matchLine = lastUserMatch!.trim();

    final index = _newsFeed.indexWhere((line) {
      final text = line.trim();

      return text.contains(matchLine);
    });

    if (index < 0) {
      _insertNewsIfNew(
        detail,
        category: GameMessageCategory.match,
      );
      return;
    }

    final current = _newsFeed[index].trim();

    if (current.contains(detail)) return;

    _newsCategoryByText.remove(current);

    _newsFeed[index] = '$current $detail';
    _newsCategoryByText[_newsFeed[index].trim()] = GameMessageCategory.match;
  }

  bool _isSpecialNarrativeRound(int round) {
    return round == 6 ||
        round == 12 ||
        round == 18 ||
        round == 24 ||
        round == 30;
  }

  String? _buildRegularMatchPlayerDetailLine({
    required UserMatchSummary? summary,
  }) {
    if (summary == null) return null;

    final scorers = summary.scorers;
    final assisters = summary.assisters;

    if (scorers.isEmpty) return null;

    final scorerNames = scorers.map((e) => e.playerName).toList();

    final assistNames = assisters.map((e) => e.playerName).toList();

    final hasDifferentAssist =
        assistNames.isNotEmpty && assistNames.first != scorerNames.first;

    if (scorers.length == 1 && hasDifferentAssist) {
      return '${scorerNames.first} marcou para o $userClubName, com assistência de ${assistNames.first}.';
    }

    if (scorers.length == 1) {
      return '${scorerNames.first} marcou o gol do $userClubName na partida.';
    }

    if (scorers.length == 2) {
      return '${scorerNames[0]} e ${scorerNames[1]} marcaram os gols do $userClubName.';
    }

    final first = scorerNames.first;

    final others = scorerNames.skip(1).join(', ');

    return '$first, $others marcaram os gols do $userClubName.';
  }

  String _buildPreSeasonLegacyContext() {
    final seasons = userLegacySeasons;

    if (seasons <= 0) {
      return 'Contexto histórico: o trabalho ainda não tem memória acumulada no clube. Esta temporada pode começar a construir essa relação.';
    }

    return 'Contexto histórico: $userLegacySummaryLine';
  }

  String _buildPreSeasonLegacyNewsLine() {
    final seasons = userLegacySeasons;

    if (seasons <= 0) {
      return 'MEMÓRIA DO CLUBE — O projeto esportivo começa sem legado acumulado. A temporada atual será a primeira grande referência da passagem.';
    }

    return 'MEMÓRIA DO CLUBE — $userLegacySummaryLine';
  }

  String _buildLegacyImpactNewsLine(LegacySeasonResult result) {
    final points = result.seasonPoints;
    final total = result.totalPoints;
    final label = ClubLegacyHelper.label(total);
    final pressure = ClubLegacyHelper.pressureLabel(total);

    if (points >= 10) {
      return 'LEGADO — A temporada adiciona grande peso histórico ao trabalho. Pontuação da campanha: +$points. Status atual: $label, com $pressure.';
    }

    if (points >= 3) {
      return 'LEGADO — A campanha fortalece a passagem no clube. Pontuação da campanha: +$points. Status atual: $label, com $pressure.';
    }

    if (points >= 1) {
      return 'LEGADO — A temporada traz ganho discreto de reputação. Pontuação da campanha: +$points. Status atual: $label, com $pressure.';
    }

    if (points == 0) {
      return 'LEGADO — A temporada não altera muito a memória da passagem. Pontuação da campanha: $points. Status atual: $label, com $pressure.';
    }

    return 'LEGADO — A campanha pesa negativamente na memória do clube. Pontuação da campanha: $points. Status atual: $label, com $pressure.';
  }
}
