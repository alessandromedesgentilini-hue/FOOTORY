import 'package:footory26/core/seeded_rng.dart';
import 'package:footory26/models/continental/atlas_champions_club_fixture.dart';
import 'package:footory26/models/continental/atlas_champions_club_group.dart';
import 'package:footory26/models/continental/atlas_champions_club_group_table.dart';
import 'package:footory26/models/continental/atlas_champions_club_result.dart';
import 'package:footory26/services/world/catalog/world_club_registry.dart';
import 'package:footory26/services/world/catalog/world_club_summary.dart';

class AtlasChampionsClubService {
  const AtlasChampionsClubService._();

  static const String competitionId = 'ATLAS_CHAMPIONS_CLUB';
  static const String competitionName = 'ATLAS Champions Club';

  static bool isEditionYear(int seasonYear) {
    return seasonYear % 4 == 2;
  }

  static List<WorldClubSummary> buildParticipants({
    required List<String> southAmericanQualifiedClubIds,
  }) {
    final internationalClubs = WorldClubRegistry.allOutsideSouthAmerica();

    final southAmericanClubs = southAmericanQualifiedClubIds
        .map(WorldClubRegistry.byId)
        .whereType<WorldClubSummary>()
        .toList(growable: false);

    final participants = <WorldClubSummary>[
      ...internationalClubs,
      ...southAmericanClubs,
    ];

    final unique = <String, WorldClubSummary>{};

    for (final club in participants) {
      unique[club.id] = club;
    }

    return List.unmodifiable(unique.values);
  }

  static List<AtlasChampionsClubGroup> buildGroups({
    required int seasonYear,
    required List<WorldClubSummary> participants,
    required SeededRng rng,
  }) {
    if (participants.length != 32) {
      throw StateError(
        'ATLAS Champions Club precisa de 32 clubes. Atual: ${participants.length}.',
      );
    }

    final shuffled = [...participants];

    for (var i = shuffled.length - 1; i > 0; i--) {
      final j = rng.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }

    final groups = <AtlasChampionsClubGroup>[];

    for (var i = 0; i < 8; i++) {
      final letter = String.fromCharCode('A'.codeUnitAt(0) + i);
      final start = i * 4;

      groups.add(
        AtlasChampionsClubGroup(
          id: 'atlas_champions_${seasonYear}_group_$letter',
          name: 'Grupo $letter',
          clubIds: shuffled
              .skip(start)
              .take(4)
              .map((club) => club.id)
              .toList(growable: false),
        ),
      );
    }

    return List.unmodifiable(groups);
  }

  static List<AtlasChampionsClubFixture> buildGroupFixtures({
    required int seasonYear,
    required List<AtlasChampionsClubGroup> groups,
  }) {
    final fixtures = <AtlasChampionsClubFixture>[];

    for (final group in groups) {
      final clubs = group.clubIds;

      if (clubs.length != 4) {
        throw StateError('${group.name} precisa ter 4 clubes.');
      }

      fixtures.addAll([
        AtlasChampionsClubFixture(
          id: '${group.id}_r1_m1',
          seasonYear: seasonYear,
          stage: group.name,
          homeClubId: clubs[0],
          awayClubId: clubs[1],
        ),
        AtlasChampionsClubFixture(
          id: '${group.id}_r1_m2',
          seasonYear: seasonYear,
          stage: group.name,
          homeClubId: clubs[2],
          awayClubId: clubs[3],
        ),
        AtlasChampionsClubFixture(
          id: '${group.id}_r2_m1',
          seasonYear: seasonYear,
          stage: group.name,
          homeClubId: clubs[0],
          awayClubId: clubs[2],
        ),
        AtlasChampionsClubFixture(
          id: '${group.id}_r2_m2',
          seasonYear: seasonYear,
          stage: group.name,
          homeClubId: clubs[1],
          awayClubId: clubs[3],
        ),
        AtlasChampionsClubFixture(
          id: '${group.id}_r3_m1',
          seasonYear: seasonYear,
          stage: group.name,
          homeClubId: clubs[0],
          awayClubId: clubs[3],
        ),
        AtlasChampionsClubFixture(
          id: '${group.id}_r3_m2',
          seasonYear: seasonYear,
          stage: group.name,
          homeClubId: clubs[1],
          awayClubId: clubs[2],
        ),
      ]);
    }

    return List.unmodifiable(fixtures);
  }

  static AtlasChampionsClubFixture simulateFixture({
    required AtlasChampionsClubFixture fixture,
    required SeededRng rng,
    bool allowDraw = true,
  }) {
    final homeClub = WorldClubRegistry.byId(fixture.homeClubId);
    final awayClub = WorldClubRegistry.byId(fixture.awayClubId);

    if (homeClub == null) {
      throw StateError('Clube mandante não encontrado: ${fixture.homeClubId}');
    }

    if (awayClub == null) {
      throw StateError('Clube visitante não encontrado: ${fixture.awayClubId}');
    }

    final result = _simulateSingleMatch(
      homeClub: homeClub,
      awayClub: awayClub,
      rng: rng,
      allowDraw: allowDraw,
    );

    return fixture.copyWith(
      homeGoals: result.homeGoals,
      awayGoals: result.awayGoals,
      winnerClubId: result.winnerClubId,
    );
  }

  static List<AtlasChampionsClubFixture> simulateGroupStage({
    required List<AtlasChampionsClubFixture> fixtures,
    required SeededRng rng,
  }) {
    return List.unmodifiable(
      fixtures.map((fixture) {
        return simulateFixture(
          fixture: fixture,
          rng: rng,
          allowDraw: true,
        );
      }),
    );
  }

  static List<AtlasChampionsClubGroupTable> buildTables({
    required List<AtlasChampionsClubGroup> groups,
    required List<AtlasChampionsClubFixture> playedFixtures,
  }) {
    final tables = groups.map((group) {
      var table = AtlasChampionsClubGroupTable(
        groupId: group.id,
        rows: group.clubIds.map((clubId) {
          return AtlasChampionsClubGroupTableRow(clubId: clubId);
        }).toList(growable: false),
      );

      final groupFixtures = playedFixtures.where((fixture) {
        return fixture.stage == group.name;
      });

      for (final fixture in groupFixtures) {
        if (fixture.homeGoals == null || fixture.awayGoals == null) continue;

        table = table.applyFixture(
          homeClubId: fixture.homeClubId,
          awayClubId: fixture.awayClubId,
          homeGoals: fixture.homeGoals!,
          awayGoals: fixture.awayGoals!,
        );
      }

      return table;
    }).toList(growable: false);

    return List.unmodifiable(tables);
  }

  static List<String> qualifiedFromGroups({
    required List<AtlasChampionsClubGroupTable> tables,
  }) {
    final qualified = <String>[];

    for (final table in tables) {
      final standings = table.standings;

      if (standings.length < 2) {
        throw StateError('Tabela inválida na ATLAS Champions Club.');
      }

      qualified.add(standings[0].clubId);
      qualified.add(standings[1].clubId);
    }

    return List.unmodifiable(qualified);
  }

  static List<AtlasChampionsClubFixture> buildRoundOf16({
    required int seasonYear,
    required List<String> qualifiedClubIds,
  }) {
    if (qualifiedClubIds.length != 16) {
      throw StateError(
        'Oitavas precisam de 16 clubes. Atual: ${qualifiedClubIds.length}.',
      );
    }

    final fixtures = <AtlasChampionsClubFixture>[];

    for (var i = 0; i < 8; i++) {
      fixtures.add(
        AtlasChampionsClubFixture(
          id: 'atlas_champions_${seasonYear}_r16_${i + 1}',
          seasonYear: seasonYear,
          stage: 'OITAVAS',
          homeClubId: qualifiedClubIds[i],
          awayClubId: qualifiedClubIds[15 - i],
        ),
      );
    }

    return List.unmodifiable(fixtures);
  }

  static List<AtlasChampionsClubFixture> buildNextKnockoutRound({
    required int seasonYear,
    required String stage,
    required String idPrefix,
    required List<AtlasChampionsClubFixture> previousRound,
  }) {
    final winners = previousRound.map((fixture) {
      if (fixture.winnerClubId == null) {
        throw StateError('Mata-mata anterior ainda não foi concluído.');
      }

      return fixture.winnerClubId!;
    }).toList(growable: false);

    if (winners.length.isOdd) {
      throw StateError('Número inválido de classificados para $stage.');
    }

    final fixtures = <AtlasChampionsClubFixture>[];

    for (var i = 0; i < winners.length; i += 2) {
      fixtures.add(
        AtlasChampionsClubFixture(
          id: 'atlas_champions_${seasonYear}_${idPrefix}_${(i ~/ 2) + 1}',
          seasonYear: seasonYear,
          stage: stage,
          homeClubId: winners[i],
          awayClubId: winners[i + 1],
        ),
      );
    }

    return List.unmodifiable(fixtures);
  }

  static List<AtlasChampionsClubFixture> simulateKnockoutRound({
    required List<AtlasChampionsClubFixture> fixtures,
    required SeededRng rng,
  }) {
    return List.unmodifiable(
      fixtures.map((fixture) {
        return simulateFixture(
          fixture: fixture,
          rng: rng,
          allowDraw: false,
        );
      }),
    );
  }

  static AtlasChampionsClubResult simulateTournament({
    required int seasonYear,
    required List<String> southAmericanQualifiedClubIds,
    required SeededRng rng,
  }) {
    final participants = buildParticipants(
      southAmericanQualifiedClubIds: southAmericanQualifiedClubIds,
    );

    final groups = buildGroups(
      seasonYear: seasonYear,
      participants: participants,
      rng: rng,
    );

    final groupFixtures = buildGroupFixtures(
      seasonYear: seasonYear,
      groups: groups,
    );

    final playedGroupFixtures = simulateGroupStage(
      fixtures: groupFixtures,
      rng: rng,
    );

    final tables = buildTables(
      groups: groups,
      playedFixtures: playedGroupFixtures,
    );

    final qualified = qualifiedFromGroups(tables: tables);

    final roundOf16 = buildRoundOf16(
      seasonYear: seasonYear,
      qualifiedClubIds: qualified,
    );

    final playedRoundOf16 = simulateKnockoutRound(
      fixtures: roundOf16,
      rng: rng,
    );

    final quarterFinals = buildNextKnockoutRound(
      seasonYear: seasonYear,
      stage: 'QUARTAS',
      idPrefix: 'qf',
      previousRound: playedRoundOf16,
    );

    final playedQuarterFinals = simulateKnockoutRound(
      fixtures: quarterFinals,
      rng: rng,
    );

    final semifinals = buildNextKnockoutRound(
      seasonYear: seasonYear,
      stage: 'SEMIFINAL',
      idPrefix: 'sf',
      previousRound: playedQuarterFinals,
    );

    final playedSemifinals = simulateKnockoutRound(
      fixtures: semifinals,
      rng: rng,
    );

    final finalFixtures = buildNextKnockoutRound(
      seasonYear: seasonYear,
      stage: 'FINAL',
      idPrefix: 'final',
      previousRound: playedSemifinals,
    );

    final playedFinal = simulateKnockoutRound(
      fixtures: finalFixtures,
      rng: rng,
    );

    if (playedFinal.length != 1) {
      throw StateError('ATLAS Champions Club deve ter exatamente uma final.');
    }

    final finalFixture = playedFinal.first;

    if (finalFixture.winnerClubId == null) {
      throw StateError('Final da ATLAS Champions Club sem campeão.');
    }

    final runnerUpClubId = finalFixture.winnerClubId == finalFixture.homeClubId
        ? finalFixture.awayClubId
        : finalFixture.homeClubId;

    final allFixtures = <AtlasChampionsClubFixture>[
      ...playedGroupFixtures,
      ...playedRoundOf16,
      ...playedQuarterFinals,
      ...playedSemifinals,
      ...playedFinal,
    ];

    return AtlasChampionsClubResult(
      seasonYear: seasonYear,
      championClubId: finalFixture.winnerClubId!,
      runnerUpClubId: runnerUpClubId,
      groups: groups,
      tables: tables,
      fixtures: List.unmodifiable(allFixtures),
    );
  }

  static _AtlasChampionsMatchResult _simulateSingleMatch({
    required WorldClubSummary homeClub,
    required WorldClubSummary awayClub,
    required SeededRng rng,
    required bool allowDraw,
  }) {
    final homeScorePower = homeClub.basePower + 0.10;
    final awayScorePower = awayClub.basePower;

    var homeGoals = _goalsFromPower(homeScorePower, rng);
    var awayGoals = _goalsFromPower(awayScorePower, rng);

    String? winnerClubId;

    if (homeGoals > awayGoals) {
      winnerClubId = homeClub.id;
    } else if (awayGoals > homeGoals) {
      winnerClubId = awayClub.id;
    } else if (!allowDraw) {
      final homeTieWeight = homeClub.basePower + 0.08;
      final awayTieWeight = awayClub.basePower;

      final total = homeTieWeight + awayTieWeight;
      final roll = rng.nextDouble() * total;

      if (roll < homeTieWeight) {
        homeGoals += 1;
        winnerClubId = homeClub.id;
      } else {
        awayGoals += 1;
        winnerClubId = awayClub.id;
      }
    }

    return _AtlasChampionsMatchResult(
      homeGoals: homeGoals,
      awayGoals: awayGoals,
      winnerClubId: winnerClubId,
    );
  }

  static int _goalsFromPower(double power, SeededRng rng) {
    final clampedPower = power.clamp(1.0, 10.0);

    final baseChance = clampedPower / 10.0;
    var goals = 0;

    if (rng.nextDouble() < baseChance) goals++;
    if (rng.nextDouble() < baseChance * 0.70) goals++;
    if (rng.nextDouble() < baseChance * 0.40) goals++;
    if (rng.nextDouble() < baseChance * 0.16) goals++;
    if (rng.nextDouble() < baseChance * 0.05) goals++;

    return goals;
  }
}

class _AtlasChampionsMatchResult {
  final int homeGoals;
  final int awayGoals;
  final String? winnerClubId;

  const _AtlasChampionsMatchResult({
    required this.homeGoals,
    required this.awayGoals,
    required this.winnerClubId,
  });
}
