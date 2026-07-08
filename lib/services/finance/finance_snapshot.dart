import 'finance_rules_service.dart';

class FinanceSnapshot {
  /// Caixa livre:
  /// usado para contratações, estruturas e investimentos.
  final int caixa;

  /// Fluxo operacional:
  /// usado para salários, manutenção e custos mensais.
  final int operacional;

  /// Dívida total do clube.
  final int debt;

  /// Folha salarial mensal.
  final int monthlyWage;

  final FinanceHealth health;

  const FinanceSnapshot({
    required this.caixa,
    required this.operacional,
    required this.debt,
    required this.monthlyWage,
    required this.health,
  });

  FinanceSnapshot copyWith({
    int? caixa,
    int? operacional,
    int? debt,
    int? monthlyWage,
    FinanceHealth? health,
  }) {
    return FinanceSnapshot(
      caixa: caixa ?? this.caixa,
      operacional: operacional ?? this.operacional,
      debt: debt ?? this.debt,
      monthlyWage: monthlyWage ?? this.monthlyWage,
      health: health ?? this.health,
    );
  }

  // =========================================================
  // HELPERS
  // =========================================================

  /// Dinheiro total do clube.
  int get totalCash => caixa + operacional;

  /// Clube está no vermelho operacional.
  bool get isOperationalNegative => operacional < 0;

  /// Clube está sem caixa livre.
  bool get isCaixaNegative => caixa < 0;

  /// Clube está financeiramente quebrado.
  bool get isBroken =>
      operacional < 0 &&
      caixa <= 0 &&
      health == FinanceHealth.colapsoFinanceiro;

  /// Margem operacional segura.
  bool get hasOperationalMargin => operacional >= monthlyWage * 2;

  /// Quantos meses o clube aguenta pagar salário
  /// usando APENAS o operacional.
  int get operationalSurvivalMonths {
    if (monthlyWage <= 0) return 999;
    return (operacional / monthlyWage).floor();
  }

  /// Dívida líquida aproximada.
  int get netDebt => (debt - totalCash).clamp(0, 9999999999);

  // =========================================================
  // LABELS
  // =========================================================

  String get healthLabel {
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

  String get operationalStatusLabel {
    if (operacional >= monthlyWage * 4) {
      return 'Fluxo operacional muito confortável';
    }

    if (operacional >= monthlyWage * 2) {
      return 'Fluxo operacional saudável';
    }

    if (operacional >= monthlyWage) {
      return 'Fluxo operacional estável';
    }

    if (operacional >= 0) {
      return 'Fluxo operacional apertado';
    }

    return 'Fluxo operacional negativo';
  }

  String get investmentStatusLabel {
    if (caixa >= 150000000) {
      return 'Grande margem para investimento';
    }

    if (caixa >= 70000000) {
      return 'Boa margem para investimento';
    }

    if (caixa >= 30000000) {
      return 'Margem moderada para investimento';
    }

    if (caixa >= 0) {
      return 'Baixa margem para investimento';
    }

    return 'Sem capacidade de investimento';
  }

  // =========================================================
  // NARRATIVA
  // =========================================================

  String get financeNarrative {
    if (isBroken) {
      return 'O clube atravessa um cenário de colapso financeiro.';
    }

    if (health == FinanceHealth.critico) {
      return 'A situação financeira inspira muita preocupação.';
    }

    if (isOperationalNegative) {
      return 'O fluxo operacional do clube está no vermelho.';
    }

    if (health == FinanceHealth.muitoSaudavel) {
      return 'O clube vive um dos momentos financeiros mais sólidos da temporada.';
    }

    if (health == FinanceHealth.saudavel) {
      return 'As contas do clube seguem em condição confortável.';
    }

    if (health == FinanceHealth.estavel) {
      return 'O clube mantém equilíbrio financeiro no momento.';
    }

    return 'O clube precisa monitorar melhor suas finanças.';
  }

  // =========================================================
  // SAVE SYSTEM
  // =========================================================

  Map<String, dynamic> toJson() {
    return {
      'caixa': caixa,
      'operacional': operacional,
      'debt': debt,
      'monthlyWage': monthlyWage,
      'health': health.name,
    };
  }

  static FinanceSnapshot fromJson(Map<String, dynamic> json) {
    final healthName =
        (json['health'] as String?) ?? FinanceHealth.estavel.name;

    final parsedHealth = FinanceHealth.values.firstWhere(
      (e) => e.name == healthName,
      orElse: () => FinanceHealth.estavel,
    );

    return FinanceSnapshot(
      caixa: ((json['caixa'] as num?) ?? 0).toInt(),
      operacional: ((json['operacional'] as num?) ?? 0).toInt(),
      debt: ((json['debt'] as num?) ?? 0).toInt(),
      monthlyWage: ((json['monthlyWage'] as num?) ?? 0).toInt(),
      health: parsedHealth,
    );
  }
}
