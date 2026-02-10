// lib/services/match/match_models.dart
import 'dart:math';

enum PosGrupo { gk, def, mid, atk, other }

class PlayerSnapshot {
  final String id;
  final String nome;
  final String
      pos; // ex: "GOL", "ZAG", "LD", "LE", "VOL", "MC", "MEI", "PE", "PD", "CA"
  final int overall100; // 0..100 (ex: 68)
  final bool isStarter;

  const PlayerSnapshot({
    required this.id,
    required this.nome,
    required this.pos,
    required this.overall100,
    this.isStarter = true,
  });

  double get overall10 => overall100 / 10.0;

  PosGrupo get grupo {
    final p = pos.toUpperCase().trim();
    if (p == "GOL" || p == "GK") return PosGrupo.gk;

    // DEF
    if (p == "ZAG" || p == "ZG" || p == "DC" || p == "CB") return PosGrupo.def;
    if (p == "LD" || p == "LE" || p == "RB" || p == "LB") return PosGrupo.def;

    // MID
    if (p == "VOL" || p == "CDM") return PosGrupo.mid;
    if (p == "MC" || p == "CM") return PosGrupo.mid;
    if (p == "MEI" || p == "CAM") return PosGrupo.mid;
    if (p == "ME" || p == "MD" || p == "RM" || p == "LM") return PosGrupo.mid;

    // ATK
    if (p == "PE" || p == "PD" || p == "LW" || p == "RW") return PosGrupo.atk;
    if (p == "CA" || p == "ST") return PosGrupo.atk;

    return PosGrupo.other;
  }
}

class TeamSnapshot {
  final String id;
  final String nome;
  final int ligaNivel; // 1..10 (ex: Serie D pode ser 3/4; tu decide)
  final int clubeNivel; // 1..10 (força estrutural do clube)
  final int treinadorNivel; // 1..10
  final double momento; // -0.10..+0.10 (bônus/penalidade leve)
  final List<PlayerSnapshot> elenco;

  const TeamSnapshot({
    required this.id,
    required this.nome,
    required this.ligaNivel,
    required this.clubeNivel,
    required this.treinadorNivel,
    required this.momento,
    required this.elenco,
  });

  List<PlayerSnapshot> get titulares =>
      elenco.where((p) => p.isStarter).toList();

  double get forcaElenco10 {
    final t = titulares;
    if (t.isEmpty) return 5.0;
    final avg = t.map((p) => p.overall10).reduce((a, b) => a + b) / t.length;
    return avg.clamp(1.0, 10.0);
  }
}

class MatchContext {
  final int seasonYear;
  final int rodada;
  final bool isCup;
  final int seed; // se quiser determinismo: combina ano/rodada/ids

  const MatchContext({
    required this.seasonYear,
    required this.rodada,
    this.isCup = false,
    required this.seed,
  });
}

class GoalEvent {
  final int minute; // apenas estética (não simula minuto a minuto)
  final String scorerId;
  final String scorerName;
  final String? assistId;
  final String? assistName;

  const GoalEvent({
    required this.minute,
    required this.scorerId,
    required this.scorerName,
    this.assistId,
    this.assistName,
  });
}

class CardEvent {
  final int minute;
  final String playerId;
  final String playerName;
  final bool red;

  const CardEvent({
    required this.minute,
    required this.playerId,
    required this.playerName,
    required this.red,
  });
}

class InjuryEvent {
  final int minute;
  final String playerId;
  final String playerName;
  final int daysOut;

  const InjuryEvent({
    required this.minute,
    required this.playerId,
    required this.playerName,
    required this.daysOut,
  });
}

class MatchResult {
  final String homeId;
  final String awayId;
  final int homeGoals;
  final int awayGoals;

  final List<GoalEvent> homeGoalEvents;
  final List<GoalEvent> awayGoalEvents;

  final List<CardEvent> homeCards;
  final List<CardEvent> awayCards;

  final List<InjuryEvent> homeInjuries;
  final List<InjuryEvent> awayInjuries;

  const MatchResult({
    required this.homeId,
    required this.awayId,
    required this.homeGoals,
    required this.awayGoals,
    required this.homeGoalEvents,
    required this.awayGoalEvents,
    required this.homeCards,
    required this.awayCards,
    required this.homeInjuries,
    required this.awayInjuries,
  });
}

int samplePoisson(Random rng, double lambda) {
  // Poisson simples (lambda ~ 0..4 típico)
  if (lambda <= 0) return 0;
  final L = exp(-lambda);
  int k = 0;
  double p = 1.0;
  do {
    k++;
    p *= rng.nextDouble();
  } while (p > L);
  return max(0, k - 1);
}

int minuteSample(Random rng) {
  // estética: 1..90 com leve viés pro fim
  final r = rng.nextDouble();
  if (r < 0.15) return 1 + rng.nextInt(20); // 1..20
  if (r < 0.55) return 21 + rng.nextInt(35); // 21..55
  return 56 + rng.nextInt(35); // 56..90
}
