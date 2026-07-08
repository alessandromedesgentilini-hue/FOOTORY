import 'north_america_club_entry.dart';
import 'usa_club_catalog.dart';

class NorthAmericaClubCatalog {
  const NorthAmericaClubCatalog._();

  static List<NorthAmericaClubEntry> all() {
    return List.unmodifiable([
      ...UsaClubCatalog.all(),
    ]);
  }

  static NorthAmericaClubEntry? byId(String id) {
    final target = id.trim();

    if (target.isEmpty) return null;

    for (final club in all()) {
      if (club.id == target) return club;
    }

    return null;
  }

  static List<NorthAmericaClubEntry> byCountry(String countryId) {
    final target = countryId.trim().toUpperCase();

    return List.unmodifiable(
      all().where((club) => club.countryId == target),
    );
  }
}
