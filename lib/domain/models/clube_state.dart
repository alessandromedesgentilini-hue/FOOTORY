// lib/domain/models/clube_state.dart
//
// Estado mínimo do Clube (MVP).
// Domínio puro: nenhuma lógica de UI.
//
// Responsabilidades:
// - Identidade do clube
// - Divisão atual
// - Finanças (caixa + dívida)
// - Avaliar saúde financeira
// - Definir percentual de repasse utilizável
// - ✅ (NOVO) Departamento de Futebol (olheiros/negociação/análise)
//
// NÃO decide:
// - premiação
// - mercado (as regras ficam em services)
// - UI
// - regras de jogo (isso fica em services)

import 'financeiro_clube.dart';
import 'departamento_futebol.dart';

/// Estados financeiros possíveis (MVP)
enum SaudeFinanceira {
  muitoBem,
  bem,
  razoavel,
  mal,
  criseAbsoluta,
}

class ClubeState {
  final String id; // slug estável
  String nome;
  String divisao; // "A" | "B" | "C" | "D"
  FinanceiroClube financeiro;

  /// ✅ Departamento de Futebol (staff)
  DepartamentoFutebol deptFutebol;

  ClubeState({
    required this.id,
    required this.nome,
    required this.divisao,
    required this.financeiro,
    DepartamentoFutebol? deptFutebol,
  }) : deptFutebol = deptFutebol ?? DepartamentoFutebol();

  // =========================================================
  // SAÚDE FINANCEIRA (baseada em dívida líquida)
  // =========================================================

  /// Dívida líquida = dívida - caixa
  double get dividaLiquida => financeiro.divida - financeiro.caixa;

  /// Classificação financeira do clube
  SaudeFinanceira get saudeFinanceira {
    final d = dividaLiquida;

    // Clube positivo (tem mais caixa do que dívida)
    if (d <= 0) {
      // muito bem se tiver caixa relevante
      if (financeiro.caixa >= 300000000) {
        return SaudeFinanceira.muitoBem;
      }
      return SaudeFinanceira.bem;
    }

    // Dívidas controláveis
    if (d <= 200000000) {
      return SaudeFinanceira.razoavel;
    }

    if (d <= 400000000) {
      return SaudeFinanceira.mal;
    }

    // Acima disso é caos
    return SaudeFinanceira.criseAbsoluta;
  }

  // =========================================================
  // REPASSE FINANCEIRO (regra-chave do jogo)
  // =========================================================

  /// Percentual do dinheiro que o jogador pode usar
  /// (vendas, premiações, bônus)
  ///
  /// Definição acordada:
  /// - Muito bem: 80%
  /// - Bem:       65%
  /// - Razoável:  50%
  /// - Mal:       35%
  /// - Crise:     25%
  int get percentualRepasse {
    switch (saudeFinanceira) {
      case SaudeFinanceira.muitoBem:
        return 80;
      case SaudeFinanceira.bem:
        return 65;
      case SaudeFinanceira.razoavel:
        return 50;
      case SaudeFinanceira.mal:
        return 35;
      case SaudeFinanceira.criseAbsoluta:
        return 25;
    }
  }

  /// Retorna quanto do valor bruto o clube pode realmente usar
  double aplicarRepasse(double valorBruto) {
    return valorBruto * (percentualRepasse / 100.0);
  }

  // =========================================================
  // UX / DEBUG (sem UI)
  // =========================================================

  String get labelSaudeFinanceira {
    switch (saudeFinanceira) {
      case SaudeFinanceira.muitoBem:
        return 'Muito bem financeiramente';
      case SaudeFinanceira.bem:
        return 'Financeiramente estável';
      case SaudeFinanceira.razoavel:
        return 'Situação financeira razoável';
      case SaudeFinanceira.mal:
        return 'Situação financeira delicada';
      case SaudeFinanceira.criseAbsoluta:
        return 'Crise financeira absoluta';
    }
  }

  // =========================================================
  // SAVE / LOAD
  // =========================================================

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'divisao': divisao,
        'financeiro': financeiro.toJson(),
        'deptFutebol': deptFutebol.toJson(),
      };

  static ClubeState fromJson(Map<String, dynamic> m) {
    return ClubeState(
      id: m['id'] as String,
      nome: (m['nome'] as String?) ?? 'Clube',
      divisao: (m['divisao'] as String?) ?? 'D',
      financeiro: FinanceiroClube.fromJson(
        (m['financeiro'] as Map<String, dynamic>?) ?? const {},
      ),
      deptFutebol: DepartamentoFutebol.fromJson(
        (m['deptFutebol'] as Map<String, dynamic>?) ?? const {},
      ),
    );
  }
}
