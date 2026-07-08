import 'package:footory26/models/continental/simon_bolivar_season_result.dart';

class AtlasChampionsSouthAmericaQualificationService {
  const AtlasChampionsSouthAmericaQualificationService._();

  static List<String> qualifiedClubIds({
    required int seasonYear,
    required List<SimonBolivarSeasonResult> simonBolivarResults,
  }) {
    final startYear = seasonYear - 4;
    final endYear = seasonYear - 1;

    final cycleResults = simonBolivarResults.where((result) {
      return result.seasonYear >= startYear && result.seasonYear <= endYear;
    }).toList(growable: false);

    cycleResults.sort((a, b) => a.seasonYear.compareTo(b.seasonYear));

    final qualified = <String>[];

    for (final result in cycleResults) {
      for (final clubId in result.qualificationOrder) {
        if (qualified.contains(clubId)) continue;

        qualified.add(clubId);

        if (qualified.length == 8) {
          return List.unmodifiable(qualified);
        }

        break;
      }
    }

    for (final result in cycleResults) {
      for (final clubId in result.qualificationOrder) {
        if (qualified.contains(clubId)) continue;

        qualified.add(clubId);

        if (qualified.length == 8) {
          return List.unmodifiable(qualified);
        }
      }
    }

    if (qualified.length != 8) {
      throw StateError(
        'ATLAS Champions Club precisa de 8 sul-americanos. Atual: ${qualified.length}.',
      );
    }

    return List.unmodifiable(qualified);
  }
}
