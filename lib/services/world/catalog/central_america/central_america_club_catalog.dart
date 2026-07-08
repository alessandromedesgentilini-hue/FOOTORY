import 'central_america_club_entry.dart';
import 'mexico_club_catalog.dart';

class CentralAmericaClubCatalog {
  const CentralAmericaClubCatalog._();

  static List<CentralAmericaClubEntry> all() {
    return List.unmodifiable([
      ...MexicoClubCatalog.all(),
    ]);
  }

  static CentralAmericaClubEntry? byId(String id) {
    final target = id.trim();

    if (target.isEmpty) return null;

    for (final club in all()) {
      if (club.id == target) return club;
    }

    return null;
  }

  static List<CentralAmericaClubEntry> byCountry(String countryId) {
    final target = countryId.trim().toUpperCase();

    return List.unmodifiable(
      all().where((club) => club.countryId == target),
    );
  }
}
