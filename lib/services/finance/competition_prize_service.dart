import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

enum MatchPrizeCompetition {
  league,
  copaBrasil,
  supercopaBrasil,
  bolivar,
  mundialAnual,
  superMundial,
}

enum KnockoutPrizeCompetition {
  copaBrasil,
  supercopaBrasil,
  bolivar,
  mundialAnual,
  superMundial,
}

enum KnockoutPrizeStage {
  participation,
  phase1,
  phase2,
  groupStage,
  roundOf16,
  quarterFinal,
  semiFinal,
  runnerUp,
  champion,
}

class CompetitionPrizeService {
  const CompetitionPrizeService();

  // ============================================================
  // LIGA NACIONAL — PRÊMIO POR RESULTADO
  // ============================================================

  int leagueMatchPrize({
    required DivisionId division,
    required int goalsFor,
    required int goalsAgainst,
  }) {
    return matchPrize(
      competition: MatchPrizeCompetition.league,
      division: division,
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
    );
  }

  // ============================================================
  // LIGA NACIONAL — PRÊMIO FINAL POR POSIÇÃO
  // ============================================================

  int leagueFinalPositionPrize({
    required DivisionId division,
    required int position,
  }) {
    final safePosition = position.clamp(1, 20);

    return switch (division) {
      DivisionId.brA => _serieAFinalPrize(safePosition),
      DivisionId.brB => _serieBFinalPrize(safePosition),
      DivisionId.brC => _serieCFinalPrize(safePosition),
      DivisionId.brD => _serieDFinalPrize(safePosition),
    };
  }

  // ============================================================
  // COPA BRASILEIRA — HELPERS DIRETOS
  // ============================================================

  int copaBrasilMatchPrize({
    required int goalsFor,
    required int goalsAgainst,
  }) {
    return matchPrize(
      competition: MatchPrizeCompetition.copaBrasil,
      goalsFor: goalsFor,
      goalsAgainst: goalsAgainst,
    );
  }

  int copaBrasilPhasePrizeByPhase(int phase) {
    return switch (phase) {
      1 => knockoutPrize(
          competition: KnockoutPrizeCompetition.copaBrasil,
          stage: KnockoutPrizeStage.phase1,
        ),
      2 => knockoutPrize(
          competition: KnockoutPrizeCompetition.copaBrasil,
          stage: KnockoutPrizeStage.phase2,
        ),
      3 => knockoutPrize(
          competition: KnockoutPrizeCompetition.copaBrasil,
          stage: KnockoutPrizeStage.roundOf16,
        ),
      4 => knockoutPrize(
          competition: KnockoutPrizeCompetition.copaBrasil,
          stage: KnockoutPrizeStage.quarterFinal,
        ),
      5 => knockoutPrize(
          competition: KnockoutPrizeCompetition.copaBrasil,
          stage: KnockoutPrizeStage.semiFinal,
        ),
      _ => 0,
    };
  }

  int copaBrasilFinalPrize({
    required bool champion,
  }) {
    return knockoutPrize(
      competition: KnockoutPrizeCompetition.copaBrasil,
      stage:
          champion ? KnockoutPrizeStage.champion : KnockoutPrizeStage.runnerUp,
    );
  }

  // ============================================================
  // PRÊMIO POR RESULTADO — COMPETIÇÕES
  // ============================================================

  int matchPrize({
    required MatchPrizeCompetition competition,
    required int goalsFor,
    required int goalsAgainst,
    DivisionId? division,
  }) {
    final result = _matchResult(goalsFor: goalsFor, goalsAgainst: goalsAgainst);

    switch (competition) {
      case MatchPrizeCompetition.league:
        final div = division ?? DivisionId.brD;
        return _leagueResultPrize(
          division: div,
          result: result,
        );

      case MatchPrizeCompetition.copaBrasil:
        return switch (result) {
          _MatchResult.win => 1000000,
          _MatchResult.draw => 500000,
          _MatchResult.loss => 0,
        };

      case MatchPrizeCompetition.supercopaBrasil:
        return switch (result) {
          _MatchResult.win => 1000000,
          _MatchResult.draw => 500000,
          _MatchResult.loss => 300000,
        };

      case MatchPrizeCompetition.bolivar:
        return switch (result) {
          _MatchResult.win => 3000000,
          _MatchResult.draw => 1000000,
          _MatchResult.loss => 500000,
        };

      case MatchPrizeCompetition.mundialAnual:
        return switch (result) {
          _MatchResult.win => 1000000,
          _MatchResult.draw => 500000,
          _MatchResult.loss => 300000,
        };

      case MatchPrizeCompetition.superMundial:
        return switch (result) {
          _MatchResult.win => 6000000,
          _MatchResult.draw => 3000000,
          _MatchResult.loss => 1000000,
        };
    }
  }

  // ============================================================
  // PRÊMIO POR FASE / FINAL — COPAS
  // ============================================================

  int knockoutPrize({
    required KnockoutPrizeCompetition competition,
    required KnockoutPrizeStage stage,
  }) {
    switch (competition) {
      case KnockoutPrizeCompetition.copaBrasil:
        return switch (stage) {
          KnockoutPrizeStage.phase1 => 3000000,
          KnockoutPrizeStage.phase2 => 6000000,
          KnockoutPrizeStage.roundOf16 => 10000000,
          KnockoutPrizeStage.quarterFinal => 18000000,
          KnockoutPrizeStage.semiFinal => 23000000,
          KnockoutPrizeStage.runnerUp => 20000000,
          KnockoutPrizeStage.champion => 55000000,
          _ => 0,
        };

      case KnockoutPrizeCompetition.supercopaBrasil:
        return switch (stage) {
          KnockoutPrizeStage.champion => 15000000,
          KnockoutPrizeStage.runnerUp => 5000000,
          _ => 0,
        };

      case KnockoutPrizeCompetition.bolivar:
        return switch (stage) {
          KnockoutPrizeStage.groupStage => 8000000,
          KnockoutPrizeStage.roundOf16 => 12000000,
          KnockoutPrizeStage.quarterFinal => 16000000,
          KnockoutPrizeStage.semiFinal => 27000000,
          KnockoutPrizeStage.runnerUp => 42000000,
          KnockoutPrizeStage.champion => 68000000,
          _ => 0,
        };

      case KnockoutPrizeCompetition.mundialAnual:
        return switch (stage) {
          KnockoutPrizeStage.champion => 50000000,
          KnockoutPrizeStage.runnerUp => 26000000,
          KnockoutPrizeStage.semiFinal => 12000000,
          _ => 0,
        };

      case KnockoutPrizeCompetition.superMundial:
        return switch (stage) {
          KnockoutPrizeStage.participation => 80000000,
          KnockoutPrizeStage.roundOf16 => 110000000,
          KnockoutPrizeStage.quarterFinal => 120000000,
          KnockoutPrizeStage.semiFinal => 140000000,
          KnockoutPrizeStage.runnerUp => 120000000,
          KnockoutPrizeStage.champion => 330000000,
          _ => 0,
        };
    }
  }

  // ============================================================
  // HELPERS INTERNOS
  // ============================================================

  int _leagueResultPrize({
    required DivisionId division,
    required _MatchResult result,
  }) {
    switch (division) {
      case DivisionId.brA:
        return switch (result) {
          _MatchResult.win => 1000000,
          _MatchResult.draw => 500000,
          _MatchResult.loss => 300000,
        };

      case DivisionId.brB:
        return switch (result) {
          _MatchResult.win => 500000,
          _MatchResult.draw => 250000,
          _MatchResult.loss => 150000,
        };

      case DivisionId.brC:
        return switch (result) {
          _MatchResult.win => 250000,
          _MatchResult.draw => 150000,
          _MatchResult.loss => 50000,
        };

      case DivisionId.brD:
        return switch (result) {
          _MatchResult.win => 150000,
          _MatchResult.draw => 90000,
          _MatchResult.loss => 30000,
        };
    }
  }

  _MatchResult _matchResult({
    required int goalsFor,
    required int goalsAgainst,
  }) {
    if (goalsFor > goalsAgainst) return _MatchResult.win;
    if (goalsFor == goalsAgainst) return _MatchResult.draw;
    return _MatchResult.loss;
  }

  int _serieAFinalPrize(int position) {
    return switch (position) {
      1 => 145000000,
      2 => 95000000,
      3 => 80000000,
      4 => 65000000,
      5 => 60000000,
      6 => 55000000,
      7 => 50000000,
      8 => 48000000,
      9 => 45000000,
      10 => 40000000,
      11 => 35000000,
      12 => 30000000,
      13 => 28000000,
      14 => 25000000,
      15 => 23000000,
      16 => 20000000,
      _ => 4000000,
    };
  }

  int _serieBFinalPrize(int position) {
    return switch (position) {
      1 => 60000000,
      2 => 45000000,
      3 => 40000000,
      4 => 35000000,
      5 => 20000000,
      6 => 18000000,
      7 => 16000000,
      8 => 14000000,
      9 => 12000000,
      10 => 10000000,
      11 => 8000000,
      12 => 7000000,
      13 => 6000000,
      14 => 5000000,
      15 => 4000000,
      16 => 3000000,
      _ => 1000000,
    };
  }

  int _serieCFinalPrize(int position) {
    return switch (position) {
      1 => 35000000,
      2 => 28000000,
      3 => 23000000,
      4 => 20000000,
      5 => 15000000,
      6 => 12000000,
      7 => 11000000,
      8 => 10000000,
      9 => 9000000,
      10 => 8000000,
      11 => 7000000,
      12 => 6000000,
      13 => 4000000,
      14 => 3000000,
      15 => 2000000,
      16 => 1000000,
      _ => 500000,
    };
  }

  int _serieDFinalPrize(int position) {
    return switch (position) {
      1 => 20000000,
      2 => 16000000,
      3 => 13000000,
      4 => 10000000,
      5 => 5000000,
      6 => 4500000,
      7 => 4000000,
      8 => 3500000,
      9 => 3000000,
      10 => 2500000,
      11 => 2000000,
      12 => 1500000,
      13 => 1000000,
      14 => 500000,
      15 => 500000,
      16 => 500000,
      _ => 250000,
    };
  }
}

enum _MatchResult {
  win,
  draw,
  loss,
}
