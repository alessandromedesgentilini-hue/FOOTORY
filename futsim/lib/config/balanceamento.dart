class Balanceamento {
  // Penalidade fora de posição (aplicada IN-GAME)
  static const double penalidadeForaPosicao = 0.22; // 22%

  // Ajustes de encaixe com o estilo do time (efeito na nota da partida)
  static const double ajusteEncaixeBom = 0.3; // ~ +0.2 a +0.4
  static const double ajusteEncaixeRuim = -0.5; // ~ -0.3 a -0.6

  // Consistência -> define a variância da nota (sigma)
  static double sigmaPorConsistencia(int consist) {
    final c = consist.clamp(0, 10);
    return 0.9 * (1.0 - c / 10.0);
  }
}
