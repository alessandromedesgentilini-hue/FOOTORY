// lib/sim/simulador.dart
import 'dart:math' as math;

import '../models/time_model.dart';
import '../models/estilos.dart';

class ResultadoPartida {
  final TimeModel mandante;
  final TimeModel visitante;
  final int golsMandante;
  final int golsVisitante;
  final int finalizMandante;
  final int finalizVisitante;
  final double xgMandante;
  final double xgVisitante;
  final int posseMandante; // %
  final int posseVisitante; // %

  ResultadoPartida({
    required this.mandante,
    required this.visitante,
    required this.golsMandante,
    required this.golsVisitante,
    required this.finalizMandante,
    required this.finalizVisitante,
    required this.xgMandante,
    required this.xgVisitante,
    required this.posseMandante,
    required this.posseVisitante,
  });

  @override
  String toString() =>
      '${mandante.nome} $golsMandante x $golsVisitante ${visitante.nome}  |  '
      'Posse $posseMandante%/$posseVisitante%  |  '
      'Fin. $finalizMandante/$finalizVisitante  |  '
      'xG ${xgMandante.toStringAsFixed(2)}/${xgVisitante.toStringAsFixed(2)}';
}

class SimuladorPartida {
  final math.Random _rng;
  final double bonusMandoPct; // ex.: 3.0 = +3% de efetividade
  final bool usarTendenciaDePossePorEstilo;
  final bool usarMultiplicadorDeFinalizacoesPorEstilo;
  final bool usarViesXgPorEstilo; // sem acento

  SimuladorPartida({
    int? seed,
    this.bonusMandoPct = 3.0,
    this.usarTendenciaDePossePorEstilo = true,
    this.usarMultiplicadorDeFinalizacoesPorEstilo = true,
    this.usarViesXgPorEstilo = true,
  }) : _rng = math.Random(seed);

  ResultadoPartida simular({
    required TimeModel mandante,
    required TimeModel visitante,
  }) {
    // 1) Efetividade (estilo/nível/variação + matchup)
    final efM = mandante.efetividadeContra(
      visitante.estiloAtual,
      visitante.nivelExecucao,
    );
    final efV = visitante.efetividadeContra(
      mandante.estiloAtual,
      mandante.nivelExecucao,
    );

    // 2) Bônus de consistência (até ~8%) + bônus de mando para o mandante
    double aplCons(double base, double bonusCons) =>
        (base * (1 + bonusCons / 100)).clamp(1, 120).toDouble();

    var efM2 = aplCons(efM.toDouble(), mandante.bonusConsistenciaPct());
    var efV2 = aplCons(efV.toDouble(), visitante.bonusConsistenciaPct());

    if (bonusMandoPct > 0) {
      efM2 = (efM2 * (1 + bonusMandoPct / 100)).clamp(1, 120).toDouble();
    }

    // 3) Posse de bola (cap 35–65), com leve tendência por estilo
    double ratio = efM2 / (efM2 + efV2); // sempre > 0
    double posseM = 0.5 + (ratio - 0.5) * 0.8;

    if (usarTendenciaDePossePorEstilo) {
      final bias = _posseBiasPorEstilo(mandante.estiloAtual) -
          _posseBiasPorEstilo(visitante.estiloAtual);
      posseM += bias; // pequeno viés, clamp logo abaixo
    }

    posseM = posseM.clamp(0.35, 0.65);
    final posseMandante = (posseM * 100).round();
    final posseVisitante = 100 - posseMandante;

    // 4) Chances de gol a partir de efetividade (mantendo tua curva)
    int baseChances(double ef) {
      final c = (6 + 0.2 * (ef - 35)).round(); // tua curva
      return math.max(3, math.min(20, c + _rng.nextInt(3) - 1)); // ±1 ruído
    }

    var chancesM = baseChances(efM2);
    var chancesV = baseChances(efV2);

    // 5) Finalizações ≈ chances * fator (estilo pode influenciar)
    double multFinalizacoes(Estilo e) {
      if (!usarMultiplicadorDeFinalizacoesPorEstilo) return 1.4;

      switch (e.base) {
        case BaseEstilo.tikiTaka:
          return 1.25; // mais seleção de arremate
        case BaseEstilo.gegenpress:
          return 1.55; // mais volume após pressão
        case BaseEstilo.transicao: // mapeia teu "transicaoRapida"
          return 1.45;
        case BaseEstilo.sulAmericano:
          return 1.35;
        case BaseEstilo.bolaParada: // mapeia teu "cucabol"
          return 1.30;
      }
    }

    int finalizFromChances(int c, Estilo e) {
      final mult = multFinalizacoes(e);
      final f = (c * mult + _rng.nextInt(3) - 1).round();
      return math.max(c, f); // nunca menos que o nº de chances
    }

    final fim = finalizFromChances(chancesM, mandante.estiloAtual);
    final fiv = finalizFromChances(chancesV, visitante.estiloAtual);

    // 6) xG por chance (0.05..0.15), com leve viés por estilo
    double xgPerChance(double ef, Estilo e) {
      double base = (0.07 + (ef - 40) * 0.001); // tua curva
      if (usarViesXgPorEstilo) {
        base += _xgBiasPorEstilo(e);
      }
      return base.clamp(0.05, 0.15);
    }

    final xgM = chancesM * xgPerChance(efM2, mandante.estiloAtual);
    final xgV = chancesV * xgPerChance(efV2, visitante.estiloAtual);

    // 7) Gols – binomial simples baseado em “qualidade” da chance
    double pGol(double ef, Estilo e) {
      double p = (0.10 + (ef - 50) * 0.002); // ~0.06..0.22
      if (usarViesXgPorEstilo) {
        p += _xgBiasPorEstilo(e) * 0.5; // coerente com viés de xG
      }
      return p.clamp(0.06, 0.22);
    }

    int golsBinomial(int tentativas, double p) {
      int g = 0;
      for (var i = 0; i < tentativas; i++) {
        if (_rng.nextDouble() < p) g++;
      }
      return g;
    }

    final gm = golsBinomial(chancesM, pGol(efM2, mandante.estiloAtual));
    final gv = golsBinomial(chancesV, pGol(efV2, visitante.estiloAtual));

    return ResultadoPartida(
      mandante: mandante,
      visitante: visitante,
      golsMandante: gm,
      golsVisitante: gv,
      finalizMandante: fim,
      finalizVisitante: fiv,
      xgMandante: double.parse(xgM.toStringAsFixed(2)),
      xgVisitante: double.parse(xgV.toStringAsFixed(2)),
      posseMandante: posseMandante,
      posseVisitante: posseVisitante,
    );
  }

  // ───────── helpers de viés por estilo ─────────

  // Tendência de POSSE (pequena): soma no mandante e subtrai do visitante
  // valores típicos: ±0.00..0.07 antes do clamp 35–65
  double _posseBiasPorEstilo(Estilo e) {
    switch (e.base) {
      case BaseEstilo.tikiTaka:
        return 0.07;
      case BaseEstilo.gegenpress:
        return 0.02;
      case BaseEstilo.transicao: // mapeia teu "transicaoRapida"
        return -0.03;
      case BaseEstilo.sulAmericano:
        return 0.00;
      case BaseEstilo.bolaParada: // mapeia teu "cucabol"
        return -0.05;
    }
  }

  // Viés leve em xG/chance e pGol (mantém tudo clampado)
  double _xgBiasPorEstilo(Estilo e) {
    switch (e.base) {
      case BaseEstilo.tikiTaka:
        return 0.015; // lapida melhor a chance
      case BaseEstilo.gegenpress:
        return 0.005; // volume alto, qualidade média
      case BaseEstilo.transicao: // "transicaoRapida"
        return 0.010; // contra-ataques bons
      case BaseEstilo.sulAmericano:
        return 0.000;
      case BaseEstilo.bolaParada: // "cucabol"
        return 0.005; // bola parada ajuda xG médio
    }
  }
}
