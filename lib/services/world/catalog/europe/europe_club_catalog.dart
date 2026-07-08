import 'england_club_catalog.dart';
import 'france_club_catalog.dart';
import 'germany_club_catalog.dart';
import 'italy_club_catalog.dart';
import 'netherlands_club_catalog.dart';
import 'portugal_club_catalog.dart';
import 'spain_club_catalog.dart';
import 'turkey_club_catalog.dart';
import 'europe_club_entry.dart';

class EuropeClubCatalog {
  const EuropeClubCatalog._();

  static List<EuropeClubEntry> all() {
    return List.unmodifiable([
      ...GermanyClubCatalog.all(),
      ...FranceClubCatalog.all(),
      ...EnglandClubCatalog.all(),
      ...ItalyClubCatalog.all(),
      ...SpainClubCatalog.all(),
      ...NetherlandsClubCatalog.all(),
      ...PortugalClubCatalog.all(),
      ...TurkeyClubCatalog.all(),
    ]);
  }

  static EuropeClubEntry? byId(String id) {
    final target = id.trim();

    if (target.isEmpty) return null;

    for (final club in all()) {
      if (club.id == target) return club;
    }

    return null;
  }

  static List<EuropeClubEntry> byCountry(String countryId) {
    final target = countryId.trim().toUpperCase();

    return List.unmodifiable(
      all().where((club) => club.countryId == target),
    );
  }
}
