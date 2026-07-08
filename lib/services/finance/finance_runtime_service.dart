import 'package:footory26/models/player.dart';
import 'package:footory26/services/finance/club_finance_profile_catalog.dart';
import 'package:footory26/services/finance/finance_club_service.dart';
import 'package:footory26/services/finance/finance_rules_service.dart';
import 'package:footory26/services/finance/finance_snapshot.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class InitialFinanceSeed {
  final int caixa;
  final int operacional;
  final int debt;

  const InitialFinanceSeed({
    required this.caixa,
    required this.operacional,
    required this.debt,
  });
}

class FinanceRuntimeService {
  final FinanceClubService financeClubService;
  final FinanceRulesService financeRulesService;

  FinanceRuntimeService({
    required this.financeClubService,
    required this.financeRulesService,
  });

  FinanceSnapshot ensureClubFinance({
    required Map<String, FinanceSnapshot> financeByClub,
    required String clubId,
    required FinanceSnapshot Function() factory,
  }) {
    return financeByClub.putIfAbsent(clubId, factory);
  }

  void setFinanceForClub({
    required Map<String, FinanceSnapshot> financeByClub,
    required String clubId,
    required FinanceSnapshot snapshot,
  }) {
    if (clubId.trim().isEmpty) return;
    financeByClub[clubId] = financeClubService.refreshHealth(snapshot);
  }

  FinanceSnapshot buildInitialFinanceForClub({
    required String clubId,
    required DivisionId divisionId,
  }) {
    final profile = ClubFinanceProfileCatalog.byClubId(
      clubId: clubId,
      division: divisionId,
    );

    return financeClubService.refreshHealth(
      FinanceSnapshot(
        caixa: profile.caixa,
        operacional: profile.operacional,
        debt: profile.debt,
        monthlyWage: 0,
        health: FinanceHealth.estavel,
      ),
    );
  }

  FinanceSnapshot buildInitialFinanceForDivision(DivisionId divisionId) {
    final seed = defaultFinanceSeedForDivision(divisionId);

    return financeClubService.refreshHealth(
      FinanceSnapshot(
        caixa: seed.caixa,
        operacional: seed.operacional,
        debt: seed.debt,
        monthlyWage: 0,
        health: FinanceHealth.estavel,
      ),
    );
  }

  void seedFinanceForWorldIfNeeded({
    required Map<DivisionId, List<String>> clubIdsByDiv,
    required Map<String, FinanceSnapshot> financeByClub,
    required String userClubId,
    required DivisionId Function(String clubId) divisionResolver,
  }) {
    for (final div in DivisionId.values) {
      final clubIds = clubIdsByDiv[div] ?? const <String>[];

      for (final clubId in clubIds) {
        if (clubId.trim().isEmpty) continue;

        financeByClub.putIfAbsent(
          clubId,
          () => buildInitialFinanceForClub(
            clubId: clubId,
            divisionId: divisionResolver(clubId),
          ),
        );
      }
    }

    if (userClubId.trim().isNotEmpty) {
      financeByClub.putIfAbsent(
        userClubId,
        () => buildInitialFinanceForClub(
          clubId: userClubId,
          divisionId: divisionResolver(userClubId),
        ),
      );
    }
  }

  FinanceSnapshot applyFullRevenue({
    required FinanceSnapshot current,
    required int value,
  }) {
    if (value <= 0) return financeClubService.refreshHealth(current);

    final updated = financeClubService.applyIncome(
      snapshot: current,
      value: value,
      isFullRevenue: true,
    );

    return financeClubService.refreshHealth(updated);
  }

  FinanceSnapshot applyRestrictedRevenue({
    required FinanceSnapshot current,
    required int value,
  }) {
    if (value <= 0) return financeClubService.refreshHealth(current);

    final updated = financeClubService.applyIncome(
      snapshot: current,
      value: value,
      isFullRevenue: false,
    );

    return financeClubService.refreshHealth(updated);
  }

  FinanceSnapshot paySalaries({
    required FinanceSnapshot current,
  }) {
    final updated = _payOperationalCost(
      current: current,
      totalCost: current.monthlyWage,
    );

    return financeClubService.refreshHealth(updated);
  }

  FinanceSnapshot payFixedCosts({
    required FinanceSnapshot current,
    required int totalCost,
  }) {
    final updated = _payOperationalCost(
      current: current,
      totalCost: totalCost,
    );

    return financeClubService.refreshHealth(updated);
  }

  FinanceSnapshot _payOperationalCost({
    required FinanceSnapshot current,
    required int totalCost,
  }) {
    if (totalCost <= 0) return current;

    final afterOperational = current.operacional - totalCost;

    if (afterOperational >= 0) {
      return current.copyWith(
        operacional: afterOperational,
      );
    }

    final missing = afterOperational.abs();
    final debtIncrease = (missing * 1.20).round();

    return current.copyWith(
      operacional: 0,
      debt: current.debt + debtIncrease,
    );
  }

  FinanceSnapshot applyTransferExpense({
    required FinanceSnapshot current,
    required int transferCost,
    required int salary,
  }) {
    final updated = financeClubService.applyTransfer(
      snapshot: current,
      transferCost: transferCost,
      salary: salary,
    );

    return financeClubService.refreshHealth(updated);
  }

  FinanceSnapshot applyTransferAgreementExpense({
    required FinanceSnapshot current,
    required int transferCost,
  }) {
    final updated = financeClubService.applyTransfer(
      snapshot: current,
      transferCost: transferCost,
      salary: 0,
    );

    return financeClubService.refreshHealth(updated);
  }

  FinanceSnapshot applySalaryIncrease({
    required FinanceSnapshot current,
    required int salary,
  }) {
    if (salary <= 0) return financeClubService.refreshHealth(current);

    return financeClubService.refreshHealth(
      current.copyWith(
        monthlyWage: current.monthlyWage + salary,
      ),
    );
  }

  FinanceSnapshot applySale({
    required FinanceSnapshot current,
    required int value,
    required int salaryRemoved,
  }) {
    final updated = financeClubService.applySale(
      snapshot: current,
      value: value,
      salaryRemoved: salaryRemoved,
    );

    return financeClubService.refreshHealth(updated);
  }

  int calculatePlayerSalary({
    required FinanceSnapshot finance,
    required int financeLevel,
    required int playerValue,
  }) {
    // Salário precisa ser estável.
    // Ele depende do valor do jogador e do nível financeiro do clube.
    // NÃO pode depender da saúde financeira atual, senão a folha muda sozinha
    // quando caixa, dívida ou operacional mudam.
    return financeRulesService.calculateSalary(
      playerValue: playerValue,
      financeLevel: financeLevel,
    );
  }

  int recalculateMonthlyWage({
    required List<Player> squad,
    required int Function(Player player) salaryCalculator,
  }) {
    var total = 0;

    for (final player in squad) {
      total += salaryCalculator(player);
    }

    return total;
  }

  void recalculateMonthlyWagesForWorld({
    required Map<String, FinanceSnapshot> financeByClub,
    required Map<String, List<Player>> squadsByClub,
    required int Function(String clubId, Player player) salaryCalculator,
  }) {
    for (final clubId in financeByClub.keys.toList()) {
      final current = financeByClub[clubId];
      if (current == null) continue;

      final squad = squadsByClub[clubId];

      if (squad == null) {
        financeByClub[clubId] = financeClubService.refreshHealth(current);
        continue;
      }

      final total = recalculateMonthlyWage(
        squad: squad,
        salaryCalculator: (player) => salaryCalculator(clubId, player),
      );

      financeByClub[clubId] = financeClubService.refreshHealth(
        current.copyWith(monthlyWage: total),
      );
    }
  }

  int estimatePlayerValue({
    required int playerOvr,
    required int playerAge,
    required DivisionId divisionId,
  }) {
    final serieAValue = estimateSerieAPlayerValue(
      playerOvr: playerOvr,
      playerAge: playerAge,
    );

    final divisionAdjusted =
        (serieAValue * divisionMarketMultiplier(divisionId)).round();

    return divisionAdjusted.clamp(100000, 260000000);
  }

  int estimateSerieAPlayerValue({
    required int playerOvr,
    required int playerAge,
  }) {
    final baseValue = basePlayerValueByOvr(playerOvr);
    final ageAdjusted = (baseValue * ageMarketMultiplier(playerAge)).round();

    return ageAdjusted.clamp(100000, 260000000);
  }

  int estimateFreeAgentSigningCost({
    required int playerOvr,
    required int playerAge,
    required DivisionId divisionId,
  }) {
    final serieAFullValue = estimateSerieAPlayerValue(
      playerOvr: playerOvr,
      playerAge: playerAge,
    );

    return (serieAFullValue * 0.25).round();
  }

  int basePlayerValueByOvr(int ovr) {
    final safeOvr = ovr.clamp(30, 99);

    if (safeOvr <= 30) return 250000;
    if (safeOvr <= 40) {
      return _interpolateValue(safeOvr, 30, 40, 250000, 700000);
    }
    if (safeOvr <= 50) {
      return _interpolateValue(safeOvr, 40, 50, 700000, 1500000);
    }
    if (safeOvr <= 60) {
      return _interpolateValue(safeOvr, 50, 60, 1500000, 4000000);
    }
    if (safeOvr <= 70) {
      return _interpolateValue(safeOvr, 60, 70, 4000000, 10000000);
    }
    if (safeOvr <= 75) {
      return _interpolateValue(safeOvr, 70, 75, 10000000, 20000000);
    }
    if (safeOvr <= 80) {
      return _interpolateValue(safeOvr, 75, 80, 20000000, 40000000);
    }
    if (safeOvr <= 85) {
      return _interpolateValue(safeOvr, 80, 85, 40000000, 90000000);
    }
    if (safeOvr <= 90) {
      return _interpolateValue(safeOvr, 85, 90, 90000000, 180000000);
    }

    return _interpolateValue(safeOvr, 90, 99, 180000000, 260000000);
  }

  int _interpolateValue(int value, int minX, int maxX, int minY, int maxY) {
    if (value <= minX) return minY;
    if (value >= maxX) return maxY;
    if (maxX == minX) return minY;

    final t = (value - minX) / (maxX - minX);
    return (minY + ((maxY - minY) * t)).round();
  }

  double ageMarketMultiplier(int age) {
    if (age <= 18) return 1.40;
    if (age <= 20) return 1.25;
    if (age <= 24) return 1.15;
    if (age <= 27) return 1.05;
    if (age <= 30) return 1.00;
    if (age <= 32) return 0.90;
    if (age <= 34) return 0.80;
    if (age == 35) return 0.65;
    return 0.50;
  }

  double divisionMarketMultiplier(DivisionId div) {
    switch (div) {
      case DivisionId.brA:
        return 1.0;
      case DivisionId.brB:
        return 0.7;
      case DivisionId.brC:
        return 0.5;
      case DivisionId.brD:
        return 0.3;
    }
  }

  InitialFinanceSeed defaultFinanceSeedForDivision(DivisionId div) {
    final fallback = ClubFinanceProfileCatalog.fallbackByDivision(div);

    return InitialFinanceSeed(
      caixa: fallback.caixa,
      operacional: fallback.operacional,
      debt: fallback.debt,
    );
  }
}
