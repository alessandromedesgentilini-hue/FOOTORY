import 'package:footory26/core/seeded_rng.dart';

enum MatchOutcome {
  homeWin,
  draw,
  awayWin,
}

enum MatchBalance {
  veryBalanced,
  balanced,
  slightFavorite,
  clearFavorite,
  dominantFavorite,
}

class MatchResult {
  final int homeGoals;
  final int awayGoals;

  final double delta;
  final double homeWinProbability;
  final double drawProbability;
  final double awayWinProbability;

  final MatchOutcome outcome;
  final MatchBalance balance;

  const MatchResult({
    required this.homeGoals,
    required this.awayGoals,
    this.delta = 0.0,
    this.homeWinProbability = 0.0,
    this.drawProbability = 0.0,
    this.awayWinProbability = 0.0,
    this.outcome = MatchOutcome.draw,
    this.balance = MatchBalance.balanced,
  });

  bool get homeWon => homeGoals > awayGoals;
  bool get awayWon => awayGoals > homeGoals;
  bool get isDraw => homeGoals == awayGoals;

  bool get homeFavorite => delta > 0.15;
  bool get awayFavorite => delta < -0.15;
  bool get veryBalanced => balance == MatchBalance.veryBalanced;
}

class MatchEngine {
  const MatchEngine();

  MatchResult simulate({
    required double homeBasePower,
    required double awayBasePower,
    required int homeCoachLevel,
    required int awayCoachLevel,
    required int homeStadiumLevel,
    required bool applyUserHomeBonus,
    required SeededRng rng,
    bool debug = false,
    void Function(String line)? log,
  }) {
    void d(String s) {
      if (!debug) return;
      (log ?? _defaultLog)(s);
    }

    double delta = homeBasePower - awayBasePower;

    final homePct = _coachBonusPct(homeCoachLevel);
    final awayPct = _coachBonusPct(awayCoachLevel);

    if (delta.abs() >= 0.05) {
      if (delta > 0) {
        delta += delta.abs() * (homePct / 100.0);
      } else {
        delta -= delta.abs() * (awayPct / 100.0);
      }
    } else {
      delta += (homeCoachLevel - awayCoachLevel) * 0.05;
    }

    if (applyUserHomeBonus) {
      delta += _stadiumBonusPoints(homeStadiumLevel);
    }

    final deltaRaw = delta;
    final deltaClamped = deltaRaw.clamp(-3.0, 3.0);

    d('--- MatchEngine.simulate ---');
    d('homeBasePower=$homeBasePower awayBasePower=$awayBasePower');
    d('homeCoachLevel=$homeCoachLevel awayCoachLevel=$awayCoachLevel');
    d('homeStadiumLevel=$homeStadiumLevel applyUserHomeBonus=$applyUserHomeBonus');
    d('coachBonusPct home=$homePct away=$awayPct');
    d('deltaRaw=$deltaRaw deltaClamped=$deltaClamped');

    final probs = _matchProbsFromDelta(deltaClamped);

    d('probs H=${(probs.homeWin * 100).toStringAsFixed(1)}%'
        ' D=${(probs.draw * 100).toStringAsFixed(1)}%'
        ' A=${(probs.awayWin * 100).toStringAsFixed(1)}%');

    final internalOutcome = _pickOutcome(probs, rng);
    d('outcome=$internalOutcome');

    final goals = _generateGoals(
      delta: deltaClamped,
      outcome: internalOutcome,
      rng: rng,
    );

    d('goals ${goals.$1}x${goals.$2}');
    d('---------------------------');

    return MatchResult(
      homeGoals: goals.$1,
      awayGoals: goals.$2,
      delta: deltaClamped,
      homeWinProbability: probs.homeWin,
      drawProbability: probs.draw,
      awayWinProbability: probs.awayWin,
      outcome: _toPublicOutcome(internalOutcome),
      balance: _balanceFromDelta(deltaClamped),
    );
  }

  static void _defaultLog(String s) {
    // ignore: avoid_print
    print(s);
  }

  _MatchProbs _matchProbsFromDelta(double delta) {
    final absD = delta.abs();
    final base = _interpProfile(absD);

    double homeWin = base.homeWin;
    double draw = base.draw;

    if (delta < 0) {
      final favSideWin = homeWin;
      homeWin = 1.0 - draw - favSideWin;
    }

    homeWin = homeWin.clamp(0.05, 0.90);
    draw = draw.clamp(0.10, 0.45);

    double awayWin = 1.0 - draw - homeWin;

    if (awayWin < 0.05) {
      awayWin = 0.05;
      homeWin = 1.0 - draw - awayWin;
    }

    if (homeWin < 0.05) {
      homeWin = 0.05;
      awayWin = 1.0 - draw - homeWin;
    }

    final sum0 = homeWin + draw + awayWin;
    if (sum0 < 0.999 || sum0 > 1.001) {
      homeWin /= sum0;
      draw /= sum0;
      awayWin /= sum0;
    }

    return _MatchProbs(
      homeWin: homeWin,
      draw: draw,
      awayWin: awayWin,
    );
  }

  _BaseProfile _interpProfile(double absD) {
    const anchors = <_Anchor>[
      _Anchor(d: 0.0, homeWin: 0.30, draw: 0.40),
      _Anchor(d: 0.5, homeWin: 0.40, draw: 0.30),
      _Anchor(d: 1.0, homeWin: 0.52, draw: 0.26),
      _Anchor(d: 1.5, homeWin: 0.62, draw: 0.24),
      _Anchor(d: 2.0, homeWin: 0.70, draw: 0.20),
      _Anchor(d: 3.0, homeWin: 0.80, draw: 0.15),
    ];

    if (absD >= anchors.last.d) {
      final a = anchors.last;
      return _BaseProfile(homeWin: a.homeWin, draw: a.draw);
    }

    if (absD <= anchors.first.d) {
      final a = anchors.first;
      return _BaseProfile(homeWin: a.homeWin, draw: a.draw);
    }

    for (int i = 0; i < anchors.length - 1; i++) {
      final a = anchors[i];
      final b = anchors[i + 1];

      if (absD >= a.d && absD <= b.d) {
        final t = (absD - a.d) / (b.d - a.d);

        return _BaseProfile(
          homeWin: _lerp(a.homeWin, b.homeWin, t),
          draw: _lerp(a.draw, b.draw, t),
        );
      }
    }

    final a = anchors.last;
    return _BaseProfile(homeWin: a.homeWin, draw: a.draw);
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  _Outcome _pickOutcome(_MatchProbs p, SeededRng rng) {
    final r = rng.nextInt(10000);
    final h = (p.homeWin * 10000).round();
    final d = (p.draw * 10000).round();

    if (r < h) return _Outcome.home;
    if (r < h + d) return _Outcome.draw;
    return _Outcome.away;
  }

  (int, int) _generateGoals({
    required double delta,
    required _Outcome outcome,
    required SeededRng rng,
  }) {
    final absD = delta.abs();

    int maxSide = 3;
    if (absD >= 1.2) maxSide = 4;
    if (absD >= 2.0) maxSide = 5;
    if (absD >= 2.5) maxSide = 6;

    int sampleBiasedGoals(int maxG, {required double favor}) {
      final safeFavor = favor.clamp(0.15, 0.85);
      final bump = (safeFavor * 120).round();

      final w0 = 300 - bump;
      final w1 = 330 + bump;
      final w2 = 220 + bump;
      final w3 = 95 + (bump ~/ 2);
      final w4 = 35 + (bump ~/ 4);
      final w5 = 12 + (bump ~/ 8);
      final w6 = 3 + (bump ~/ 12);

      final weights = <int>[
        w0,
        w1,
        w2,
        w3,
        w4,
        w5,
        w6,
      ].map((e) => e.clamp(1, 999)).toList();

      final maxIndex = maxG.clamp(0, 6);

      int total = 0;
      for (int i = 0; i <= maxIndex; i++) {
        total += weights[i];
      }

      final r = rng.nextInt(total);

      int acc = 0;
      for (int g = 0; g <= maxIndex; g++) {
        acc += weights[g];
        if (r < acc) return g;
      }

      return maxIndex;
    }

    double favorHome = 0.45;
    double favorAway = 0.45;

    if (delta > 0) {
      favorHome = (0.45 + (absD * 0.10)).clamp(0.45, 0.85);
      favorAway = (0.45 - (absD * 0.06)).clamp(0.15, 0.45);
    } else if (delta < 0) {
      favorAway = (0.45 + (absD * 0.10)).clamp(0.45, 0.85);
      favorHome = (0.45 - (absD * 0.06)).clamp(0.15, 0.45);
    }

    if (outcome == _Outcome.draw) {
      final drawMax = (absD >= 1.8) ? 3 : 2;
      final g = sampleBiasedGoals(drawMax, favor: 0.55);
      return (g, g);
    }

    if (outcome == _Outcome.home) {
      int home = sampleBiasedGoals(maxSide, favor: favorHome);
      int away = sampleBiasedGoals(maxSide, favor: favorAway);

      if (home <= away) {
        home = (away + 1).clamp(1, maxSide);
      }

      return (home, away);
    }

    int away = sampleBiasedGoals(maxSide, favor: favorAway);
    int home = sampleBiasedGoals(maxSide, favor: favorHome);

    if (away <= home) {
      away = (home + 1).clamp(1, maxSide);
    }

    return (home, away);
  }

  MatchOutcome _toPublicOutcome(_Outcome outcome) {
    switch (outcome) {
      case _Outcome.home:
        return MatchOutcome.homeWin;
      case _Outcome.draw:
        return MatchOutcome.draw;
      case _Outcome.away:
        return MatchOutcome.awayWin;
    }
  }

  MatchBalance _balanceFromDelta(double delta) {
    final d = delta.abs();

    if (d < 0.25) return MatchBalance.veryBalanced;
    if (d < 0.70) return MatchBalance.balanced;
    if (d < 1.20) return MatchBalance.slightFavorite;
    if (d < 2.00) return MatchBalance.clearFavorite;
    return MatchBalance.dominantFavorite;
  }

  double _coachBonusPct(int level) {
    final v = level.clamp(1, 10);

    return switch (v) {
      1 => 0,
      2 => 1,
      3 => 2,
      4 => 3,
      5 => 5,
      6 => 7,
      7 => 10,
      8 => 12,
      9 => 15,
      _ => 20,
    }
        .toDouble();
  }

  double _stadiumBonusPoints(int stadiumLevel) {
    final v = stadiumLevel.clamp(1, 10);

    return switch (v) {
      1 => 0.00,
      2 => 0.08,
      3 => 0.14,
      4 => 0.20,
      5 => 0.27,
      6 => 0.34,
      7 => 0.42,
      8 => 0.50,
      9 => 0.60,
      _ => 0.70,
    };
  }
}

class _MatchProbs {
  final double homeWin;
  final double draw;
  final double awayWin;

  const _MatchProbs({
    required this.homeWin,
    required this.draw,
    required this.awayWin,
  });
}

class _BaseProfile {
  final double homeWin;
  final double draw;

  const _BaseProfile({
    required this.homeWin,
    required this.draw,
  });
}

class _Anchor {
  final double d;
  final double homeWin;
  final double draw;

  const _Anchor({
    required this.d,
    required this.homeWin,
    required this.draw,
  });
}

enum _Outcome {
  home,
  draw,
  away,
}
