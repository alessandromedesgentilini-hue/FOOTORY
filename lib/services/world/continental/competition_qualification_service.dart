import 'package:footory26/services/world/catalog/south_america/south_america_club_catalog.dart';

class CompetitionQualificationService {
  const CompetitionQualificationService();

  List<String> buildSimonBolivarQualifiedClubs({
    required List<String> brazilQualifiedIds,
    required bool defendingChampionIsBrazilian,
  }) {
    final internationalClubs =
        SouthAmericaClubCatalog.simonBolivarInternationalQualified();

    final qualified = <String>[
      ...brazilQualifiedIds,
    ];

    bool removedArgentineClub = false;

    for (final club in internationalClubs) {
      if (defendingChampionIsBrazilian &&
          !removedArgentineClub &&
          club.countryId == 'AR') {
        removedArgentineClub = true;
        continue;
      }

      qualified.add(club.id);
    }

    _validateField(qualified);

    return List.unmodifiable(qualified);
  }

  bool validateSimonBolivarField(List<String> clubIds) {
    return clubIds.length == 32 && clubIds.toSet().length == clubIds.length;
  }

  void _validateField(List<String> clubIds) {
    if (clubIds.length != 32) {
      throw StateError(
        'Taça Simón Bolívar precisa de 32 clubes. Recebido: ${clubIds.length}.',
      );
    }

    final unique = clubIds.toSet();

    if (unique.length != clubIds.length) {
      throw StateError(
        'Existem clubes duplicados na classificação da Simón Bolívar.',
      );
    }
  }
}
