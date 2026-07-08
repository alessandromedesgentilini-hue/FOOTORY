class TierService {
  /// Converte diferença de força em tier de vantagem.
  ///
  /// diff = homePower - awayPower
  ///
  /// Retorna: -3 .. +3
  /// (negativo = visitante melhor)
  static int fromPowerDiff(double diff) {
    if (diff >= 25) return 3;
    if (diff >= 15) return 2;
    if (diff >= 7) return 1;

    if (diff <= -25) return -3;
    if (diff <= -15) return -2;
    if (diff <= -7) return -1;

    return 0;
  }

  /// Bônus percentual baseado no tier
  static double bonusMultiplier(int tier) {
    switch (tier) {
      case 3:
        return 1.35;
      case 2:
        return 1.22;
      case 1:
        return 1.10;

      case -1:
        return 0.90;
      case -2:
        return 0.78;
      case -3:
        return 0.65;

      default:
        return 1.0;
    }
  }
}
