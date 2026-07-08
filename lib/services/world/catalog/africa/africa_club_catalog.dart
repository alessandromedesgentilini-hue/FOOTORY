import 'africa_club_entry.dart';
import 'egypt_club_catalog.dart';

class AfricaClubCatalog {
  const AfricaClubCatalog._();

  static List<AfricaClubEntry> all() {
    return List.unmodifiable([
      ...EgyptClubCatalog.all(),
    ]);
  }

  static AfricaClubEntry? byId(String id) {
    final target = id.trim();

    if (target.isEmpty) return null;

    for (final club in all()) {
      if (club.id == target) return club;
    }

    return null;
  }

  static List<AfricaClubEntry> byCountry(String countryId) {
    final target = countryId.trim().toUpperCase();

    return List.unmodifiable(
      all().where((club) => club.countryId == target),
    );
  }
}
