// lib/sim/simulador.dart
//
// Motor simples de simulação de partidas.
// - Mantém-se desacoplado do resto do app (só depende de TimeModel).
// - Gera gols via Poisson com pequena vantagem de mando.
// - Finalizações derivadas do xG com ruído e limites plausíveis.
// - Posse do mandante em 35..65 com leve relação ao placar.
//
// Observação: o modelo não usa atributos do TimeModel ainda; é proposital
// para o MVP. Quando quiser, injete “força”/estilo do time e ajuste o xG.

import 'dart:math';
import '../models/time_model.dart';

class ResultadoPartida {
  final TimeModel mandante;
  final TimeModel visitante;

  final int golsMandante;
  final int golsVisitante;

  final int finalizMandante; // chutes do mandante
  final int finalizVisitante; // chutes do visitante

  /// Posse de bola do mandante (0–100). A do visitante é 100 - posseMandante.
  final int posseMandante;
  int get posseVisitante => 100 - posseMandante;

  const ResultadoPartida({
    required this.mandante,
    required this.visitante,
    required this.golsMandante,
    required this.golsVisitante,
    required this.finalizMandante,
    required this.finalizVisitante,
    required this.posseMandante,
  });

  @override
  String toString() => '$golsMandante x $golsVisitante';
}

class SimuladorPartida {
  final Random _rng;
  SimuladorPartida({int seed = 0}) : _rng = Random(seed);

  ResultadoPartida simular({
    required TimeModel mandante,
    required TimeModel visitante,
  }) {
    // xG médios base com ruído; mandante tem leve vantagem
    double noise() => (_rng.nextDouble() - 0.5) * 0.9; // -0.45..0.45
    final xgM = (1.35 + noise()).clamp(0.15, 2.6);
    final xgV = (1.15 + noise()).clamp(0.15, 2.4);

    final gM = _poisson(xgM);
    final gV = _poisson(xgV);

    int shotsFor(double xg) {
      final base = (xg * 7 + _rng.nextDouble() * 5).round(); // ~3..22
      return _clampi(base, 3, 22);
    }

    final shotsM = shotsFor(xgM);
    final shotsV = shotsFor(xgV);

    // Posse: 50 + mando + leve relação com o placar + ruído, clamp 35..65
    var posseM = 50;
    posseM += 4; // casa
    posseM += (gM - gV) * 2;
    posseM += _rng.nextInt(7) - 3; // -3..+3
    posseM = _clampi(posseM, 35, 65);

    return ResultadoPartida(
      mandante: mandante,
      visitante: visitante,
      golsMandante: gM,
      golsVisitante: gV,
      finalizMandante: shotsM,
      finalizVisitante: shotsV,
      posseMandante: posseM,
    );
  }

  // Poisson(k; lambda) via método de Knuth (limitado para evitar laços longos).
  int _poisson(double lambda) {
    if (lambda <= 0) return 0;
    final L = exp(-lambda);
    var p = 1.0;
    var k = 0;
    do {
      k++;
      p *= _rng.nextDouble();
    } while (p > L && k < 12); // limita gols a ~0..11 (razoável p/ futebol)
    return k - 1;
  }
}

// ---- utils locais ----
int _clampi(int v, int lo, int hi) {
  if (v < lo) return lo;
  if (v > hi) return hi;
  return v;
}
