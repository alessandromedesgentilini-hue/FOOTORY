// lib/services/finance/finance_rules_service.dart
//
// FinanceRulesService (MVP)
// Regras de aplicação de dinheiro no clube:
// - Usa ClubeState.percentualRepasse (80/65/50/35/25)
// - Receita "grande" (venda / premiação grande):
//    -> parte entra no caixa (repasse)
//    -> resto tenta abater dívida automaticamente
//    -> se dívida acabar, sobra volta pro caixa
// - Receita "pequena" (bônus por rodada):
//    -> 100% no caixa (sem repasse/abatimento automático)
//
// Importante:
// - Domínio (ClubeState/FinanceiroClube) guarda estado e status.
// - Service aplica eventos (venda, prêmio, bônus, pagar dívida).

import '../../domain/models/clube_state.dart';

class FinanceApplyResult {
  final double valorBruto;

  /// Quanto entrou no caixa no final
  final double entrouNoCaixa;

  /// Quanto foi usado para abater dívida automaticamente
  final double abateuDivida;

  /// Quanto sobrou e voltou pro caixa porque a dívida acabou
  final double sobraParaCaixa;

  /// Percentual de repasse usado (ex: 65)
  final int percentualRepasse;

  const FinanceApplyResult({
    required this.valorBruto,
    required this.entrouNoCaixa,
    required this.abateuDivida,
    required this.sobraParaCaixa,
    required this.percentualRepasse,
  });

  Map<String, dynamic> toMap() => {
        'valorBruto': valorBruto,
        'entrouNoCaixa': entrouNoCaixa,
        'abateuDivida': abateuDivida,
        'sobraParaCaixa': sobraParaCaixa,
        'percentualRepasse': percentualRepasse,
      };
}

class FinanceRulesService {
  const FinanceRulesService();

  // =========================================================
  // POS-RODADA (MVP)
  // =========================================================

  /// Atalho MVP: aplicar finanças de rodada (matchday).
  /// - Calcula bônus por divisão
  /// - Aplica como "receita pequena" (100% no caixa)
  FinanceApplyResult aplicarPosRodadaUsuario({
    required ClubeState clube,
    required String divisao,
  }) {
    final valor = bonusRodadaPorDivisao(divisao);
    return aplicarBonusRodada(clube: clube, valor: valor);
  }

  /// Bônus bruto de rodada (matchday) por divisão.
  /// Ajusta fácil depois.
  double bonusRodadaPorDivisao(String divisao) {
    switch (divisao.toUpperCase()) {
      case 'A':
        return 8000000;
      case 'B':
        return 4000000;
      case 'C':
        return 2000000;
      default:
        return 1200000;
    }
  }

  // =========================================================
  // API PRINCIPAL
  // =========================================================

  /// Venda de jogador / prêmio grande / bilheteria final etc.
  FinanceApplyResult aplicarReceitaGrande({
    required ClubeState clube,
    required double valor,
  }) {
    return _aplicarReceitaComRepasseEAjusteDivida(
      clube: clube,
      valor: valor,
    );
  }

  /// Bônus pequeno por rodada (entra 100% no caixa).
  /// MVP: sem repasse/abatimento automático.
  FinanceApplyResult aplicarBonusRodada({
    required ClubeState clube,
    required double valor,
  }) {
    if (valor <= 0) {
      return FinanceApplyResult(
        valorBruto: valor,
        entrouNoCaixa: 0,
        abateuDivida: 0,
        sobraParaCaixa: 0,
        percentualRepasse: clube.percentualRepasse,
      );
    }

    // Receita pequena: 100% no caixa
    clube.financeiro.caixa += valor;

    return FinanceApplyResult(
      valorBruto: valor,
      entrouNoCaixa: valor,
      abateuDivida: 0,
      sobraParaCaixa: 0,
      percentualRepasse: clube.percentualRepasse,
    );
  }

  /// Alias semântico (mesma coisa de aplicarReceitaGrande)
  FinanceApplyResult aplicarVendaJogador({
    required ClubeState clube,
    required double valorVenda,
  }) {
    return aplicarReceitaGrande(clube: clube, valor: valorVenda);
  }

  /// Premiação final / premiação grande (mesma regra de receita grande)
  FinanceApplyResult aplicarPremiacao({
    required ClubeState clube,
    required double valorPremio,
  }) {
    return aplicarReceitaGrande(clube: clube, valor: valorPremio);
  }

  /// Pagamento manual de dívida com o caixa (não deixa pagar mais que o caixa)
  /// Retorna quanto efetivamente pagou.
  double pagarDividaManual({
    required ClubeState clube,
    required double valor,
  }) {
    if (valor <= 0) return 0.0;
    if (clube.financeiro.divida <= 0) return 0.0;
    if (clube.financeiro.caixa <= 0) return 0.0;

    final pago = valor.clamp(0.0, clube.financeiro.caixa);
    clube.financeiro.caixa -= pago;

    final novaDivida = clube.financeiro.divida - pago;
    clube.financeiro.divida = novaDivida < 0 ? 0 : novaDivida;

    return pago;
  }

  // =========================================================
  // IMPLEMENTAÇÃO
  // =========================================================

  FinanceApplyResult _aplicarReceitaComRepasseEAjusteDivida({
    required ClubeState clube,
    required double valor,
  }) {
    if (valor <= 0) {
      return FinanceApplyResult(
        valorBruto: valor,
        entrouNoCaixa: 0,
        abateuDivida: 0,
        sobraParaCaixa: 0,
        percentualRepasse: clube.percentualRepasse,
      );
    }

    final pct = clube.percentualRepasse;

    // Se não há dívida, tudo entra no caixa
    if (clube.financeiro.divida <= 0) {
      clube.financeiro.caixa += valor;
      return FinanceApplyResult(
        valorBruto: valor,
        entrouNoCaixa: valor,
        abateuDivida: 0,
        sobraParaCaixa: 0,
        percentualRepasse: pct,
      );
    }

    final ficaNoCaixa = valor * (pct / 100.0);
    final vaiPraDivida = valor - ficaNoCaixa;

    // Abate no máximo a dívida atual
    final abate = vaiPraDivida.clamp(0.0, clube.financeiro.divida);
    clube.financeiro.divida -= abate;
    if (clube.financeiro.divida < 0) clube.financeiro.divida = 0;

    // Se sobrou porque a dívida acabou, volta pro caixa
    final sobra = vaiPraDivida - abate;

    clube.financeiro.caixa += (ficaNoCaixa + sobra);

    return FinanceApplyResult(
      valorBruto: valor,
      entrouNoCaixa: (ficaNoCaixa + sobra),
      abateuDivida: abate,
      sobraParaCaixa: sobra,
      percentualRepasse: pct,
    );
  }
}
