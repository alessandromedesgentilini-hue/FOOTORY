part of '../game_state.dart';

extension GameStateRuntimeHandler on GameState {
  int get roundPlayed {
    if (_maxRound <= 0) return 0;
    final v = roundIndex - 1;
    return v.clamp(0, _maxRound);
  }

  int get roundDisplay {
    if (_maxRound <= 0) return 1;
    if (seasonEnded) return _maxRound;
    return roundIndex.clamp(1, _maxRound);
  }

  double get userStructuralPower => _userClubStructures.structuralPower;
  int get userComplexoLevel => _userClubStructures.complexo;
  int get userCtLevel => _userClubStructures.ct;
  int get userBaseLevel => _userClubStructures.base;
  int get userScoutLevel => _userClubStructures.scout;
  int get userFinanceiroLevel => _userClubStructures.financeiro;
  int get userMarketingLevel => _userClubStructures.marketing;
  int get userComunicacaoLevel => _userClubStructures.comunicacao;
  int get userMedicoLevel => _userClubStructures.medico;
  int get userStadiumLevel => _userClubStructures.estadio;

  int get readMatchNewsCount => _readMatchNewsCount;
  int get readMarketNewsCount => _readMarketNewsCount;
  int get readWorldNewsCount => _readWorldNewsCount;
  int get readFinanceNewsCount => _readFinanceNewsCount;
  int get readTrainingNewsCount => _readTrainingNewsCount;
  int get readSeasonNewsCount => _readSeasonNewsCount;

  int get unreadNewsCount {
    final value = _newsFeed.length - _readNewsCount;
    return value < 0 ? 0 : value;
  }

  int get unreadDepartmentMessagesCount {
    final value = _departmentMessages.length - _readDepartmentMessagesCount;
    return value < 0 ? 0 : value;
  }

  int get totalUnreadMessages =>
      unreadNewsCount + unreadDepartmentMessagesCount;

  bool get hasUnreadMessages => totalUnreadMessages > 0;

  ClubLegacyEntry? getUserClubLegacy() {
    return _legacyRuntimeService.getClubLegacy(_clubLegacy, userClubId);
  }

  int get userLegacyPoints => getUserClubLegacy()?.totalPoints ?? 0;
  int get userLegacySeasons => getUserClubLegacy()?.seasons ?? 0;

  String get userLegacyLabel => ClubLegacyHelper.label(userLegacyPoints);

  String get userLegacyShortLabel =>
      ClubLegacyHelper.shortLabel(userLegacyPoints);

  String get userLegacyPressureLabel =>
      ClubLegacyHelper.pressureLabel(userLegacyPoints);

  String get userLegacyEmotionalContext =>
      ClubLegacyHelper.emotionalContext(userLegacyPoints);

  String get userLegacySummaryLine {
    final seasons = userLegacySeasons;

    if (seasons <= 0) {
      return 'O projeto esportivo ainda está começando e não possui histórico consolidado no clube.';
    }

    return '$userLegacyLabel após $seasons temporada(s). $userLegacyEmotionalContext';
  }

  ClubStatusSnapshot get userClubStatus {
    return _clubStatusRuntimeService.build(
      historicalSize: _userHistoricalSize(),
      clubPower10: clubPower10(userClubId),
      legacyPoints: userLegacyPoints,
      divisionId: _userDiv(),
    );
  }

  String get userClubStatusLabel => userClubStatus.label;
  String get userClubStatusPressure => userClubStatus.pressure;
  String get userClubStatusExpectation => userClubStatus.expectation;
  String get userClubStatusNarrativeContext => userClubStatus.narrativeContext;
  int get userClubStatusScore => userClubStatus.statusScore;
  ClubStatusTier get userClubStatusTier => userClubStatus.currentTier;
  ClubHistoricalSize get userClubHistoricalSize =>
      userClubStatus.historicalSize;

  ClubHistoricalSize _userHistoricalSize() {
    final basePower = clubCpuPower10(userClubId);

    if (basePower >= 7.0) return ClubHistoricalSize.big;
    if (basePower >= 5.2) return ClubHistoricalSize.medium;
    return ClubHistoricalSize.small;
  }

  void setUserClubStructures(ClubStructures value) {
    _userClubStructures = _structureRuntimeService.clampByComplexo(value);
    notifyListeners();
  }

  int getStructureLevel(ClubStructureType type) {
    return _structureRuntimeService.getStructureLevel(
      _userClubStructures,
      type,
    );
  }

  bool canUpgradeStructure(ClubStructureType type) {
    return _structureRuntimeService.canUpgrade(
      _userClubStructures,
      type,
    );
  }

  bool upgradeUserStructure(ClubStructureType type) {
    final currentBalance =
        userClubId.isNotEmpty ? _ensureFinanceForClub(userClubId).caixa : 0;

    final result = _structureRuntimeService.tryUpgrade(
      currentStructures: _userClubStructures,
      type: type,
      currentBalance: currentBalance,
    );

    if (!result.success) return false;

    _userClubStructures = result.updatedStructures;

    if (userClubId.isNotEmpty && result.financeCost > 0) {
      final finance = _ensureFinanceForClub(userClubId);
      final updated = finance.copyWith(
        caixa: finance.caixa - result.financeCost,
      );
      _financeByClub[userClubId] = _financeClubService.refreshHealth(updated);
    }

    notifyListeners();
    return true;
  }

  ClubStructures _clampStructuresByComplexo(ClubStructures s) {
    return _structureRuntimeService.clampByComplexo(s);
  }

  void consumePendingCheckpoint() {
    if (_pendingCheckpoint == null) return;
    _pendingCheckpoint = null;
    notifyListeners();
  }

  void markAllMessagesAsRead() {
    _readNewsCount = _newsFeed.length;
    _readDepartmentMessagesCount = _departmentMessages.length;
    notifyListeners();
  }

  void markNewsAsRead() {
    _readNewsCount = _newsFeed.length;
    notifyListeners();
  }

  void markMatchNewsAsRead(int total) {
    _readMatchNewsCount = total;
    _syncReadNewsCountFromCategories();
    notifyListeners();
  }

  void markMarketNewsAsRead(int total) {
    _readMarketNewsCount = total;
    _syncReadNewsCountFromCategories();
    notifyListeners();
  }

  void markWorldNewsAsRead(int total) {
    _readWorldNewsCount = total;
    _syncReadNewsCountFromCategories();
    notifyListeners();
  }

  void markFinanceNewsAsRead(int total) {
    _readFinanceNewsCount = total;
    _syncReadNewsCountFromCategories();
    notifyListeners();
  }

  void markTrainingNewsAsRead(int total) {
    _readTrainingNewsCount = total;
    _syncReadNewsCountFromCategories();
    notifyListeners();
  }

  void markSeasonNewsAsRead(int total) {
    _readSeasonNewsCount = total;
    _syncReadNewsCountFromCategories();
    notifyListeners();
  }

  void _syncReadNewsCountFromCategories() {
    _readNewsCount = _readMatchNewsCount +
        _readMarketNewsCount +
        _readWorldNewsCount +
        _readFinanceNewsCount +
        _readTrainingNewsCount +
        _readSeasonNewsCount;

    if (_readNewsCount > _newsFeed.length) {
      _readNewsCount = _newsFeed.length;
    }
  }

  void markDepartmentMessagesAsRead() {
    _readDepartmentMessagesCount = _departmentMessages.length;
    notifyListeners();
  }

  void _resetUnreadState() {
    _readNewsCount = 0;
    _readDepartmentMessagesCount = 0;

    _readMatchNewsCount = 0;
    _readMarketNewsCount = 0;
    _readWorldNewsCount = 0;
    _readFinanceNewsCount = 0;
    _readTrainingNewsCount = 0;
    _readSeasonNewsCount = 0;
  }

  List<Player> getProSquad() {
    return List.unmodifiable(_proSquads[userClubId] ?? const <Player>[]);
  }

  void restoreClubLegacyFromSave(Map<String, ClubLegacyEntry> value) {
    _legacyRuntimeService.restoreLegacyMap(
      target: _clubLegacy,
      source: value,
    );
    notifyListeners();
  }

  void applySeasonLegacy({
    required String clubId,
    required int points,
  }) {
    if (clubId.trim().isEmpty) return;

    final current = _clubLegacy[clubId];

    if (current == null) {
      _clubLegacy[clubId] = ClubLegacyEntry(
        clubId: clubId,
        totalPoints: points,
        seasons: 1,
      );
    } else {
      _clubLegacy[clubId] = current.copyWith(
        totalPoints: current.totalPoints + points,
        seasons: current.seasons + 1,
      );
    }

    notifyListeners();
  }

  int _calculateSeasonPerformancePoints() {
    return _legacyRuntimeService.calculateSeasonPerformancePoints(
      clubId: userClubId,
      divisionId: _userDiv(),
      tablesByDivision: _tableByDiv,
    );
  }

  void restoreCareerMetaFromSave({
    required int seasonYear,
    required int roundIndex,
    required bool seasonEnded,
    required String dateStr,
    String? currentDateIso,
  }) {
    _seasonYear = seasonYear;
    this.roundIndex = roundIndex;
    this.seasonEnded = seasonEnded;
    this.dateStr = dateStr;

    if (currentDateIso != null && currentDateIso.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(currentDateIso);
      if (parsed != null) {
        _currentDate = parsed;
        this.dateStr = _formatDate(_currentDate);
      }
    }

    notifyListeners();
  }

  int _readInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  DivisionId _divisionIdOfClub(String clubId) {
    for (final entry in _clubIdsByDiv.entries) {
      if (entry.value.contains(clubId)) {
        return entry.key;
      }
    }

    return _userDiv();
  }
}
