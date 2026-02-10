// lib/domain/rules/xp_rules.dart
//
// A5 — Regras canônicas de XP e evolução (FutSim)
//
// - XP ganho mensalmente
// - XP base por CT: 8/10/12/14/16
// - Bônus por minutos no mês: 0/1/2/3 (0 / 600 / 1500 / 2400+)
// - Multiplicador por idade (canônico):
//   16–19: 2.0x
//   20–22: 1.9x
//   23–26: 1.7x
//   27–30: 1.6x
//   31–34: 1.4x
//   35–37: 1.2x
//   38+:   1.0x (ou 0.8x opcional)
// - Conversão: 100 XP = 1 ponto manual (aplicado pelo usuário)
// - XP acumula; não perde entre meses
// - Regressão física em janeiro:
//   33–35: -1/ano
//   36–37: -2/ano
//   38+:   -3/ano
//   Distribuir entre atributos físicos; nunca abaixo de 1.

import '../enums/atributo.dart';

class XpRules {
  const XpRules._();

  // -------------------------
  // XP mensal
  // -------------------------

  /// XP base por nível do CT (1..5)
  static int xpBasePorCt(int ctNivel) {
    switch (ctNivel.clamp(1, 5)) {
      case 1:
        return 8;
      case 2:
        return 10;
      case 3:
        return 12;
      case 4:
        return 14;
      case 5:
        return 16;
    }
    return 8;
  }

  /// Bônus por minutos no mês (simplificado e canônico)
  /// 0 -> +0
  /// >=600 -> +1
  /// >=1500 -> +2
  /// >=2400 -> +3
  static int bonusPorMinutosNoMes(int minutos) {
    if (minutos >= 2400) return 3;
    if (minutos >= 1500) return 2;
    if (minutos >= 600) return 1;
    return 0;
  }

  /// Multiplicador por idade (canônico A5)
  /// Obs: 38+ pode ser 1.0 (padrão) ou 0.8 se você quiser mais punitivo.
  static double multIdade(int idade, {double mult38Plus = 1.0}) {
    if (idade <= 19) return 2.0;
    if (idade <= 22) return 1.9;
    if (idade <= 26) return 1.7;
    if (idade <= 30) return 1.6;
    if (idade <= 34) return 1.4;
    if (idade <= 37) return 1.2;
    return mult38Plus;
  }

  /// Calcula o XP ganho no mês.
  ///
  /// Fórmula:
  /// XP_final = (XP_CT + bonus_minutos) * mult_idade
  ///
  /// Retorna int arredondado (round) e mínimo 0.
  static int calcularXpMes({
    required int ctNivel,
    required int idade,
    required int minutosNoMes,
    double mult38Plus = 1.0,
  }) {
    final base = xpBasePorCt(ctNivel);
    final bonus = bonusPorMinutosNoMes(minutosNoMes);
    final mult = multIdade(idade, mult38Plus: mult38Plus);

    final xp = ((base + bonus) * mult).round();
    return xp < 0 ? 0 : xp;
  }

  /// Quantos pontos manuais existem para um XP acumulado.
  static int pontosDisponiveis(int xpAcumulado) => xpAcumulado ~/ 100;

  /// Consome 100 XP ao aplicar 1 ponto manual.
  static int consumirUmPonto(int xpAcumulado) {
    final novo = xpAcumulado - 100;
    return novo < 0 ? 0 : novo;
  }

  // -------------------------
  // Regressão física (Janeiro)
  // -------------------------

  static const List<Atributo> atributosFisicos = <Atributo>[
    Atributo.potencia,
    Atributo.velocidade,
    Atributo.resistencia,
    Atributo.aptidaoFisica,
    Atributo.coordenacaoMotora,
  ];

  /// Quantos pontos físicos o jogador perde neste ano, baseado na idade (canônico).
  static int perdaFisicaAnual(int idade) {
    if (idade >= 38) return 3;
    if (idade >= 36) return 2; // 36–37
    if (idade >= 33) return 1; // 33–35
    return 0;
  }

  /// Aplica regressão física distribuindo perdas entre os 5 atributos físicos.
  ///
  /// - Nunca deixa atributo abaixo de 1.
  /// - Distribuição simples e justa:
  ///   percorre a lista e tira 1 de cada enquanto ainda houver perda.
  ///
  /// Se quiser “aleatoriedade” no futuro, dá pra embaralhar a lista com seed.
  static Map<Atributo, int> aplicarRegressaoFisicaAnual({
    required Map<Atributo, int> atributos,
    required int idade,
  }) {
    final perda = perdaFisicaAnual(idade);
    if (perda <= 0) return atributos;

    // copia para não mutar o mapa original
    final out = <Atributo, int>{...atributos};

    var restante = perda;
    var i = 0;

    // Distribui em ciclo pelos 5 atributos físicos
    while (restante > 0 && i < 100) {
      i++;
      for (final a in atributosFisicos) {
        if (restante <= 0) break;
        final atual = (out[a] ?? 1).clamp(1, 10);
        if (atual > 1) {
          out[a] = atual - 1;
          restante -= 1;
        }
      }

      // Se todos já estão em 1, para (não dá pra tirar mais)
      final todosNoMin = atributosFisicos.every((a) => ((out[a] ?? 1) <= 1));
      if (todosNoMin) break;
    }

    return out;
  }
}
