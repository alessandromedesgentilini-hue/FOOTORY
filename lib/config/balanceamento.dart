// lib/config/balanceamento.dart
//
// Regras de balanceamento e utilitários para compor a nota de partida.
// Arquivo AUTOCONTIDO (só usa dart:math). CTRL+A e colar.

import 'dart:math';

/// Qualidade do encaixe tático do jogador com o plano do time.
enum EncaixeTatico { ruim, neutro, bom }

class Balanceamento {
  // ----------------------------
  // Constantes centrais (ajuste)
  // ----------------------------

  /// Penalidade quando o atleta atua fora da posição natural (multiplicativa).
  /// Ex.: nota 7.5 -> 7.5 * (1 - 0.22) = 5.85
  static const double penalidadeForaPosicao = 0.22; // 22%

  /// Bônus quando o atleta tem bom encaixe com o estilo do time (aditivo).
  /// Ex.: nota 6.8 -> 6.8 + 0.30 = 7.1
  static const double ajusteEncaixeBom = 0.30; // ~ +0.2 a +0.4

  /// Penalidade quando o encaixe é ruim (aditivo negativo).
  /// Ex.: nota 7.0 -> 7.0 - 0.50 = 6.5
  static const double ajusteEncaixeRuim = -0.50; // ~ -0.3 a -0.6

  /// Vantagem leve do mandante (aditivo). Pequena para não distorcer.
  static const double bonusMandantePadrao = 0.18;

  /// Limites de nota in-game.
  static const double minNota = 1.0;
  static const double maxNota = 10.0;

  // ---------------------------------
  // Variância: consistência do atleta
  // ---------------------------------

  /// Converte consistência (0..10) em desvio-padrão da variação da nota.
  /// Consistência alta -> sigma baixo (menos oscilação).
  static double sigmaPorConsistencia(int consist) {
    final c = consist.clamp(0, 10);
    return 0.9 * (1.0 - c / 10.0);
  }

  // ---------------
  // Aplicadores
  // ---------------

  /// Aplica penalidade por atuar fora de posição (se [foraPosicao] for true).
  static double aplicarForaPosicao(double nota, {required bool foraPosicao}) {
    if (!foraPosicao) return nota;
    return nota * (1.0 - penalidadeForaPosicao);
  }

  /// Aplica ajuste aditivo conforme o [encaixe] tático.
  static double aplicarEncaixe(double nota, EncaixeTatico encaixe) {
    switch (encaixe) {
      case EncaixeTatico.bom:
        return nota + ajusteEncaixeBom;
      case EncaixeTatico.ruim:
        return nota + ajusteEncaixeRuim;
      case EncaixeTatico.neutro:
        return nota;
    }
  }

  /// Aplica bônus de mandante (aditivo). Use 0.0 para visitante.
  static double aplicarBonusMandante(
    double nota, {
    double bonus = bonusMandantePadrao,
  }) {
    return nota + bonus;
  }

  /// Garante que a nota fique no intervalo [minNota, maxNota].
  static double clampNota(double nota) {
    if (nota < minNota) return minNota;
    if (nota > maxNota) return maxNota;
    return nota;
  }

  // ------------------------
  // Ruído Gaussiano (Box-Muller)
  // ------------------------

  /// Ruído normal padrão (média 0, sigma 1).
  static double _gaussStd(Random rng) {
    // Box–Muller
    final u1 = rng.nextDouble().clamp(1e-12, 1.0);
    final u2 = rng.nextDouble().clamp(1e-12, 1.0);
    final r = sqrt(-2.0 * log(u1));
    final theta = 2.0 * pi * u2;
    return r * cos(theta); // N(0,1)
  }

  /// Aplica ruído Gaussiano com [sigma] à nota.
  static double aplicarRuido(double nota,
      {required double sigma, Random? rng}) {
    final _rng = rng ?? Random();
    if (sigma <= 0) return nota;
    final noise = _gaussStd(_rng) * sigma;
    return nota + noise;
  }

  // ------------------------
  // Pipeline completo
  // ------------------------

  /// Simula a nota final do jogador na partida a partir de uma [base]
  /// (geralmente 1..10), considerando:
  /// - fora de posição
  /// - encaixe tático (bom/neutro/ruim)
  /// - vantagem de mandante (aditivo)
  /// - consistência (desvio-padrão do ruído)
  ///
  /// Retorna valor clamped em [1.0, 10.0].
  static double simularNotaPartida(
    double base, {
    required int consistencia0a10,
    bool foraDePosicao = false,
    EncaixeTatico encaixe = EncaixeTatico.neutro,
    bool mandante = false,
    double bonusMandante = bonusMandantePadrao,
    Random? rng,
  }) {
    var nota = base;

    // Fora de posição (multiplicativo)
    nota = aplicarForaPosicao(nota, foraPosicao: foraDePosicao);

    // Encaixe tático (aditivo)
    nota = aplicarEncaixe(nota, encaixe);

    // Mandante (aditivo)
    if (mandante) {
      nota = aplicarBonusMandante(nota, bonus: bonusMandante);
    }

    // Ruído pela consistência
    final sigma = sigmaPorConsistencia(consistencia0a10);
    nota = aplicarRuido(nota, sigma: sigma, rng: rng);

    // Limites
    return clampNota(nota);
  }
}
