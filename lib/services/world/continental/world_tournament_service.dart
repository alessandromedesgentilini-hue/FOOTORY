import 'package:footory26/core/seeded_rng.dart';
import 'package:footory26/models/continental/atlas_champions_club_result.dart';
import 'package:footory26/models/continental/atlas_club_result.dart';
import 'package:footory26/models/continental/simon_bolivar_season_result.dart';
import 'package:footory26/models/continental/world_tournament_result.dart';
import 'package:footory26/services/world/continental/atlas_champions_club_service.dart';
import 'package:footory26/services/world/continental/atlas_champions_south_america_qualification_service.dart';
import 'package:footory26/services/world/continental/atlas_club_service.dart';

class WorldTournamentService {
  const WorldTournamentService._();

  static AtlasClubResult runAtlasClub({
    required int seasonYear,
    required String simonBolivarChampionClubId,
    required SeededRng rng,
  }) {
    return AtlasClubService.simulateTournament(
      seasonYear: seasonYear,
      simonBolivarChampionClubId: simonBolivarChampionClubId,
      rng: rng,
    );
  }

  static AtlasChampionsClubResult? runAtlasChampionsClub({
    required int seasonYear,
    required List<SimonBolivarSeasonResult> simonBolivarResults,
    required SeededRng rng,
  }) {
    if (!AtlasChampionsClubService.isEditionYear(seasonYear)) {
      return null;
    }

    final qualifiedSouthAmericans =
        AtlasChampionsSouthAmericaQualificationService.qualifiedClubIds(
      seasonYear: seasonYear,
      simonBolivarResults: simonBolivarResults,
    );

    return AtlasChampionsClubService.simulateTournament(
      seasonYear: seasonYear,
      southAmericanQualifiedClubIds: qualifiedSouthAmericans,
      rng: rng,
    );
  }

  static WorldTournamentResult atlasClubSummary(
    AtlasClubResult result,
  ) {
    return WorldTournamentResult(
      competitionId: AtlasClubService.competitionId,
      competitionName: AtlasClubService.competitionName,
      seasonYear: result.seasonYear,
      championClubId: result.championClubId,
      runnerUpClubId: result.runnerUpClubId,
    );
  }

  static WorldTournamentResult atlasChampionsSummary(
    AtlasChampionsClubResult result,
  ) {
    return WorldTournamentResult(
      competitionId: AtlasChampionsClubService.competitionId,
      competitionName: AtlasChampionsClubService.competitionName,
      seasonYear: result.seasonYear,
      championClubId: result.championClubId,
      runnerUpClubId: result.runnerUpClubId,
    );
  }
}
