import 'new_zealand_club_catalog.dart';
import 'oceania_club_entry.dart';

class OceaniaClubCatalog {
  const OceaniaClubCatalog._();

  static List<OceaniaClubEntry> all() {
    return List.unmodifiable([
      ...NewZealandClubCatalog.all(),
    ]);
  }

  static OceaniaClubEntry? byId(String id) {
    final target = id.trim();

    if (target.isEmpty) return null;

    for (final club in all()) {
      if (club.id == target) return club;
    }

    return null;
  }

  static List<OceaniaClubEntry> byCountry(String countryId) {
    final target = countryId.trim().toUpperCase();

    return List.unmodifiable(
      all().where((club) => club.countryId == target),
    );
  }
}
