import 'package:footory26/core/seeded_rng.dart';
import 'package:footory26/models/continental/simon_bolivar_group_fixture.dart';
import 'package:footory26/models/continental/simon_bolivar_group_table.dart';
import 'package:footory26/models/cup_fixture.dart';

class SimonBolivarService {
  static const String competitionId = 'SBV';
  static const String competitionName = 'Taça Simón Bolívar';

  const SimonBolivarService();

  List<SimonBolivarGroupFixture> buildGroupStage({
    required int seasonYear,
    required List<String> qualifiedClubIds,
    required SeededRng rng,
  }) {
    if (qualifiedClubIds.length != 32) {
      throw StateError(
        'Taça Simón Bolívar precisa de 32 clubes, mas recebeu ${qualifiedClubIds.length}.',
      );
    }

    final clubs = _shuffled(qualifiedClubIds, rng);
    final out = <SimonBolivarGroupFixture>[];

    const groups = <String>['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

    for (int g = 0; g < groups.length; g++) {
      final groupId = groups[g];
      final groupClubs = clubs.skip(g * 4).take(4).toList();

      out.addAll(
        _buildGroupFixtures(
          seasonYear: seasonYear,
          groupId: groupId,
          clubs: groupClubs,
        ),
      );
    }

    return List.unmodifiable(out);
  }

  List<SimonBolivarGroupFixture> _buildGroupFixtures({
    required int seasonYear,
    required String groupId,
    required List<String> clubs,
  }) {
    if (clubs.length != 4) {
      throw StateError(
        'Grupo $groupId precisa de 4 clubes, mas recebeu ${clubs.length}.',
      );
    }

    final dates = groupStageRoundDates(seasonYear);
    final out = <SimonBolivarGroupFixture>[];

    final roundPairs = <List<List<int>>>[
      [
        [0, 1],
        [2, 3],
      ],
      [
        [0, 2],
        [3, 1],
      ],
      [
        [0, 3],
        [1, 2],
      ],
      [
        [1, 0],
        [3, 2],
      ],
      [
        [2, 0],
        [1, 3],
      ],
      [
        [3, 0],
        [2, 1],
      ],
    ];

    for (int r = 0; r < roundPairs.length; r++) {
      final round = r + 1;
      final pairs = roundPairs[r];

      for (int i = 0; i < pairs.length; i++) {
        final pair = pairs[i];

        out.add(
          SimonBolivarGroupFixture(
            id: '$competitionId-$seasonYear-G$groupId-R$round-${i + 1}',
            competitionId: competitionId,
            seasonYear: seasonYear,
            groupId: groupId,
            round: round,
            homeClubId: clubs[pair[0]],
            awayClubId: clubs[pair[1]],
            date: dates[round - 1],
          ),
        );
      }
    }

    return out;
  }

  List<DateTime> groupStageRoundDates(int seasonYear) {
    return <DateTime>[
      DateTime(seasonYear, 4, 3),
      DateTime(seasonYear, 4, 17),
      DateTime(seasonYear, 5, 8),
      DateTime(seasonYear, 5, 22),
      DateTime(seasonYear, 6, 5),
      DateTime(seasonYear, 6, 19),
    ];
  }

  List<DateTime> knockoutPhaseDates({
    required int seasonYear,
    required int phase,
  }) {
    return switch (phase) {
      1 => <DateTime>[
          DateTime(seasonYear, 7, 3),
          DateTime(seasonYear, 7, 10),
        ],
      2 => <DateTime>[
          DateTime(seasonYear, 8, 7),
          DateTime(seasonYear, 8, 14),
        ],
      3 => <DateTime>[
          DateTime(seasonYear, 9, 11),
          DateTime(seasonYear, 9, 18),
        ],
      4 => <DateTime>[
          DateTime(seasonYear, 11, 7),
        ],
      _ => <DateTime>[
          DateTime(seasonYear, 12, 1),
        ],
    };
  }

  String knockoutPhaseLabel(int phase) {
    return switch (phase) {
      1 => 'Oitavas de final',
      2 => 'Quartas de final',
      3 => 'Semifinais',
      4 => 'Final',
      _ => 'Fase $phase',
    };
  }

  bool knockoutPhaseHasTwoLegs(int phase) {
    return phase >= 1 && phase <= 3;
  }

  List<SimonBolivarGroupTable> buildGroupTables({
    required List<SimonBolivarGroupFixture> fixtures,
  }) {
    final clubsByGroup = <String, Set<String>>{};

    for (final fx in fixtures) {
      clubsByGroup.putIfAbsent(fx.groupId, () => <String>{});
      clubsByGroup[fx.groupId]!.add(fx.homeClubId);
      clubsByGroup[fx.groupId]!.add(fx.awayClubId);
    }

    final tables = <String, SimonBolivarGroupTable>{};

    for (final entry in clubsByGroup.entries) {
      tables[entry.key] = SimonBolivarGroupTable(
        groupId: entry.key,
        clubIds: entry.value.toList(),
      );
    }

    for (final fx in fixtures) {
      if (!fx.isPlayed) continue;

      final table = tables[fx.groupId];
      if (table == null) continue;

      table.applyMatch(
        homeClubId: fx.homeClubId,
        awayClubId: fx.awayClubId,
        homeGoals: fx.homeGoals!,
        awayGoals: fx.awayGoals!,
      );
    }

    final out = tables.values.toList();
    out.sort((a, b) => a.groupId.compareTo(b.groupId));

    return List.unmodifiable(out);
  }

  bool isGroupStageResolved({
    required List<SimonBolivarGroupFixture> fixtures,
  }) {
    if (fixtures.isEmpty) return false;
    return fixtures.every((fx) => fx.isPlayed);
  }

  List<String> qualifiedFromGroups({
    required List<SimonBolivarGroupFixture> fixtures,
  }) {
    final tables = buildGroupTables(fixtures: fixtures);

    if (tables.length != 8) return const <String>[];

    final qualified = <String>[];

    for (final table in tables) {
      qualified.addAll(table.topClubIds(2));
    }

    if (qualified.length != 16) return const <String>[];

    return List.unmodifiable(qualified);
  }

  List<CupFixture> buildRoundOf16({
    required int seasonYear,
    required List<SimonBolivarGroupFixture> groupFixtures,
  }) {
    final tables = buildGroupTables(fixtures: groupFixtures);

    if (tables.length != 8) return const <CupFixture>[];

    final winners = <String>[];
    final runners = <String>[];

    for (final table in tables) {
      final sorted = table.sorted();

      if (sorted.length < 2) return const <CupFixture>[];

      winners.add(sorted[0].clubId);
      runners.add(sorted[1].clubId);
    }

    if (winners.length != 8 || runners.length != 8) {
      return const <CupFixture>[];
    }

    final pairings = <List<String>>[
      [runners[7], winners[0]],
      [runners[6], winners[1]],
      [runners[5], winners[2]],
      [runners[4], winners[3]],
      [runners[3], winners[4]],
      [runners[2], winners[5]],
      [runners[1], winners[6]],
      [runners[0], winners[7]],
    ];

    return _buildKnockoutPhaseFixtures(
      seasonYear: seasonYear,
      phase: 1,
      pairings: pairings,
    );
  }

  List<CupFixture> buildNextKnockoutPhase({
    required int seasonYear,
    required List<CupFixture> knockoutFixtures,
  }) {
    if (knockoutFixtures.isEmpty) return const <CupFixture>[];

    final currentPhase =
        knockoutFixtures.map((fx) => fx.phase).reduce((a, b) => a > b ? a : b);

    if (currentPhase >= 4) return const <CupFixture>[];

    final alreadyHasNextPhase = knockoutFixtures.any(
      (fx) => fx.phase == currentPhase + 1,
    );

    if (alreadyHasNextPhase) return const <CupFixture>[];

    final currentPhaseFixtures =
        knockoutFixtures.where((fx) => fx.phase == currentPhase).toList();

    final winners = winnersFromPhase(currentPhaseFixtures);

    final expectedWinners = switch (currentPhase) {
      1 => 8,
      2 => 4,
      3 => 2,
      _ => 0,
    };

    if (winners.length != expectedWinners) {
      return const <CupFixture>[];
    }

    final pairings = <List<String>>[];

    for (int i = 0; i < winners.length; i += 2) {
      if (i + 1 >= winners.length) break;

      pairings.add(<String>[
        winners[i],
        winners[i + 1],
      ]);
    }

    return _buildKnockoutPhaseFixtures(
      seasonYear: seasonYear,
      phase: currentPhase + 1,
      pairings: pairings,
    );
  }

  String? resolveChampion({
    required List<CupFixture> knockoutFixtures,
  }) {
    final finalFixtures =
        knockoutFixtures.where((fx) => fx.phase == 4).toList();

    if (finalFixtures.length != 1) return null;

    final finalFixture = finalFixtures.first;

    if (finalFixture.resolved &&
        finalFixture.winnerClubId != null &&
        finalFixture.winnerClubId!.trim().isNotEmpty) {
      return finalFixture.winnerClubId;
    }

    if (!finalFixture.isPlayed) return null;
    if (finalFixture.homeGoals == null || finalFixture.awayGoals == null) {
      return null;
    }

    if (finalFixture.homeGoals! > finalFixture.awayGoals!) {
      return finalFixture.homeClubId;
    }

    if (finalFixture.awayGoals! > finalFixture.homeGoals!) {
      return finalFixture.awayClubId;
    }

    return _tieBreak(
      finalFixture.homeClubId,
      finalFixture.awayClubId,
    );
  }

  List<String> winnersFromPhase(List<CupFixture> fixtures) {
    if (fixtures.isEmpty) return const <String>[];

    final phase = fixtures.first.phase;

    if (fixtures.any((fx) => fx.phase != phase)) {
      return const <String>[];
    }

    if (phase == 4) {
      final champion = resolveChampion(knockoutFixtures: fixtures);
      if (champion == null) return const <String>[];
      return List.unmodifiable(<String>[champion]);
    }

    final ties = <int, List<CupFixture>>{};

    for (final fx in fixtures) {
      final tieIndex = _tieIndexFromCupFixture(fx);

      if (tieIndex == null) return const <String>[];

      ties.putIfAbsent(tieIndex, () => <CupFixture>[]);
      ties[tieIndex]!.add(fx);
    }

    final winners = <String>[];
    final sortedTieIndexes = ties.keys.toList()..sort();

    for (final tieIndex in sortedTieIndexes) {
      final tieFixtures = ties[tieIndex]!;

      if (tieFixtures.length != 2) return const <String>[];

      tieFixtures.sort((a, b) => a.leg.compareTo(b.leg));

      final resolvedWinner = _resolvedWinnerFromTie(tieFixtures);
      if (resolvedWinner != null) {
        winners.add(resolvedWinner);
        continue;
      }

      if (tieFixtures.any((fx) => !fx.isPlayed)) {
        return const <String>[];
      }

      final firstLeg = tieFixtures[0];
      final secondLeg = tieFixtures[1];

      if (firstLeg.homeGoals == null ||
          firstLeg.awayGoals == null ||
          secondLeg.homeGoals == null ||
          secondLeg.awayGoals == null) {
        return const <String>[];
      }

      final firstClubId = firstLeg.homeClubId;
      final secondClubId = firstLeg.awayClubId;

      final firstClubAggregate = firstLeg.homeGoals! + secondLeg.awayGoals!;
      final secondClubAggregate = firstLeg.awayGoals! + secondLeg.homeGoals!;

      if (firstClubAggregate > secondClubAggregate) {
        winners.add(firstClubId);
      } else if (secondClubAggregate > firstClubAggregate) {
        winners.add(secondClubId);
      } else {
        winners.add(
          _tieBreak(firstClubId, secondClubId),
        );
      }
    }

    return List.unmodifiable(winners);
  }

  String? _resolvedWinnerFromTie(List<CupFixture> tieFixtures) {
    final winners = tieFixtures
        .where((fx) => fx.resolved)
        .map((fx) => fx.winnerClubId)
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    if (winners.length == 1) return winners.first;
    return null;
  }

  List<CupFixture> _buildKnockoutPhaseFixtures({
    required int seasonYear,
    required int phase,
    required List<List<String>> pairings,
  }) {
    final dates = knockoutPhaseDates(
      seasonYear: seasonYear,
      phase: phase,
    );

    final out = <CupFixture>[];

    for (int i = 0; i < pairings.length; i++) {
      final homeFirst = pairings[i][0];
      final awayFirst = pairings[i][1];
      final tieIndex = i + 1;

      if (knockoutPhaseHasTwoLegs(phase)) {
        out.add(
          CupFixture(
            id: '$competitionId-$seasonYear-P$phase-$tieIndex-L1',
            competitionId: competitionId,
            seasonYear: seasonYear,
            phase: phase,
            phaseLabel: knockoutPhaseLabel(phase),
            leg: 1,
            homeClubId: homeFirst,
            awayClubId: awayFirst,
            date: dates[0],
          ),
        );

        out.add(
          CupFixture(
            id: '$competitionId-$seasonYear-P$phase-$tieIndex-L2',
            competitionId: competitionId,
            seasonYear: seasonYear,
            phase: phase,
            phaseLabel: knockoutPhaseLabel(phase),
            leg: 2,
            homeClubId: awayFirst,
            awayClubId: homeFirst,
            date: dates[1],
          ),
        );
      } else {
        out.add(
          CupFixture(
            id: '$competitionId-$seasonYear-P$phase-$tieIndex-L1',
            competitionId: competitionId,
            seasonYear: seasonYear,
            phase: phase,
            phaseLabel: knockoutPhaseLabel(phase),
            leg: 1,
            homeClubId: homeFirst,
            awayClubId: awayFirst,
            date: dates[0],
          ),
        );
      }
    }

    return List.unmodifiable(out);
  }

  int? _tieIndexFromCupFixture(CupFixture fixture) {
    final parts = fixture.id.split('-');

    if (parts.length < 4) return null;

    final raw = parts[3];

    return int.tryParse(raw);
  }

  String _tieBreak(String a, String b) {
    return a.compareTo(b) <= 0 ? a : b;
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
