// lib/services/team_power_service.dart

import '../core/seeded_rng.dart';

class TeamPowerContext {
  final double ovrMedia100; // 0..100 (média do elenco * 10)
  final double idxEstruturas100; // 0..100 (força do clube/estruturas * 10)
  final int taticaBonus; // {0,5,10,15,20}
  final bool mandante; // true => +5
  final int seed; // reprodutibilidade

  const TeamPowerContext({
    required this.ovrMedia100,
    required this.idxEstruturas100,
    required this.taticaBonus,
    required this.mandante,
    required this.seed,
  });
}

class TeamPowerService {
  const TeamPowerService();

  double calcularM(TeamPowerContext ctx) {
    final home = ctx.mandante ? 5.0 : 0.0;

    // ruído leve determinístico (-5..+5)
    // OBS: isso não é "aleatório do nada": com o mesmo seed, sai o mesmo epsilon.
    final rng = SeededRng(ctx.seed ^ 0x1f2e3d4c);
    final epsilon = (rng.next() * 10.0) - 5.0; // [-5, +5)

    final m = 0.60 * ctx.ovrMedia100 +
        0.30 * ctx.idxEstruturas100 +
        0.10 * (ctx.taticaBonus + home) +
        epsilon;

    return m.clamp(0.0, 120.0);
  }
}
