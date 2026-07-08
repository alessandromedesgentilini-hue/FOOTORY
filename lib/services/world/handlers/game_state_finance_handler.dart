part of '../game_state.dart';

extension GameStateFinanceHandler on GameState {
  FinanceSnapshot get userFinance =>
      _financeByClub[userClubId] ??
      const FinanceSnapshot(
        caixa: 0,
        operacional: 0,
        debt: 0,
        monthlyWage: 0,
        health: FinanceHealth.muitoSaudavel,
      );

  int get userBalance => userFinance.caixa;
  int get userCaixaLivre => userFinance.caixa;
  int get userOperationalCash => userFinance.operacional;
  int get userDebt => userFinance.debt;
  int get userMonthlyWage => userFinance.monthlyWage;

  int get userStructureMaintenance =>
      _structureRuntimeService.structureMaintenanceOfClub(
        clubId: userClubId,
        userClubId: userClubId,
        userStructures: _userClubStructures,
        catalogResolver: ClubStructuresCatalog.byId,
      );

  int get userTotalMonthlyFixedCost =>
      userMonthlyWage + userStructureMaintenance;

  FinanceHealth get userFinanceHealth => userFinance.health;

  double get userRepassPercentage =>
      _financeRulesService.repassPercentage(userFinance.health);

  FinanceSnapshot? financeOfClub(String clubId) => _financeByClub[clubId];

  void setFinanceForClub(String clubId, FinanceSnapshot snapshot) {
    if (clubId.trim().isEmpty) return;

    _financeRuntimeService.setFinanceForClub(
      financeByClub: _financeByClub,
      clubId: clubId,
      snapshot: snapshot,
    );

    notifyListeners();
  }

  int estimatePlayerValueForUserClub(Player player) {
    return _estimatePlayerValueForClub(
      player: player,
      clubId: userClubId,
    );
  }

  int calculatePlayerSalaryForUserClub(Player player) {
    return _calculatePlayerSalaryForClub(
      player: player,
      clubId: userClubId,
    );
  }

  void recalculateUserMonthlyWage() {
    _recalculateMonthlyWageForClub(userClubId);
    notifyListeners();
  }

  void applyUserFullRevenue(int value) {
    if (userClubId.isEmpty || value <= 0) return;

    final current = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.applyFullRevenue(
      current: current,
      value: value,
    );

    notifyListeners();
  }

  void applyUserRestrictedRevenue(int value) {
    if (userClubId.isEmpty || value <= 0) return;

    final current = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.applyRestrictedRevenue(
      current: current,
      value: value,
    );

    notifyListeners();
  }

  void applyUserTransferExpense({
    required int transferCost,
    required Player player,
  }) {
    if (userClubId.isEmpty) return;

    final current = _ensureFinanceForClub(userClubId);

    final salary = _calculatePlayerSalaryForClub(
      player: player,
      clubId: userClubId,
    );

    _financeByClub[userClubId] = _financeRuntimeService.applyTransferExpense(
      current: current,
      transferCost: transferCost,
      salary: salary,
    );

    notifyListeners();
  }

  void applyUserSaleFinance({
    required int value,
    required Player player,
  }) {
    if (userClubId.isEmpty) return;

    final current = _ensureFinanceForClub(userClubId);

    final salary = _calculatePlayerSalaryForClub(
      player: player,
      clubId: userClubId,
    );

    _financeByClub[userClubId] = _financeRuntimeService.applySale(
      current: current,
      value: value,
      salaryRemoved: salary,
    );

    notifyListeners();
  }

  FinanceSnapshot _ensureFinanceForClub(String clubId) {
    return _financeRuntimeService.ensureClubFinance(
      financeByClub: _financeByClub,
      clubId: clubId,
      factory: () => _financeRuntimeService.buildInitialFinanceForClub(
        clubId: clubId,
        divisionId: _divisionIdOfClub(clubId),
      ),
    );
  }

  void _seedFinanceForWorldIfNeeded() {
    _financeRuntimeService.seedFinanceForWorldIfNeeded(
      clubIdsByDiv: _clubIdsByDiv,
      financeByClub: _financeByClub,
      userClubId: userClubId,
      divisionResolver: _divisionIdOfClub,
    );
  }

  void _recalculateMonthlyWagesForWorld() {
    _financeRuntimeService.recalculateMonthlyWagesForWorld(
      financeByClub: _financeByClub,
      squadsByClub: _proSquads,
      salaryCalculator: (clubId, player) => _calculatePlayerSalaryForClub(
        player: player,
        clubId: clubId,
      ),
    );
  }

  void _recalculateMonthlyWageForClub(String clubId) {
    if (clubId.trim().isEmpty) return;

    final snapshot = _ensureFinanceForClub(clubId);
    final squad = _proSquads[clubId] ?? const <Player>[];

    final total = _financeRuntimeService.recalculateMonthlyWage(
      squad: squad,
      salaryCalculator: (player) => _calculatePlayerSalaryForClub(
        player: player,
        clubId: clubId,
      ),
    );

    _financeByClub[clubId] = _financeClubService.refreshHealth(
      snapshot.copyWith(monthlyWage: total),
    );
  }

  int _calculatePlayerSalaryForClub({
    required Player player,
    required String clubId,
  }) {
    final finance = _ensureFinanceForClub(clubId);
    final level = clubId == userClubId ? userFinanceiroLevel : 5;

    final value = _estimatePlayerValueForClub(
      player: player,
      clubId: clubId,
    );

    return _financeRuntimeService.calculatePlayerSalary(
      finance: finance,
      financeLevel: level,
      playerValue: value,
    );
  }

  int _estimatePlayerValueForClub({
    required Player player,
    required String clubId,
  }) {
    return _financeRuntimeService.estimatePlayerValue(
      playerOvr: player.ovrCheio,
      playerAge: player.idade,
      divisionId: _divisionIdOfClub(clubId),
    );
  }
}
