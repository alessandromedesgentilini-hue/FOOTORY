import 'finance_rules_service.dart';
import 'finance_snapshot.dart';

class FinanceClubService {
  final FinanceRulesService rules;

  FinanceClubService(this.rules);

  /// =========================================================
  /// RECEITAS
  /// =========================================================
  ///
  /// FULL REVENUE:
  /// - Bilheteria
  /// - Bônus de partida
  /// - Receitas operacionais do dia a dia
  ///
  /// Vai 100% para o fluxo operacional.
  ///
  /// ---------------------------------------------------------
  ///
  /// RESTRICTED REVENUE:
  /// - Patrocínio
  /// - Premiação
  /// - Venda de jogador
  ///
  /// Primeiro reduz dívida.
  /// Depois divide:
  ///
  /// 50% caixa livre
  /// 50% operacional
  ///
  FinanceSnapshot applyIncome({
    required FinanceSnapshot snapshot,
    required int value,
    required bool isFullRevenue,
  }) {
    if (value <= 0) return snapshot;

    /// ======================================================
    /// RECEITA OPERACIONAL DIRETA
    /// ======================================================
    if (isFullRevenue) {
      return snapshot.copyWith(
        operacional: snapshot.operacional + value,
      );
    }

    /// ======================================================
    /// RECEITA COM RETENÇÃO
    /// ======================================================
    final repassPct = rules.repassPercentage(snapshot.health);

    final received = (value * repassPct).round();
    final debtReduction = value - received;

    final operacional = (received * 0.5).round();
    final caixa = received - operacional;

    return snapshot.copyWith(
      caixa: snapshot.caixa + caixa,
      operacional: snapshot.operacional + operacional,
      debt: (snapshot.debt - debtReduction).clamp(
        0,
        2000000000,
      ),
    );
  }

  /// =========================================================
  /// PAGAMENTO DE SALÁRIOS
  /// =========================================================
  ///
  /// Se faltar operacional:
  ///
  /// - pega empréstimo automático
  /// - juros fixos de 20%
  /// - dívida sobe imediatamente
  ///
  FinanceSnapshot paySalaries(FinanceSnapshot snapshot) {
    final afterOperational = snapshot.operacional - snapshot.monthlyWage;

    /// conseguiu pagar normal
    if (afterOperational >= 0) {
      return snapshot.copyWith(
        operacional: afterOperational,
      );
    }

    /// faltou dinheiro
    final missing = afterOperational.abs();

    final debtIncrease = (missing * 1.20).round();

    return snapshot.copyWith(
      operacional: 0,
      debt: snapshot.debt + debtIncrease,
    );
  }

  /// =========================================================
  /// SAÚDE FINANCEIRA
  /// =========================================================
  FinanceSnapshot refreshHealth(FinanceSnapshot snapshot) {
    final newHealth = rules.evaluateHealth(snapshot.debt);

    return snapshot.copyWith(
      health: newHealth,
    );
  }

  /// =========================================================
  /// CONTRATAÇÃO
  /// =========================================================
  FinanceSnapshot applyTransfer({
    required FinanceSnapshot snapshot,
    required int transferCost,
    required int salary,
  }) {
    return snapshot.copyWith(
      caixa: snapshot.caixa - transferCost,
      monthlyWage: snapshot.monthlyWage + salary,
    );
  }

  /// =========================================================
  /// VENDA
  /// =========================================================
  FinanceSnapshot applySale({
    required FinanceSnapshot snapshot,
    required int value,
    required int salaryRemoved,
  }) {
    final updated = applyIncome(
      snapshot: snapshot,
      value: value,
      isFullRevenue: false,
    );

    return updated.copyWith(
      monthlyWage: (updated.monthlyWage - salaryRemoved).clamp(
        0,
        9999999,
      ),
    );
  }
}
