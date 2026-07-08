part of '../game_state.dart';

extension MonthlyFinanceHandler on GameState {
  void _maybeProcessMonthlyFinance({
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    if (!_crossedIntoNewMonth(fromDate, toDate)) return;
    if (userClubId.isEmpty) return;

    final currentMonthKey = '${toDate.year}-${toDate.month}';
    final currentMonthHash = currentMonthKey.hashCode;

    if (_processedEvolutionMonths.contains(currentMonthHash)) {
      return;
    }

    _processedEvolutionMonths.add(currentMonthHash);

    _recalculateMonthlyWageForClub(userClubId);

    final monthLabel = _monthYearLabel(toDate);

    final before = userFinance;
    final beforeHealth = before.health;
    final beforeOperational = before.operacional;
    final beforeDebt = before.debt;

    _applyMonthlySponsorRevenue(monthLabel: monthLabel);

    final wageCost = userMonthlyWage;
    final structureCost = userStructureMaintenance;
    final totalCost = wageCost + structureCost;

    if (totalCost <= 0) return;

    final current = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.payFixedCosts(
      current: current,
      totalCost: totalCost,
    );

    final after = userFinance;

    _insertNewsIfNew(
      'Fechamento de $monthLabel — '
      'O clube pagou ${_financeMoney(totalCost)} em custos fixos: '
      '${_financeMoney(wageCost)} de folha salarial e '
      '${_financeMoney(structureCost)} de manutenção estrutural.',
    );

    final availableBeforeCost = beforeOperational;
    final missingBeforeLoan = totalCost - availableBeforeCost;

    if (missingBeforeLoan > 0) {
      final debtIncrease = after.debt - beforeDebt;

      _insertNewsIfNew(
        'Empréstimo operacional — '
        'O fluxo operacional não cobria os custos de $monthLabel. '
        'Faltaram ${_financeMoney(missingBeforeLoan)} '
        'para manter salários e estrutura em dia. '
        'O clube acionou crédito emergencial e a dívida aumentou em '
        '${_financeMoney(debtIncrease)} já com juros.',
      );
    }

    if (after.health != beforeHealth) {
      _insertNewsIfNew(
        'Alerta financeiro — '
        'A saúde financeira mudou de '
        '${_financeHealthLabel(beforeHealth)} para '
        '${_financeHealthLabel(after.health)} '
        'após o fechamento de $monthLabel.',
      );
    }

    if (after.operacional == 0 && missingBeforeLoan > 0) {
      _insertNewsIfNew(
        'Fluxo operacional zerado — '
        'O clube terminou $monthLabel sem reserva operacional.',
      );
    } else if (after.operacional <= 10000000 && after.operacional > 0) {
      _insertNewsIfNew(
        'Fluxo operacional apertado — '
        'Após o fechamento de $monthLabel, '
        'restam apenas ${_financeMoney(after.operacional)} '
        'para cobrir salários e manutenção.',
      );
    }
  }

  void _applyMonthlySponsorRevenue({
    required String monthLabel,
  }) {
    final result = _sponsorRevenueService.calculateMonthly(
      divisionId: divisionId,
      marketingLevel: userMarketingLevel,
    );

    if (result.monthlyAmount <= 0) return;

    final before = userFinance;
    final beforeDebt = before.debt;

    final current = _ensureFinanceForClub(userClubId);

    _financeByClub[userClubId] = _financeRuntimeService.applyRestrictedRevenue(
      current: current,
      value: result.monthlyAmount,
    );

    final after = userFinance;

    final debtPaid = (beforeDebt - after.debt).clamp(0, result.monthlyAmount);
    final retained = result.monthlyAmount - debtPaid;

    _insertNewsIfNew(
      'PATROCÍNIO — '
      'Em $monthLabel, ${result.message} '
      'Do valor total, ${_financeMoney(debtPaid)} '
      'foram usados para reduzir dívida e '
      '${_financeMoney(retained)} ficaram disponíveis ao clube.',
    );
  }

  bool _crossedIntoNewMonth(
    DateTime fromDate,
    DateTime toDate,
  ) {
    return fromDate.month != toDate.month || fromDate.year != toDate.year;
  }

  String _monthYearLabel(DateTime date) {
    const months = <int, String>{
      1: 'janeiro',
      2: 'fevereiro',
      3: 'março',
      4: 'abril',
      5: 'maio',
      6: 'junho',
      7: 'julho',
      8: 'agosto',
      9: 'setembro',
      10: 'outubro',
      11: 'novembro',
      12: 'dezembro',
    };

    final month = months[date.month] ?? 'mês';

    return '$month/${date.year}';
  }

  String _financeMoney(int value) {
    return MoneyFormatter.formatCurrency(value);
  }

  String _financeHealthLabel(FinanceHealth health) {
    switch (health) {
      case FinanceHealth.muitoSaudavel:
        return 'Muito saudável';
      case FinanceHealth.saudavel:
        return 'Saudável';
      case FinanceHealth.estavel:
        return 'Estável';
      case FinanceHealth.pressionado:
        return 'Pressionado';
      case FinanceHealth.critico:
        return 'Crítico';
      case FinanceHealth.colapsoFinanceiro:
        return 'Colapso financeiro';
    }
  }
}
