part of '../game_state.dart';

extension GameStateSaveHandler on GameState {
  Map<String, dynamic> exportStateForSave() {
    final userSquad = _proSquads[userClubId] ?? const <Player>[];
    final staff = selectedCoachStaffOrFallback;

    return <String, dynamic>{
      'saveVersion': 6,
      'slotId': currentSaveSlotId,
      'clubId': userClubId,
      'clubName': userClubName,
      'divisionId': divisionId,
      'seed': seed,
      'seasonYear': _seasonYear,
      'roundIndex': roundIndex,
      'dateStr': dateStr,
      'currentDateIso': _currentDate.toIso8601String(),
      'seasonEnded': seasonEnded,
      'coachStaffId': staff.id,
      'userCoachLevel': staff.level,
      'coachStaff': <String, dynamic>{
        'id': staff.id,
        'level': staff.level,
        'contractEndYear': staff.contractEndYear,
        'prestige': staff.prestige.name,
        'monthlySalary': staff.monthlySalary,
      },
      'userWinStreak': userWinStreak,
      'userLoseStreak': userLoseStreak,
      'userDrawStreak': userDrawStreak,
      'lastUserMatch': lastUserMatch,
      'leagueSeasons': _leagueSeasonsToJson(),
      'brazilCupFixtures': _brazilCupFixtures.map(_cupFixtureToJson).toList(),
      'readState': <String, dynamic>{
        'readNewsCount': _readNewsCount,
        'readDepartmentMessagesCount': _readDepartmentMessagesCount,
        'readMatchNewsCount': _readMatchNewsCount,
        'readMarketNewsCount': _readMarketNewsCount,
        'readWorldNewsCount': _readWorldNewsCount,
        'readFinanceNewsCount': _readFinanceNewsCount,
        'readTrainingNewsCount': _readTrainingNewsCount,
        'readSeasonNewsCount': _readSeasonNewsCount,
      },
      'finance': _financeToJson(userFinance),
      'financeByClub': _financeByClub.map(
        (clubId, finance) => MapEntry(clubId, _financeToJson(finance)),
      ),
      'structures': _structuresToJson(_userClubStructures),
      'clubLegacy': _clubLegacy.map(
        (clubId, legacy) => MapEntry(
          clubId,
          <String, dynamic>{
            'clubId': legacy.clubId,
            'totalPoints': legacy.totalPoints,
            'seasons': legacy.seasons,
          },
        ),
      ),
      'userClubSummary': <String, dynamic>{
        'caixa': userCaixaLivre,
        'operacional': userOperationalCash,
        'balance': userBalance,
        'debt': userDebt,
        'monthlyWage': userMonthlyWage,
      },
      'userSquad': userSquad.map((p) => p.toJson()).toList(),
      'market': <String, dynamic>{
        'transferPlayers':
            _marketService.transferPlayers.map((p) => p.toJson()).toList(),
        'loanPlayers':
            _marketService.loanPlayers.map((p) => p.toJson()).toList(),
        'freeAgents': _marketService.freeAgents.map((p) => p.toJson()).toList(),
      },
      'scout': <String, dynamic>{
        'transfers': _scoutTransfers.map((t) => t.toJson()).toList(),
        'loans': _scoutLoans.map((t) => t.toJson()).toList(),
        'frees': _scoutFrees.map((t) => t.toJson()).toList(),
      },
      'observedPlayers': _observedPlayers.map((p) => p.toJson()).toList(),
      'futureArrivals': _futureArrivals.map((a) => a.toJson()).toList(),
      'pendingTransferOffer': _pendingTransferOffer?.toJson(),
      'simonBolivar': <String, dynamic>{
        'groupFixtures': _simonBolivarGroupFixtures
            .map(_simonBolivarGroupFixtureToJson)
            .toList(),
        'knockoutFixtures':
            _simonBolivarKnockoutFixtures.map(_cupFixtureToJson).toList(),
      },
      'newsFeed': List<String>.from(_newsFeed),
      'newsCategories': _newsCategoryByText.map(
        (text, category) => MapEntry(text, category.name),
      ),
    };
  }

  void restoreRuntimeStateFromSave(Map<String, dynamic> state) {
    final currentDateIso = state['currentDateIso'] as String?;
    if (currentDateIso != null && currentDateIso.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(currentDateIso);
      if (parsed != null) {
        _currentDate = parsed;
        dateStr = _formatDate(_currentDate);
      }
    }

    _seasonYear = _readInt(state['seasonYear'], fallback: _seasonYear);
    roundIndex = _readInt(state['roundIndex'], fallback: roundIndex);
    seasonEnded = state['seasonEnded'] == true;
    lastUserMatch = state['lastUserMatch'] as String?;

    userWinStreak = _readInt(state['userWinStreak'], fallback: userWinStreak);
    userLoseStreak =
        _readInt(state['userLoseStreak'], fallback: userLoseStreak);
    userDrawStreak =
        _readInt(state['userDrawStreak'], fallback: userDrawStreak);

    _restoreCoachStaffFromSave(state);
    _restoreLeagueSeasonsFromSave(state);
    _restoreBrazilCupFromSave(state);

    final structuresMap =
        (state['structures'] as Map?)?.cast<String, dynamic>();
    if (structuresMap != null) {
      _userClubStructures = _clampStructuresByComplexo(
        ClubStructures(
          complexo: _readInt(structuresMap['complexo'], fallback: 1),
          ct: _readInt(structuresMap['ct'], fallback: 1),
          base: _readInt(structuresMap['base'], fallback: 1),
          scout: _readInt(structuresMap['scout'], fallback: 1),
          financeiro: _readInt(structuresMap['financeiro'], fallback: 1),
          marketing: _readInt(structuresMap['marketing'], fallback: 1),
          comunicacao: _readInt(structuresMap['comunicacao'], fallback: 1),
          medico: _readInt(structuresMap['medico'], fallback: 1),
          estadio: _readInt(structuresMap['estadio'], fallback: 1),
        ),
      );
    }

    final financeByClubMap =
        (state['financeByClub'] as Map?)?.cast<String, dynamic>();

    if (financeByClubMap != null && financeByClubMap.isNotEmpty) {
      _financeByClub.clear();

      for (final entry in financeByClubMap.entries) {
        final financeMap = (entry.value as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};

        _financeByClub[entry.key] = _financeFromJson(financeMap);
      }
    } else {
      final financeMap = (state['finance'] as Map?)?.cast<String, dynamic>();
      if (financeMap != null) {
        _financeByClub[userClubId] = _financeFromJson(financeMap);
      }
    }

    final legacyMap = (state['clubLegacy'] as Map?)?.cast<String, dynamic>();
    if (legacyMap != null) {
      _clubLegacy.clear();

      for (final entry in legacyMap.entries) {
        final value = (entry.value as Map?)?.cast<String, dynamic>() ??
            <String, dynamic>{};

        final clubId = (value['clubId'] as String?) ?? entry.key;

        _clubLegacy[entry.key] = ClubLegacyEntry(
          clubId: clubId,
          totalPoints: _readInt(value['totalPoints'], fallback: 0),
          seasons: _readInt(value['seasons'], fallback: 0),
        );
      }
    }

    final rawUserSquad = state['userSquad'] as List?;
    if (rawUserSquad != null) {
      _proSquads[userClubId] = rawUserSquad
          .whereType<Map>()
          .map((e) => Player.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    final marketMap = (state['market'] as Map?)?.cast<String, dynamic>();
    if (marketMap != null) {
      _marketService.clearMarket();

      _marketService.addManyTransferPlayers(
        _playersFromRawList(marketMap['transferPlayers']),
      );

      _marketService.addManyLoanPlayers(
        _playersFromRawList(marketMap['loanPlayers']),
      );

      _marketService.addManyFreeAgents(
        _playersFromRawList(marketMap['freeAgents']),
      );
    }

    final scoutMap = (state['scout'] as Map?)?.cast<String, dynamic>();
    if (scoutMap != null) {
      _scoutTransfers
        ..clear()
        ..addAll(_targetsFromRawList(scoutMap['transfers']));

      _scoutLoans
        ..clear()
        ..addAll(_targetsFromRawList(scoutMap['loans']));

      _scoutFrees
        ..clear()
        ..addAll(_targetsFromRawList(scoutMap['frees']));
    }

    final rawObserved = state['observedPlayers'] as List?;
    if (rawObserved != null) {
      _observedPlayers
        ..clear()
        ..addAll(
          rawObserved.whereType<Map>().map(
                (e) => ObservedPlayer.fromJson(e.cast<String, dynamic>()),
              ),
        );
    }

    final rawFutureArrivals = state['futureArrivals'] as List?;
    if (rawFutureArrivals != null) {
      _futureArrivals
        ..clear()
        ..addAll(
          rawFutureArrivals.whereType<Map>().map(
                (e) => FutureArrival.fromJson(e.cast<String, dynamic>()),
              ),
        );
    }

    final pendingMap =
        (state['pendingTransferOffer'] as Map?)?.cast<String, dynamic>();

    _pendingTransferOffer =
        pendingMap == null ? null : TransferOffer.fromJson(pendingMap);

    final simonBolivarMap =
        (state['simonBolivar'] as Map?)?.cast<String, dynamic>();

    if (simonBolivarMap != null) {
      final rawGroupFixtures = simonBolivarMap['groupFixtures'] as List?;
      if (rawGroupFixtures != null) {
        _simonBolivarGroupFixtures
          ..clear()
          ..addAll(
            rawGroupFixtures.whereType<Map>().map(
                  (e) => _simonBolivarGroupFixtureFromJson(
                    e.cast<String, dynamic>(),
                  ),
                ),
          );
      }

      final rawKnockoutFixtures = simonBolivarMap['knockoutFixtures'] as List?;
      if (rawKnockoutFixtures != null) {
        _simonBolivarKnockoutFixtures
          ..clear()
          ..addAll(
            rawKnockoutFixtures.whereType<Map>().map(
                  (e) => _cupFixtureFromJson(
                    e.cast<String, dynamic>(),
                  ),
                ),
          );
      }
    }

    final rawNews = state['newsFeed'] as List?;
    _newsFeed.clear();

    if (rawNews != null) {
      _newsFeed.addAll(rawNews.map((e) => e.toString()));
    }

    _newsCategoryByText.clear();

    final rawCategories =
        (state['newsCategories'] as Map?)?.cast<String, dynamic>();

    if (rawCategories != null) {
      for (final entry in rawCategories.entries) {
        final text = entry.key.trim();
        if (text.isEmpty) continue;

        _newsCategoryByText[text] = GameMessage.categoryFromString(
          entry.value?.toString(),
          fallback: _inferLegacyNewsCategory(text),
        );
      }
    }

    for (final text in _newsFeed) {
      final key = text.trim();
      if (key.isEmpty) continue;

      _newsCategoryByText.putIfAbsent(
        key,
        () => _inferLegacyNewsCategory(key),
      );
    }

    final readMap = (state['readState'] as Map?)?.cast<String, dynamic>();
    if (readMap != null) {
      _readNewsCount = _readInt(readMap['readNewsCount'], fallback: 0);
      _readDepartmentMessagesCount =
          _readInt(readMap['readDepartmentMessagesCount'], fallback: 0);

      _readMatchNewsCount =
          _readInt(readMap['readMatchNewsCount'], fallback: 0);
      _readMarketNewsCount =
          _readInt(readMap['readMarketNewsCount'], fallback: 0);
      _readWorldNewsCount =
          _readInt(readMap['readWorldNewsCount'], fallback: 0);
      _readFinanceNewsCount =
          _readInt(readMap['readFinanceNewsCount'], fallback: 0);
      _readTrainingNewsCount =
          _readInt(readMap['readTrainingNewsCount'], fallback: 0);
      _readSeasonNewsCount =
          _readInt(readMap['readSeasonNewsCount'], fallback: 0);
    }

    _recalculateMonthlyWageForClub(userClubId);
    _syncUserDivisionViews();
  }

  void _restoreCoachStaffFromSave(Map<String, dynamic> state) {
    final staffMap = (state['coachStaff'] as Map?)?.cast<String, dynamic>();

    final id = (staffMap?['id'] as String?) ??
        (state['coachStaffId'] as String?) ??
        selectedCoachStaffOrFallback.id;

    final base = CoachStaffCatalog.all.firstWhere(
      (e) => e.id == id,
      orElse: () => selectedCoachStaffOrFallback,
    );

    final level = _readInt(
      staffMap?['level'] ?? state['userCoachLevel'],
      fallback: base.level,
    ).clamp(1, 10);

    final contractEndYear = _readInt(
      staffMap?['contractEndYear'],
      fallback: base.contractEndYear,
    );

    final prestige = _parseCoachPrestige(
      staffMap?['prestige'],
      fallback: base.prestige,
    );

    _selectedCoachStaff = base.copyWith(
      level: level,
      contractEndYear: contractEndYear,
      prestige: prestige,
    );

    _userCoachLevel = level;
  }

  CoachPrestige _parseCoachPrestige(
    dynamic raw, {
    required CoachPrestige fallback,
  }) {
    final value = (raw ?? '').toString();

    for (final prestige in CoachPrestige.values) {
      if (prestige.name == value) return prestige;
    }

    return fallback;
  }

  Future<void> _autoSave() async {
    try {
      await SaveStorageService().saveFromGameState(
        slotId: currentSaveSlotId,
        gs: this,
      );
    } catch (e) {
      debugPrint('Erro no autosave: $e');
    }
  }

  Map<String, dynamic> _leagueSeasonsToJson() {
    final out = <String, dynamic>{};

    for (final entry in _seasonByDiv.entries) {
      out[_toDivisionStr(entry.key)] = entry.value.toJson();
    }

    return out;
  }

  void _restoreLeagueSeasonsFromSave(Map<String, dynamic> state) {
    final raw = (state['leagueSeasons'] as Map?)?.cast<String, dynamic>();
    if (raw == null || raw.isEmpty) {
      _initializeTablesForAllDivisions();
      return;
    }

    _seasonByDiv.clear();

    for (final entry in raw.entries) {
      final div = _parseDivisionId(entry.key);
      if (div == null) continue;

      final seasonMap = (entry.value as Map?)?.cast<String, dynamic>();
      if (seasonMap == null) continue;

      final season = LeagueSeasonBundle.fromJson(seasonMap);

      if (season.fixtures.isEmpty) continue;

      _seasonByDiv[div] = season;
    }

    _initializeTablesForAllDivisions();

    final userDiv = _userDiv();
    final userSeason = _seasonByDiv[userDiv];

    if (userSeason != null) {
      _maxRound = userSeason.totalRounds;
    }
  }

  void _restoreBrazilCupFromSave(Map<String, dynamic> state) {
    final raw = state['brazilCupFixtures'] as List?;
    if (raw == null) return;

    _brazilCupFixtures
      ..clear()
      ..addAll(
        raw.whereType<Map>().map(
              (e) => _cupFixtureFromJson(e.cast<String, dynamic>()),
            ),
      );
  }

  List<Player> _playersFromRawList(dynamic raw) {
    final list = raw as List?;
    if (list == null) return <Player>[];

    return list
        .whereType<Map>()
        .map((e) => Player.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  List<ScoutTarget> _targetsFromRawList(dynamic raw) {
    final list = raw as List?;
    if (list == null) return <ScoutTarget>[];

    return list
        .whereType<Map>()
        .map((e) => ScoutTarget.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  GameMessageCategory _inferLegacyNewsCategory(String text) {
    final lower = text.toLowerCase();

    if (lower.startsWith('finanças') ||
        lower.contains('financeiro') ||
        lower.contains('bilheteria') ||
        lower.contains('patrocínio') ||
        lower.contains('patrocinio') ||
        lower.contains('caixa') ||
        lower.contains('fluxo operacional') ||
        lower.contains('folha salarial') ||
        lower.contains('premiação') ||
        lower.contains('premiacao')) {
      return GameMessageCategory.finance;
    }

    if (lower.startsWith('legado') ||
        lower.startsWith('memória do clube') ||
        lower.startsWith('memoria do clube') ||
        lower.contains('peso histórico') ||
        lower.contains('peso historico') ||
        lower.contains('reputação') ||
        lower.contains('reputacao')) {
      return GameMessageCategory.legacy;
    }

    if (lower.startsWith('briefing da diretoria') ||
        lower.startsWith('diretoria') ||
        lower.contains('objetivo da diretoria') ||
        lower.contains('expectativa da temporada')) {
      return GameMessageCategory.board;
    }

    if (lower.contains('copa brasileira') ||
        lower.contains('copa do brasil') ||
        lower.contains('taça simón bolívar') ||
        lower.contains('taça simon bolivar') ||
        lower.contains('simón bolívar') ||
        lower.contains('simon bolivar') ||
        lower.contains('atlas club') ||
        lower.contains('atlas champions')) {
      return GameMessageCategory.competition;
    }

    if (lower.contains('proposta') ||
        lower.contains('negociação') ||
        lower.contains('negociacao') ||
        lower.contains('contratação') ||
        lower.contains('contratacao') ||
        lower.contains('empréstimo') ||
        lower.contains('emprestimo') ||
        lower.contains('transferência') ||
        lower.contains('transferencia') ||
        lower.contains('venda concluída') ||
        lower.contains('venda concluida')) {
      return GameMessageCategory.market;
    }

    if (lower.contains('scout') ||
        lower.contains('lista de observação') ||
        lower.contains('lista de observacao') ||
        lower.contains('observado')) {
      return GameMessageCategory.scout;
    }

    if (lower.startsWith('ct') ||
        lower.contains('relatório do ct') ||
        lower.contains('relatorio do ct') ||
        lower.contains('treino') ||
        lower.contains('treinamento') ||
        lower.contains('evolução') ||
        lower.contains('evolucao')) {
      return GameMessageCategory.training;
    }

    if (RegExp(r'\d+\s*x\s*\d+').hasMatch(lower) ||
        lower.contains('destaque do jogo') ||
        lower.contains('marcou para') ||
        lower.contains('marcou o gol') ||
        lower.contains('marcaram os gols')) {
      return GameMessageCategory.match;
    }

    if (lower.contains('notícias do mundo') ||
        lower.contains('noticia do mundo') ||
        lower.contains('mercado da bola') ||
        lower.contains('mundo do futebol') ||
        lower.contains('giro da rodada') ||
        lower.contains('giro do mercado')) {
      return GameMessageCategory.world;
    }

    if (lower.startsWith('erro ao') || lower.startsWith('erro ')) {
      return GameMessageCategory.system;
    }

    return GameMessageCategory.season;
  }

  Map<String, dynamic> _simonBolivarGroupFixtureToJson(
    SimonBolivarGroupFixture fixture,
  ) {
    return <String, dynamic>{
      'id': fixture.id,
      'competitionId': fixture.competitionId,
      'seasonYear': fixture.seasonYear,
      'groupId': fixture.groupId,
      'round': fixture.round,
      'homeClubId': fixture.homeClubId,
      'awayClubId': fixture.awayClubId,
      'date': fixture.date.toIso8601String(),
      'homeGoals': fixture.homeGoals,
      'awayGoals': fixture.awayGoals,
    };
  }

  SimonBolivarGroupFixture _simonBolivarGroupFixtureFromJson(
    Map<String, dynamic> json,
  ) {
    final parsedDate = DateTime.tryParse(
      (json['date'] as String?) ?? '',
    );

    return SimonBolivarGroupFixture(
      id: (json['id'] as String?) ?? '',
      competitionId: (json['competitionId'] as String?) ?? 'SBV',
      seasonYear: _readInt(json['seasonYear'], fallback: _seasonYear),
      groupId: (json['groupId'] as String?) ?? 'A',
      round: _readInt(json['round'], fallback: 1),
      homeClubId: (json['homeClubId'] as String?) ?? '',
      awayClubId: (json['awayClubId'] as String?) ?? '',
      date: parsedDate ?? DateTime(_seasonYear, 4, 3),
      homeGoals: (json['homeGoals'] as num?)?.toInt(),
      awayGoals: (json['awayGoals'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> _cupFixtureToJson(CupFixture fixture) {
    return <String, dynamic>{
      'id': fixture.id,
      'competitionId': fixture.competitionId,
      'seasonYear': fixture.seasonYear,
      'phase': fixture.phase,
      'phaseLabel': fixture.phaseLabel,
      'leg': fixture.leg,
      'homeClubId': fixture.homeClubId,
      'awayClubId': fixture.awayClubId,
      'date': fixture.date.toIso8601String(),
      'homeGoals': fixture.homeGoals,
      'awayGoals': fixture.awayGoals,
      'resolved': fixture.resolved,
      'winnerClubId': fixture.winnerClubId,
    };
  }

  CupFixture _cupFixtureFromJson(Map<String, dynamic> json) {
    final parsedDate = DateTime.tryParse(
      (json['date'] as String?) ?? '',
    );

    return CupFixture(
      id: (json['id'] as String?) ?? '',
      competitionId: (json['competitionId'] as String?) ?? 'CBR',
      seasonYear: _readInt(json['seasonYear'], fallback: _seasonYear),
      phase: _readInt(json['phase'], fallback: 1),
      phaseLabel: (json['phaseLabel'] as String?) ?? 'Mata-mata',
      leg: _readInt(json['leg'], fallback: 1),
      homeClubId: (json['homeClubId'] as String?) ?? '',
      awayClubId: (json['awayClubId'] as String?) ?? '',
      date: parsedDate ?? DateTime(_seasonYear, 7, 3),
      homeGoals: (json['homeGoals'] as num?)?.toInt(),
      awayGoals: (json['awayGoals'] as num?)?.toInt(),
      resolved: json['resolved'] == true,
      winnerClubId: json['winnerClubId'] as String?,
    );
  }

  Map<String, dynamic> _financeToJson(FinanceSnapshot finance) {
    return <String, dynamic>{
      'caixa': finance.caixa,
      'operacional': finance.operacional,
      'balance': finance.caixa,
      'operationalCash': finance.operacional,
      'debt': finance.debt,
      'monthlyWage': finance.monthlyWage,
      'health': _financeHealthToString(finance.health),
      'structureMaintenance': userStructureMaintenance,
      'totalMonthlyFixedCost': userTotalMonthlyFixedCost,
      'repassPercentage': userRepassPercentage,
    };
  }

  FinanceSnapshot _financeFromJson(Map<String, dynamic> json) {
    return FinanceSnapshot(
      caixa: _readInt(
        json['caixa'],
        fallback: _readInt(json['balance'], fallback: 0),
      ),
      operacional: _readInt(
        json['operacional'],
        fallback: _readInt(json['operationalCash'], fallback: 0),
      ),
      debt: _readInt(json['debt'], fallback: 0),
      monthlyWage: _readInt(json['monthlyWage'], fallback: 0),
      health: _parseFinanceHealth(json['health']),
    );
  }

  Map<String, dynamic> _structuresToJson(ClubStructures structures) {
    return <String, dynamic>{
      'complexo': structures.complexo,
      'ct': structures.ct,
      'base': structures.base,
      'scout': structures.scout,
      'financeiro': structures.financeiro,
      'marketing': structures.marketing,
      'comunicacao': structures.comunicacao,
      'medico': structures.medico,
      'estadio': structures.estadio,
      'structuralPower': structures.structuralPower,
    };
  }

  FinanceHealth _parseFinanceHealth(dynamic raw) {
    switch ((raw ?? '').toString()) {
      case 'muitoSaudavel':
        return FinanceHealth.muitoSaudavel;
      case 'saudavel':
        return FinanceHealth.saudavel;
      case 'estavel':
        return FinanceHealth.estavel;
      case 'pressionado':
        return FinanceHealth.pressionado;
      case 'critico':
        return FinanceHealth.critico;
      case 'colapsoFinanceiro':
        return FinanceHealth.colapsoFinanceiro;
      default:
        return FinanceHealth.estavel;
    }
  }

  String _financeHealthToString(FinanceHealth health) {
    switch (health) {
      case FinanceHealth.muitoSaudavel:
        return 'muitoSaudavel';
      case FinanceHealth.saudavel:
        return 'saudavel';
      case FinanceHealth.estavel:
        return 'estavel';
      case FinanceHealth.pressionado:
        return 'pressionado';
      case FinanceHealth.critico:
        return 'critico';
      case FinanceHealth.colapsoFinanceiro:
        return 'colapsoFinanceiro';
    }
  }
}
