// lib/services/match/match_engine.dart
import 'dart:math';
import 'match_models.dart';
import 'style_tables.dart';

class MatchEngineV1 {
  /// Config MVP (ajustável depois)
  final double homeAdvantage; // bônus mandante
  final double baseGoals; // média base de gols por time (antes de ajustes)
  final double coachImpactMax; // impacto do treinador em % no poder do time

  /// Lesões (MVP)
  final double baseInjuryChancePerMatch; // ~0.12 (12%) por jogo
  final double baseYellowCards; // média
  final double baseRedChance; // chance de um amarelo virar vermelho

  const MatchEngineV1({
    this.homeAdvantage = 0.05,
    this.baseGoals = 1.20,
    this.coachImpactMax = 0.10,
    this.baseInjuryChancePerMatch = 0.12,
    this.baseYellowCards = 2.4,
    this.baseRedChance = 0.06,
  });

  MatchResult simulate({
    required TeamSnapshot home,
    required TeamSnapshot away,
    required dynamic estiloHome,
    required dynamic estiloAway,
    required MatchContext ctx,
  }) {
    final rng = Random(ctx.seed);

    final styleH = estiloFromAny(estiloHome);
    final styleA = estiloFromAny(estiloAway);
    final tabH = kStyleTables[styleH]!;
    final tabA = kStyleTables[styleA]!;

    // 1) Força "10" baseada em elenco + clube + treinador + momento
    final pH = _power10(home, isHome: true);
    final pA = _power10(away, isHome: false);

    // 2) Converte em lambdas de Poisson (gols esperados)
    // Diferença de poder vira ajuste suave.
    final diff = (pH - pA); // -? .. +?
    final diffAdj = (diff / 10.0) * 0.90; // escala suave

    // Liga: times em ligas mais fortes tendem a ter jogos um pouco mais “qualificados”.
    // No MVP isso mexe pouco: 1..10 => 0.90..1.10
    final ligaMul = _lerp(0.92, 1.08, (home.ligaNivel.clamp(1, 10) - 1) / 9.0);

    final lambdaHome =
        (baseGoals * ligaMul) * (1.0 + diffAdj).clamp(0.45, 2.80);
    final lambdaAway =
        (baseGoals * ligaMul) * (1.0 - diffAdj).clamp(0.45, 2.80);

    final gH = samplePoisson(rng, lambdaHome);
    final gA = samplePoisson(rng, lambdaAway);

    // 3) Gols + assistências (distribuição por grupos + peso por overall)
    final homeGoals = _buildGoals(rng, home, gH, tabH);
    final awayGoals = _buildGoals(rng, away, gA, tabA);

    // 4) Cartões (média simples)
    final homeCards = _buildCards(rng, home);
    final awayCards = _buildCards(rng, away);

    // 5) Lesões (uma checagem por time por jogo)
    final homeInjuries = _buildInjuries(rng, home);
    final awayInjuries = _buildInjuries(rng, away);

    return MatchResult(
      homeId: home.id,
      awayId: away.id,
      homeGoals: gH,
      awayGoals: gA,
      homeGoalEvents: homeGoals,
      awayGoalEvents: awayGoals,
      homeCards: homeCards,
      awayCards: awayCards,
      homeInjuries: homeInjuries,
      awayInjuries: awayInjuries,
    );
  }

  double _power10(TeamSnapshot t, {required bool isHome}) {
    // Base: elenco
    var p = t.forcaElenco10;

    // Clube: pequeno bump (1..10 => -0.25..+0.25)
    final clubAdj = _lerp(-0.25, 0.25, (t.clubeNivel.clamp(1, 10) - 1) / 9.0);
    p += clubAdj;

    // Treinador: impacto percentual (1..10 => -coachImpactMax..+coachImpactMax)
    final coachPct = _lerp(-coachImpactMax, coachImpactMax,
        (t.treinadorNivel.clamp(1, 10) - 1) / 9.0);
    p *= (1.0 + coachPct);

    // Momento: -10%..+10% (leve)
    p *= (1.0 + t.momento);

    // Mandante: +5% (default)
    if (isHome) p *= (1.0 + homeAdvantage);

    return p.clamp(1.0, 10.0);
  }

  List<GoalEvent> _buildGoals(
      Random rng, TeamSnapshot t, int goals, StyleTable style) {
    final titulares = t.titulares;
    if (goals <= 0 || titulares.isEmpty) return const [];

    final events = <GoalEvent>[];

    for (var i = 0; i < goals; i++) {
      final scorer = _pickByGroup(rng, titulares, style.gols);
      final assist =
          _pickAssist(rng, titulares, style.assists, avoidId: scorer.id);

      events.add(
        GoalEvent(
          minute: minuteSample(rng),
          scorerId: scorer.id,
          scorerName: scorer.nome,
          assistId: assist?.id,
          assistName: assist?.nome,
        ),
      );
    }

    // Ordena por "minuto" só pra ficar bonito
    events.sort((a, b) => a.minute.compareTo(b.minute));
    return events;
  }

  PlayerSnapshot _pickByGroup(
      Random rng, List<PlayerSnapshot> pool, Distribuicao dist) {
    // 1) escolhe grupo por peso
    final g = _weightedPickGroup(rng, dist);

    // 2) filtra candidatos
    var candidates = pool.where((p) => p.grupo == g).toList();
    if (candidates.isEmpty) {
      // fallback: qualquer um menos GK (se der)
      candidates = pool.where((p) => p.grupo != PosGrupo.gk).toList();
      if (candidates.isEmpty) candidates = pool;
    }

    // 3) escolhe jogador ponderado por overall
    return _weightedPickPlayer(rng, candidates);
  }

  PlayerSnapshot? _pickAssist(
      Random rng, List<PlayerSnapshot> pool, Distribuicao dist,
      {required String avoidId}) {
    // 15% de gols sem assistência (MVP)
    if (rng.nextDouble() < 0.15) return null;

    final g = _weightedPickGroup(rng, dist);
    var candidates =
        pool.where((p) => p.grupo == g && p.id != avoidId).toList();
    if (candidates.isEmpty) {
      candidates =
          pool.where((p) => p.id != avoidId && p.grupo != PosGrupo.gk).toList();
      if (candidates.isEmpty)
        candidates = pool.where((p) => p.id != avoidId).toList();
      if (candidates.isEmpty) return null;
    }
    return _weightedPickPlayer(rng, candidates);
  }

  List<CardEvent> _buildCards(Random rng, TeamSnapshot t) {
    final titulares = t.titulares;
    if (titulares.isEmpty) return const [];

    // Poisson em torno da média
    final yellows = samplePoisson(rng, baseYellowCards);

    final cards = <CardEvent>[];
    for (var i = 0; i < yellows; i++) {
      final p = _weightedPickPlayer(rng, titulares);
      final red = rng.nextDouble() < baseRedChance;
      cards.add(CardEvent(
          minute: minuteSample(rng),
          playerId: p.id,
          playerName: p.nome,
          red: red));
    }
    cards.sort((a, b) => a.minute.compareTo(b.minute));
    return cards;
  }

  List<InjuryEvent> _buildInjuries(Random rng, TeamSnapshot t) {
    final titulares = t.titulares;
    if (titulares.isEmpty) return const [];

    if (rng.nextDouble() > baseInjuryChancePerMatch) return const [];

    final p = _weightedPickPlayer(rng, titulares);

    // Gravidade (bem parecido com teu doc)
    final r = rng.nextDouble();
    int days;
    if (r < 0.60) {
      days = 3 + rng.nextInt(5); // 3..7
    } else if (r < 0.90) {
      days = 14 + rng.nextInt(15); // 14..28
    } else {
      days = 60 + rng.nextInt(61); // 60..120
    }

    return [
      InjuryEvent(
          minute: minuteSample(rng),
          playerId: p.id,
          playerName: p.nome,
          daysOut: days),
    ];
  }

  PosGrupo _weightedPickGroup(Random rng, Distribuicao d) {
    // Normaliza por segurança
    final sum = d.sum <= 0 ? 1.0 : d.sum;
    final r = rng.nextDouble();
    final a = d.atk / sum;
    final m = d.mid / sum;
    final de = d.def / sum;
    // other pega o resto

    if (r < a) return PosGrupo.atk;
    if (r < a + m) return PosGrupo.mid;
    if (r < a + m + de) return PosGrupo.def;
    return PosGrupo.other;
  }

  PlayerSnapshot _weightedPickPlayer(
      Random rng, List<PlayerSnapshot> candidates) {
    // peso = 0.7 + (ovr10) => evita peso 0 e dá vantagem pra melhores
    final weights = candidates.map((p) => 0.7 + p.overall10).toList();
    final total = weights.fold<double>(0, (a, b) => a + b);
    var r = rng.nextDouble() * total;

    for (var i = 0; i < candidates.length; i++) {
      r -= weights[i];
      if (r <= 0) return candidates[i];
    }
    return candidates.last;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}
