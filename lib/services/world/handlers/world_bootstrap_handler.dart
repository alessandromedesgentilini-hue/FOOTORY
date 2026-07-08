part of '../game_state.dart';

extension WorldBootstrapHandler on GameState {
  String clubName(String clubId) => _clubNames[clubId] ?? clubId;

  double catalogPower(String clubId) {
    final brazilClub = _clubs[clubId];
    if (brazilClub != null) return brazilClub.basePower;

    final internationalClub = SouthAmericaClubCatalog.byId(clubId);
    if (internationalClub != null) return internationalClub.basePower;

    return 4.5;
  }

  double clubCpuPower10(String clubId) =>
      _cpuClubPower10[clubId] ?? catalogPower(clubId);

  double clubPower10(String clubId) {
    if (clubId == userClubId) {
      final squad = _proSquads[userClubId] ?? const <Player>[];
      return _teamPowerService.computeTeamPower(squad);
    }

    return clubCpuPower10(clubId);
  }

  double clubBasePower(String clubId) => clubCpuPower10(clubId);

  int clubCpuCoachLevel(String clubId) {
    final brazilClub = _clubs[clubId];
    if (brazilClub != null) return brazilClub.cpuCoachLevel;

    final internationalClub = SouthAmericaClubCatalog.byId(clubId);
    if (internationalClub != null) return internationalClub.cpuCoachLevel;

    return 4;
  }

  int clubCpuStadiumLevel(String clubId) {
    final brazilClub = _clubs[clubId];
    if (brazilClub != null) return brazilClub.cpuStadiumLevel;

    final internationalClub = SouthAmericaClubCatalog.byId(clubId);
    if (internationalClub != null) return internationalClub.cpuStadiumLevel;

    return 5;
  }

  int clubStadiumLevel(String clubId) {
    if (clubId == userClubId) return userStadiumLevel;
    return clubCpuStadiumLevel(clubId);
  }

  double clubMatchPower(String clubId) {
    if (clubId == userClubId) {
      return _buildUserAutoLineup().matchPower10;
    }

    return clubPower10(clubId);
  }

  AutoLineupResult _buildUserAutoLineup() {
    final squad = _proSquads[userClubId] ?? const <Player>[];

    final identity = CoachTacticalCatalog.fromId(
      selectedCoachStaffOrFallback.tacticalIdentityId,
    );

    return _autoLineupService.build(
      squad: squad,
      formation: identity.mainFormation,
    );
  }

  List<Player> _userMatchPlayers() {
    return List<Player>.from(_buildUserAutoLineup().matchPlayers);
  }

  List<Player> _userMatchEventPool() {
    final lineup = _buildUserAutoLineup();
    final pool = List<Player>.from(lineup.weightedEventPool);

    if (pool.isNotEmpty) return pool;

    return List<Player>.from(_proSquads[userClubId] ?? const <Player>[]);
  }

  void _bootstrapWorldFromCatalog() {
    _clubs.clear();
    _clubNames.clear();
    _cpuClubPower10.clear();

    for (final c in BrazilClubCatalog.all()) {
      _clubs[c.id] = c;
      _clubNames[c.id] = c.name;
      _cpuClubPower10[c.id] = c.basePower;
    }

    for (final c in SouthAmericaClubCatalog.internationalOnly()) {
      _clubNames[c.id] = c.name;
      _cpuClubPower10[c.id] = c.basePower;
    }

    _clubNames[userClubId] = userClubName;

    _clubIdsByDiv[DivisionId.brA] =
        BrazilClubCatalog.byDivision(DivisionId.brA).map((e) => e.id).toList();
    _clubIdsByDiv[DivisionId.brB] =
        BrazilClubCatalog.byDivision(DivisionId.brB).map((e) => e.id).toList();
    _clubIdsByDiv[DivisionId.brC] =
        BrazilClubCatalog.byDivision(DivisionId.brC).map((e) => e.id).toList();
    _clubIdsByDiv[DivisionId.brD] =
        BrazilClubCatalog.byDivision(DivisionId.brD).map((e) => e.id).toList();

    final wanted = _parseDivisionId(divisionId) ?? DivisionId.brD;
    final list = _clubIdsByDiv[wanted] ?? <String>[];

    if (!list.contains(userClubId)) {
      if (list.isNotEmpty) list.removeLast();
      list.add(userClubId);
      _clubIdsByDiv[wanted] = list;
    }

    divisionId = _toDivisionStr(wanted);
  }

  void _bootstrapWorldLeagues() {
    _seasonByDiv.clear();
    _tableByDiv.clear();

    for (final div in DivisionId.values) {
      final clubIds = List<String>.from(_clubIdsByDiv[div] ?? const <String>[]);

      if (clubIds.length != 20) {
        throw StateError(
          'World inválido: $div deveria ter 20 clubes, mas tem ${clubIds.length}.',
        );
      }

      final season = _seasonService.buildLeagueSeason(
        year: _seasonYear,
        clubIds: clubIds,
      );

      _seasonByDiv[div] = season;

      final tab = LeagueTable();
      for (final c in clubIds) {
        tab.ensureClub(c);
      }
      tab.resetStats();

      _tableByDiv[div] = tab;
    }

    _syncUserDivisionViews();
  }

  void _syncUserDivisionViews() {
    fixtures.clear();
    table.resetAll();

    final div = _userDiv();
    final season = _seasonByDiv[div];
    final tab = _tableByDiv[div];

    if (season != null) {
      fixtures.addAll(season.fixtures);
      _maxRound = season.totalRounds;
    }

    if (tab != null) {
      for (final e in tab.getSorted()) {
        table.ensureClub(e.clubId);
      }

      for (final e in tab.getSorted()) {
        final tEntry = table.getEntry(e.clubId)!;
        tEntry.played = e.played;
        tEntry.wins = e.wins;
        tEntry.draws = e.draws;
        tEntry.losses = e.losses;
        tEntry.goalsFor = e.goalsFor;
        tEntry.goalsAgainst = e.goalsAgainst;
        tEntry.points = e.points;
      }
    }
  }

  void _bootstrapUserSquadPowerAware() {
    _proSquads.clear();

    final base10 = clubCpuPower10(userClubId);
    final target = (base10 * 10).round().clamp(10, 100);

    final minOvr = (target - 6).clamp(10, 100);
    final maxOvr = (target + 6).clamp(10, 100);

    _proSquads[userClubId] = List<Player>.generate(18, (i) {
      final pos = _pickPosForIndex(i);

      return _playerFactory.criarJogadorComOvrCheioTarget(
        posDet: pos,
        nacionalidade: _randomPlayerNationality(),
        idadeMin: 19,
        idadeMax: 29,
        minOvrCheio: minOvr,
        maxOvrCheio: maxOvr,
        maxTries: 35,
      );
    });
  }

  String _randomPlayerNationality() {
    final roll = _rng.rangeInt(1, 100);

    if (roll <= 65) return 'BR';
    if (roll <= 82) return _randomSouthAmericanNationality();
    if (roll <= 90) return _randomEuropeanNationality();
    if (roll <= 94) return _randomAfricanNationality();
    if (roll <= 98) return _randomAsianNationality();

    return _randomNorthAmericanNationality();
  }

  String _randomSouthAmericanNationality() {
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

    return _rng.pick(pool);
  }

  String _randomEuropeanNationality() {
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

    return _rng.pick(pool);
  }

  String _randomAfricanNationality() {
    const pool = <String>[
      'NG',
      'CI',
      'SN',
      'GH',
      'CM',
      'ML',
    ];

    return _rng.pick(pool);
  }

  String _randomAsianNationality() {
    const pool = <String>[
      'JP',
      'KR',
      'CN',
    ];

    return _rng.pick(pool);
  }

  String _randomNorthAmericanNationality() {
    const pool = <String>[
      'US',
      'MX',
      'CR',
    ];

    return _rng.pick(pool);
  }

  PosDet _pickPosForIndex(int i) {
    const cycle = <PosDet>[
      PosDet.gol,
      PosDet.gol,
      PosDet.zag,
      PosDet.zag,
      PosDet.ld,
      PosDet.le,
      PosDet.vol,
      PosDet.mc,
      PosDet.mc,
      PosDet.mei,
      PosDet.pd,
      PosDet.pe,
      PosDet.ca,
      PosDet.ca,
    ];

    return cycle[i % cycle.length];
  }

  void _bootstrapMarketAndScout() {
    _scoutTransfers.clear();
    _scoutLoans.clear();
    _scoutFrees.clear();

    _marketService.generateInitialPools(
      transferTotal: 60,
      loanTotal: 40,
      freeTotal: 40,
      defaultNationality: 'BR',
    );

    const transferCount = 6;
    const loanCount = 4;
    const freeCount = 3;

    final scoutLevel = userScoutLevel.clamp(1, 10);
    const motivo =
        'Departamento de análise apresentou opções para reforçar o elenco.';

    final pickTransfers = _scoutService.pickPoolByScoutLevel(
      source: List<Player>.from(_marketService.transferPlayers),
      scoutLevel: scoutLevel,
      count: transferCount,
    );

    final pickLoans = _scoutService.pickPoolByScoutLevel(
      source: List<Player>.from(_marketService.loanPlayers),
      scoutLevel: scoutLevel,
      count: loanCount,
    );

    final pickFrees = _scoutService.pickPoolByScoutLevel(
      source: List<Player>.from(_marketService.freeAgents),
      scoutLevel: scoutLevel,
      count: freeCount,
    );

    _scoutTransfers.addAll(
      _scoutService.buildTargets(
        players: pickTransfers,
        scoutLevel: scoutLevel,
        listType: MarketListType.transfer,
        motivo: motivo,
      ),
    );

    _scoutLoans.addAll(
      _scoutService.buildTargets(
        players: pickLoans,
        scoutLevel: scoutLevel,
        listType: MarketListType.loan,
        motivo: motivo,
      ),
    );

    _scoutFrees.addAll(
      _scoutService.buildTargets(
        players: pickFrees,
        scoutLevel: scoutLevel,
        listType: MarketListType.free,
        motivo: motivo,
      ),
    );

    _pruneUnavailableScoutTargets();
  }

  void _pruneUnavailableScoutTargets() {
    _scoutTransfers.removeWhere(
      (t) => !_marketService.containsTransferPlayer(t.jogadorId),
    );

    _scoutLoans.removeWhere(
      (t) => !_marketService.containsLoanPlayer(t.jogadorId),
    );

    _scoutFrees.removeWhere(
      (t) => !_marketService.containsFreeAgent(t.jogadorId),
    );
  }

  Map<String, List<String>> _clubIdsByDivisionStringMap() {
    return {
      'BR-A': List<String>.from(_clubIdsByDiv[DivisionId.brA] ?? const []),
      'BR-B': List<String>.from(_clubIdsByDiv[DivisionId.brB] ?? const []),
      'BR-C': List<String>.from(_clubIdsByDiv[DivisionId.brC] ?? const []),
      'BR-D': List<String>.from(_clubIdsByDiv[DivisionId.brD] ?? const []),
    };
  }

  void _runCpuTransferWindow() {
    final results = _cpuTransferService.runWindow(
      market: _marketService,
      clubIdsByDivision: _clubIdsByDivisionStringMap(),
      clubPower10ById: _cpuClubPower10,
      maxSigningsPerClub: 1,
      allowMultiplePasses: false,
      excludedClubIds: {userClubId},
    );

    _pruneUnavailableScoutTargets();

    final lines = _cpuTransferService.buildNewsLines(
      results: results,
      clubNameResolver: clubName,
      excludedClubIds: {userClubId},
    );

    for (final line in lines.reversed) {
      if (_isCpuNewsRelevantToUser(line)) {
        _newsFeed.insert(0, line);
      }
    }
  }

  bool _isCpuNewsRelevantToUser(String line) {
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
}
