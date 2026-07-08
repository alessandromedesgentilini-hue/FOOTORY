import 'dart:math';

import 'package:footory26/models/player.dart';

class PlayerEvolutionResult {
  final int delta;
  final String message;

  const PlayerEvolutionResult({
    required this.delta,
    required this.message,
  });
}

class PlayerEvolutionService {
  const PlayerEvolutionService._();

  static final Random _rng = Random();

  static PlayerEvolutionResult applyEvolution({
    required Player player,
    required int ctLevel,
  }) {
    final int ovr = player.ovrCheio;
    final double ageBase = _ageBase(player.idade);
    final double overallMultiplier = _overallMultiplier(ovr);

    final double ctBonusBase = _ctBonusBase(ctLevel);
    final int ctIdealCap = _ctIdealCap(ctLevel);
    final double ctEfficiency = _ctEfficiencyForOvr(
      ovr: ovr,
      idealCap: ctIdealCap,
    );

    final double effectiveCtBonus = ctBonusBase * ctEfficiency;

    double rawScore = ageBase + effectiveCtBonus;
    rawScore *= overallMultiplier;

    final double randomFactor = 0.90 + (_rng.nextDouble() * 0.20);
    rawScore *= randomFactor;

    int delta = _scoreToDelta(
      rawScore: rawScore,
      ageBase: ageBase,
      ovr: ovr,
    );

    if (delta > 5) delta = 5;
    if (delta < -4) delta = -4;

    return PlayerEvolutionResult(
      delta: delta,
      message: _buildMessage(delta),
    );
  }

  static Player applyDeltaToPlayer({
    required Player player,
    required int delta,
  }) {
    final Map<String, int> newAttrs = _applyDeltaToAttributes(
      attrs: player.attrs10,
      delta: delta,
    );

    return player.copyWith(
      attrs10: newAttrs,
    );
  }

  static double _ageBase(int age) {
    if (age <= 18) return 3.0;
    if (age <= 20) return 2.5;
    if (age <= 22) return 2.0;
    if (age <= 24) return 1.5;
    if (age <= 27) return 1.0;
    if (age <= 29) return 0.5;
    if (age <= 31) return 0.0;
    if (age <= 33) return -1.0;
    if (age <= 35) return -2.0;
    return -3.0;
  }

  static double _overallMultiplier(int ovr) {
    if (ovr <= 59) return 1.00;
    if (ovr <= 64) return 0.72;
    if (ovr <= 69) return 0.55;
    if (ovr <= 74) return 0.35;
    if (ovr <= 79) return 0.22;
    if (ovr <= 84) return 0.12;
    return 0.05;
  }

  static double _ctBonusBase(int level) {
    switch (level.clamp(1, 10)) {
      case 1:
        return 0.5;
      case 2:
        return 0.8;
      case 3:
        return 1.1;
      case 4:
        return 1.4;
      case 5:
        return 1.7;
      case 6:
        return 2.0;
      case 7:
        return 2.3;
      case 8:
        return 2.6;
      case 9:
        return 2.9;
      case 10:
        return 3.3;
      default:
        return 1.0;
    }
  }

  static int _ctIdealCap(int level) {
    switch (level.clamp(1, 10)) {
      case 1:
        return 55;
      case 2:
        return 60;
      case 3:
        return 63;
      case 4:
        return 66;
      case 5:
        return 69;
      case 6:
        return 73;
      case 7:
        return 76;
      case 8:
        return 79;
      case 9:
        return 82;
      case 10:
        return 86;
      default:
        return 60;
    }
  }

  static double _ctEfficiencyForOvr({
    required int ovr,
    required int idealCap,
  }) {
    if (ovr <= idealCap) return 1.00;
    if (ovr <= idealCap + 3) return 0.70;
    if (ovr <= idealCap + 6) return 0.40;
    return 0.20;
  }

  static int _scoreToDelta({
    required double rawScore,
    required double ageBase,
    required int ovr,
  }) {
    if (rawScore > 0) {
      if (rawScore >= 3.80) return 5;
      if (rawScore >= 3.00) return 4;
      if (rawScore >= 2.20) return 3;
      if (rawScore >= 1.40) return 2;
      if (rawScore >= 0.65) return 1;

      if (ageBase > 0 && ovr <= 69 && _rng.nextDouble() < 0.30) {
        return 1;
      }

      return 0;
    }

    if (rawScore < 0) {
      if (rawScore <= -3.00) return -4;
      if (rawScore <= -2.20) return -3;
      if (rawScore <= -1.40) return -2;
      if (rawScore <= -0.65) return -1;

      if (ageBase < 0 && _rng.nextDouble() < 0.25) {
        return -1;
      }

      return 0;
    }

    return 0;
  }

  static Map<String, int> _applyDeltaToAttributes({
    required Map<String, int> attrs,
    required int delta,
  }) {
    final Map<String, int> newAttrs = Map<String, int>.from(attrs);
    final List<String> keys = newAttrs.keys.toList();

    if (delta == 0 || keys.isEmpty) return newAttrs;

    final int absDelta = delta.abs();

    for (int i = 0; i < absDelta; i++) {
      final List<String> shuffledKeys = List<String>.from(keys)..shuffle(_rng);
      bool changed = false;

      for (final String key in shuffledKeys) {
        final int current = newAttrs[key] ?? 1;

        if (delta > 0) {
          if (current < 10) {
            newAttrs[key] = current + 1;
            changed = true;
            break;
          }
        } else {
          if (current > 1) {
            newAttrs[key] = current - 1;
            changed = true;
            break;
          }
        }
      }

      if (!changed) {
        break;
      }
    }

    return newAttrs;
  }

  static String _buildMessage(int delta) {
    if (delta >= 4) return 'Evolução assustadora no período';
    if (delta >= 2) return 'Evolução excelente nos treinamentos';
    if (delta == 1) return 'Boa evolução no período';
    if (delta == 0) return 'Evolução controlada no período';
    if (delta == -1) return 'Abaixo do esperado nos treinamentos';
    if (delta == -2) return 'Queda de desempenho recente';
    return 'Queda acentuada de desempenho';
  }
}
