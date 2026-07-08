import 'package:footory26/models/player.dart';

/// TeamPowerService
/// - Calcula força (1.0..10.0) a partir do elenco (média dos jogadores)
/// - Converte para “nível” 0..10 (floor)
/// - Converte para 5 estrelas (visual) sem meia estrela
///
/// Regra aprovada:
/// - NÃO arredonda pra cima.
/// - 7.7 continua no nível 7 (stars10 = 7).
/// - Só sobe quando cruza o inteiro (>= 8.0).
class TeamPowerService {
  const TeamPowerService();

  /// Rating do jogador em escala 1..10 (double), derivado dos 10 attrs.
  /// Ex.: soma 73 => 7.3
  double playerRating10(Player player) {
    final v = player.ovrCheio / 10.0;
    return _clamp10(v);
  }

  /// Força do time = média simples do elenco (1..10).
  /// (Aprovado: usa elenco inteiro, não só 11 titulares.)
  double squadPower10(List<Player> squad) {
    if (squad.isEmpty) return 1.0;

    double sum = 0.0;
    for (final player in squad) {
      sum += playerRating10(player);
    }

    final avg = sum / squad.length;
    return _clamp10(avg);
  }

  /// ✅ Esse é o método que teu GameState tá tentando chamar.
  double computeTeamPower(List<Player> squad) => squadPower10(squad);

  /// Converte rating 1..10 (double) para “nível” 0..10 (int) via floor.
  /// Ex.: 7.0..7.9 => 7
  int stars10FromRating(double rating10) {
    final v = _clamp10(rating10);
    return v.floor().clamp(0, 10);
  }

  /// Converte stars 0..10 para 5 ícones (0..5), sem meia estrela.
  /// Ex.: 7 => 3 ícones, 8 => 4 ícones, 10 => 5 ícones.
  int stars5FromStars10(int stars10) {
    final s = stars10.clamp(0, 10);
    return (s / 2).floor().clamp(0, 5);
  }

  /// Texto do tipo "6 / 10" baseado no floor.
  String label10FromRating(double rating10) {
    final s10 = stars10FromRating(rating10);
    return '$s10 / 10';
  }

  TeamPowerSnapshot snapshotFromSquad(List<Player> squad) {
    final power = squadPower10(squad);
    final s10 = stars10FromRating(power);
    final s5 = stars5FromStars10(s10);
    return TeamPowerSnapshot(
      power10: power,
      stars10: s10,
      stars5: s5,
      label10: '$s10 / 10',
    );
  }

  double _clamp10(double v) {
    if (v.isNaN || v.isInfinite) return 1.0;
    if (v < 1.0) return 1.0;
    if (v > 10.0) return 10.0;
    return v;
  }
}

class TeamPowerSnapshot {
  final double power10; // 1.0..10.0
  final int stars10; // 0..10 (floor)
  final int stars5; // 0..5 (visual)
  final String label10; // "X / 10"

  const TeamPowerSnapshot({
    required this.power10,
    required this.stars10,
    required this.stars5,
    required this.label10,
  });
}
