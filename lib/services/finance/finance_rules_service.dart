class FinanceRulesService {
  /// ================================
  /// SALÁRIO (% FIXO POR NÍVEL)
  /// ================================
  ///
  /// Regra oficial MVP:
  /// - Nível 1 = 8%
  /// - Nível 10 = 4%
  double salaryPercentageByLevel(int financeLevel) {
    final lvl = financeLevel.clamp(1, 10);

    switch (lvl) {
      case 1:
        return 0.080;
      case 2:
        return 0.075;
      case 3:
        return 0.071;
      case 4:
        return 0.066;
      case 5:
        return 0.062;
      case 6:
        return 0.058;
      case 7:
        return 0.053;
      case 8:
        return 0.049;
      case 9:
        return 0.044;
      case 10:
        return 0.040;
      default:
        return 0.060;
    }
  }

  int calculateSalary({
    required int playerValue,
    required int financeLevel,
  }) {
    final pct = salaryPercentageByLevel(financeLevel);
    return (playerValue * pct).round();
  }

  /// ================================
  /// REPASSE POR SAÚDE FINANCEIRA
  /// ================================
  ///
  /// Percentual que FICA com o clube em receitas extraordinárias.
  ///
  /// Exemplo:
  /// - repasse 0.20 = clube fica com 20%
  /// - os outros 80% abatem dívida
  double repassPercentage(FinanceHealth health) {
    switch (health) {
      case FinanceHealth.muitoSaudavel:
        return 0.90;
      case FinanceHealth.saudavel:
        return 0.80;
      case FinanceHealth.estavel:
        return 0.65;
      case FinanceHealth.pressionado:
        return 0.50;
      case FinanceHealth.critico:
        return 0.35;
      case FinanceHealth.colapsoFinanceiro:
        return 0.20;
    }
  }

  /// Percentual retido para dívida.
  double debtRetentionPercentage(FinanceHealth health) {
    return 1.0 - repassPercentage(health);
  }

  /// ================================
  /// AVALIA SAÚDE PELA DÍVIDA
  /// ================================
  ///
  /// Dívida está em REAIS.
  ///
  /// Visão MVP:
  /// - até 100M: saudável de verdade
  /// - 100M–300M: ainda controlável
  /// - 300M–700M: peso real
  /// - 700M–1.2B: pressão forte
  /// - 1.2B–1.5B: crítico
  /// - 1.5B+: colapso / retenção máxima
  FinanceHealth evaluateHealth(int debt) {
    if (debt <= 100000000) {
      return FinanceHealth.muitoSaudavel;
    }

    if (debt <= 300000000) {
      return FinanceHealth.saudavel;
    }

    if (debt <= 700000000) {
      return FinanceHealth.estavel;
    }

    if (debt <= 1200000000) {
      return FinanceHealth.pressionado;
    }

    if (debt <= 1500000000) {
      return FinanceHealth.critico;
    }

    return FinanceHealth.colapsoFinanceiro;
  }

  String healthLabel(FinanceHealth health) {
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

enum FinanceHealth {
  muitoSaudavel,
  saudavel,
  estavel,
  pressionado,
  critico,
  colapsoFinanceiro,
}
