import 'package:footory26/core/seeded_rng.dart';
import 'package:footory26/models/cup_fixture.dart';

class CupTieUpdate {
  final List<CupFixture> fixtures;
  final bool tieResolved;
  final String? winnerClubId;
  final bool decidedByPenalties;

  const CupTieUpdate({
    required this.fixtures,
    required this.tieResolved,
    required this.winnerClubId,
    required this.decidedByPenalties,
  });
}

class CupService {
  const CupService();

  List<CupFixture> buildInitialBrazilCup({
    required int seasonYear,
    required List<String> serieA,
    required List<String> serieB,
    required List<String> serieC,
    required List<String> serieD,
    required List<DateTime> phaseDates,
    required SeededRng rng,
  }) {
    final cAndD = <String>[
      ...serieC,
      ...serieD,
    ];

    final shuffledLower = _shuffled(cAndD, rng);
    final out = <CupFixture>[];

    for (int i = 0; i < shuffledLower.length; i += 2) {
      if (i + 1 >= shuffledLower.length) break;

      final tieIndex = (i ~/ 2) + 1;

      out.add(
        CupFixture(
          id: 'CBR-$seasonYear-P1-$tieIndex-L1',
          competitionId: 'CBR',
          seasonYear: seasonYear,
          phase: 1,
          phaseLabel: 'Fase 1',
          leg: 1,
          homeClubId: shuffledLower[i],
          awayClubId: shuffledLower[i + 1],
          date: phaseDates.isNotEmpty
              ? phaseDates.first
              : DateTime(seasonYear, 2, 2),
        ),
      );
    }

    return out;
  }

  List<CupFixture> buildNextPhase({
    required int seasonYear,
    required int phase,
    required String phaseLabel,
    required List<String> qualifiedClubIds,
    required List<DateTime> dates,
    required SeededRng rng,
    required bool twoLegs,
    String competitionId = 'CBR',
  }) {
    final clubs = _shuffled(qualifiedClubIds, rng);
    final out = <CupFixture>[];

    for (int i = 0; i < clubs.length; i += 2) {
      if (i + 1 >= clubs.length) break;

      final a = clubs[i];
      final b = clubs[i + 1];
      final tieIndex = (i ~/ 2) + 1;

      final firstDate =
          dates.isNotEmpty ? dates.first : DateTime(seasonYear, 2 + phase, 2);

      final secondDate =
          dates.length >= 2 ? dates[1] : firstDate.add(const Duration(days: 7));

      out.add(
        CupFixture(
          id: '$competitionId-$seasonYear-P$phase-$tieIndex-L1',
          competitionId: competitionId,
          seasonYear: seasonYear,
          phase: phase,
          phaseLabel: phaseLabel,
          leg: 1,
          homeClubId: a,
          awayClubId: b,
          date: firstDate,
        ),
      );

      if (twoLegs) {
        out.add(
          CupFixture(
            id: '$competitionId-$seasonYear-P$phase-$tieIndex-L2',
            competitionId: competitionId,
            seasonYear: seasonYear,
            phase: phase,
            phaseLabel: phaseLabel,
            leg: 2,
            homeClubId: b,
            awayClubId: a,
            date: secondDate,
          ),
        );
      }
    }

    return out;
  }

  CupFixture applySingleMatchResult({
    required CupFixture fixture,
    required int homeGoals,
    required int awayGoals,
    required SeededRng rng,
    String? penaltyWinnerClubId,
  }) {
    final winner = winnerOfSingleMatch(
      fixture: fixture,
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      rng: rng,
      penaltyWinnerClubId: penaltyWinnerClubId,
    );

    return fixture.copyWith(
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      resolved: true,
      winnerClubId: winner,
    );
  }

  CupTieUpdate applyKnockoutFixtureResult({
    required List<CupFixture> fixtures,
    required CupFixture fixture,
    required int homeGoals,
    required int awayGoals,
    required SeededRng rng,
    String? penaltyWinnerClubId,
  }) {
    final sameTie = fixtures.where((f) => _sameTie(f, fixture)).toList();

    if (sameTie.length <= 1) {
      final updated = applySingleMatchResult(
        fixture: fixture,
        homeGoals: homeGoals,
        awayGoals: awayGoals,
        rng: rng,
        penaltyWinnerClubId: penaltyWinnerClubId,
      );

      return CupTieUpdate(
        fixtures: <CupFixture>[updated],
        tieResolved: true,
        winnerClubId: updated.winnerClubId,
        decidedByPenalties: homeGoals == awayGoals,
      );
    }

    final updatedCurrent = fixture.copyWith(
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      resolved: false,
      winnerClubId: null,
    );

    final rebuiltTie = sameTie.map((f) {
      if (f.id == fixture.id) return updatedCurrent;
      return f;
    }).toList();

    rebuiltTie.sort((a, b) => a.leg.compareTo(b.leg));

    final leg1 = rebuiltTie.firstWhere(
      (f) => f.leg == 1,
      orElse: () => rebuiltTie.first,
    );

    final leg2 = rebuiltTie.firstWhere(
      (f) => f.leg == 2,
      orElse: () => rebuiltTie.last,
    );

    if (!leg1.isPlayed || !leg2.isPlayed) {
      return CupTieUpdate(
        fixtures: rebuiltTie,
        tieResolved: false,
        winnerClubId: null,
        decidedByPenalties: false,
      );
    }

    final clubA = leg1.homeClubId;
    final clubB = leg1.awayClubId;

    final clubAGoals = leg1.homeGoals! + leg2.awayGoals!;
    final clubBGoals = leg1.awayGoals! + leg2.homeGoals!;

    String winner;
    var decidedByPenalties = false;

    if (clubAGoals > clubBGoals) {
      winner = clubA;
    } else if (clubBGoals > clubAGoals) {
      winner = clubB;
    } else {
      decidedByPenalties = true;

      if (penaltyWinnerClubId != null &&
          (penaltyWinnerClubId == clubA || penaltyWinnerClubId == clubB)) {
        winner = penaltyWinnerClubId;
      } else {
        winner = rng.nextInt(2) == 0 ? clubA : clubB;
      }
    }

    final resolvedTie = rebuiltTie.map((f) {
      return f.copyWith(
        resolved: true,
        winnerClubId: winner,
      );
    }).toList();

    return CupTieUpdate(
      fixtures: resolvedTie,
      tieResolved: true,
      winnerClubId: winner,
      decidedByPenalties: decidedByPenalties,
    );
  }

  String winnerOfSingleMatch({
    required CupFixture fixture,
    required int homeGoals,
    required int awayGoals,
    required SeededRng rng,
    String? penaltyWinnerClubId,
  }) {
    if (homeGoals > awayGoals) return fixture.homeClubId;
    if (awayGoals > homeGoals) return fixture.awayClubId;

    if (penaltyWinnerClubId != null &&
        (penaltyWinnerClubId == fixture.homeClubId ||
            penaltyWinnerClubId == fixture.awayClubId)) {
      return penaltyWinnerClubId;
    }

    return rng.nextInt(2) == 0 ? fixture.homeClubId : fixture.awayClubId;
  }

  bool isPhaseResolved({
    required List<CupFixture> fixtures,
    required int phase,
  }) {
    final phaseFixtures = fixtures.where((f) => f.phase == phase).toList();

    if (phaseFixtures.isEmpty) return false;

    return phaseFixtures.every((f) => f.resolved && f.winnerClubId != null);
  }

  List<String> winnersOfPhase({
    required List<CupFixture> fixtures,
    required int phase,
  }) {
    final phaseFixtures = fixtures.where((f) => f.phase == phase).toList();

    final winners = <String>[];
    final seen = <String>{};

    for (final f in phaseFixtures) {
      final winner = f.winnerClubId?.trim();

      if (winner != null && winner.isNotEmpty && !seen.contains(winner)) {
        seen.add(winner);
        winners.add(winner);
      }
    }

    return winners;
  }

  List<String> winnersFromPlayedFixtures(List<CupFixture> fixtures) {
    final winners = <String>[];
    final seen = <String>{};

    for (final f in fixtures) {
      final winner = f.winnerClubId?.trim();

      if (winner != null && winner.isNotEmpty && !seen.contains(winner)) {
        seen.add(winner);
        winners.add(winner);
      }
    }

    return winners;
  }

  bool _sameTie(CupFixture a, CupFixture b) {
    if (a.competitionId != b.competitionId) return false;
    if (a.seasonYear != b.seasonYear) return false;
    if (a.phase != b.phase) return false;

    return _tieKey(a.id) == _tieKey(b.id);
  }

  String _tieKey(String id) {
    if (id.endsWith('-L1') || id.endsWith('-L2')) {
      return id.substring(0, id.length - 3);
    }

    return id;
  }

  List<String> _shuffled(List<String> input, SeededRng rng) {
    final out = List<String>.from(input);

    for (int i = out.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final tmp = out[i];
      out[i] = out[j];
      out[j] = tmp;
    }

    return out;
  }
}
