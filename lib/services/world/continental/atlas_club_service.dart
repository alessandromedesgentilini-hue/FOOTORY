import 'package:footory26/core/seeded_rng.dart';
import 'package:footory26/models/continental/atlas_club_fixture.dart';
import 'package:footory26/models/continental/atlas_club_result.dart';
import 'package:footory26/services/world/catalog/world_club_registry.dart';
import 'package:footory26/services/world/catalog/world_club_summary.dart';
import 'package:footory26/services/world/continental/continental_champion_draw_service.dart';

class AtlasClubService {
  const AtlasClubService._();

  static const String competitionId = 'ATLAS_CLUB';
  static const String competitionName = 'ATLAS Club';

  static List<AtlasClubFixture> buildFixtures({
    required int seasonYear,
    required String simonBolivarChampionClubId,
    required SeededRng rng,
  }) {
    final europeChampion = ContinentalChampionDrawService.drawChampion(
      clubs: WorldClubRegistry.europe(),
      rng: rng,
    );

    final asiaChampion = ContinentalChampionDrawService.drawChampion(
      clubs: WorldClubRegistry.asia(),
      rng: rng,
    );

    final centralAmericaChampion = ContinentalChampionDrawService.drawChampion(
      clubs: WorldClubRegistry.centralAmerica(),
      rng: rng,
    );

    final simonBolivarChampion = WorldClubRegistry.byId(
      simonBolivarChampionClubId,
    );

    if (simonBolivarChampion == null) {
      throw StateError(
        'Campeão da Simón Bolívar não encontrado: $simonBolivarChampionClubId',
      );
    }

    return [
      AtlasClubFixture(
        id: 'atlas_${seasonYear}_sf_1',
        seasonYear: seasonYear,
        stage: 'SEMIFINAL',
        homeClubId: europeChampion.id,
        awayClubId: asiaChampion.id,
      ),
      AtlasClubFixture(
        id: 'atlas_${seasonYear}_sf_2',
        seasonYear: seasonYear,
        stage: 'SEMIFINAL',
        homeClubId: simonBolivarChampion.id,
        awayClubId: centralAmericaChampion.id,
      ),
    ];
  }

  static AtlasClubFixture buildFinal({
    required int seasonYear,
    required AtlasClubFixture semifinalOne,
    required AtlasClubFixture semifinalTwo,
  }) {
    if (!semifinalOne.isPlayed || semifinalOne.winnerClubId == null) {
      throw StateError('Semifinal 1 da ATLAS Club ainda não foi jogada.');
    }

    if (!semifinalTwo.isPlayed || semifinalTwo.winnerClubId == null) {
      throw StateError('Semifinal 2 da ATLAS Club ainda não foi jogada.');
    }

    return AtlasClubFixture(
      id: 'atlas_${seasonYear}_final',
      seasonYear: seasonYear,
      stage: 'FINAL',
      homeClubId: semifinalOne.winnerClubId!,
      awayClubId: semifinalTwo.winnerClubId!,
    );
  }

  static AtlasClubFixture simulateFixture({
    required AtlasClubFixture fixture,
    required SeededRng rng,
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
    );

    return fixture.copyWith(
      homeGoals: result.homeGoals,
      awayGoals: result.awayGoals,
      winnerClubId: result.winnerClubId,
    );
  }

  static AtlasClubResult simulateTournament({
    required int seasonYear,
    required String simonBolivarChampionClubId,
    required SeededRng rng,
  }) {
    final semifinals = buildFixtures(
      seasonYear: seasonYear,
      simonBolivarChampionClubId: simonBolivarChampionClubId,
      rng: rng,
    );

    final playedSf1 = simulateFixture(
      fixture: semifinals[0],
      rng: rng,
    );

    final playedSf2 = simulateFixture(
      fixture: semifinals[1],
      rng: rng,
    );

    final finalFixture = buildFinal(
      seasonYear: seasonYear,
      semifinalOne: playedSf1,
      semifinalTwo: playedSf2,
    );

    final playedFinal = simulateFixture(
      fixture: finalFixture,
      rng: rng,
    );

    final runnerUpClubId = playedFinal.winnerClubId == playedFinal.homeClubId
        ? playedFinal.awayClubId
        : playedFinal.homeClubId;

    final fixtures = <AtlasClubFixture>[
      playedSf1,
      playedSf2,
      playedFinal,
    ];

    return AtlasClubResult(
      seasonYear: seasonYear,
      championClubId: playedFinal.winnerClubId!,
      runnerUpClubId: runnerUpClubId,
      fixtures: List.unmodifiable(fixtures),
    );
  }

  static _AtlasClubMatchResult _simulateSingleMatch({
    required WorldClubSummary homeClub,
    required WorldClubSummary awayClub,
    required SeededRng rng,
  }) {
    final homeScorePower = homeClub.basePower + 0.15;
    final awayScorePower = awayClub.basePower;

    var homeGoals = _goalsFromPower(homeScorePower, rng);
    var awayGoals = _goalsFromPower(awayScorePower, rng);

    if (homeGoals == awayGoals) {
      final homeTieWeight = homeClub.basePower + 0.10;
      final awayTieWeight = awayClub.basePower;

      final total = homeTieWeight + awayTieWeight;
      final roll = rng.nextDouble() * total;

      if (roll < homeTieWeight) {
        homeGoals += 1;
      } else {
        awayGoals += 1;
      }
    }

    final winnerClubId = homeGoals > awayGoals ? homeClub.id : awayClub.id;

    return _AtlasClubMatchResult(
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
    if (rng.nextDouble() < baseChance * 0.72) goals++;
    if (rng.nextDouble() < baseChance * 0.42) goals++;
    if (rng.nextDouble() < baseChance * 0.18) goals++;
    if (rng.nextDouble() < baseChance * 0.06) goals++;

    return goals;
  }
}

class _AtlasClubMatchResult {
  final int homeGoals;
  final int awayGoals;
  final String winnerClubId;

  const _AtlasClubMatchResult({
    required this.homeGoals,
    required this.awayGoals,
    required this.winnerClubId,
  });
}
