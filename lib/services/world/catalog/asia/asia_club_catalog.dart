import 'asia_club_entry.dart';
import 'japan_club_catalog.dart';
import 'saudi_arabia_club_catalog.dart';
import 'south_korea_club_catalog.dart';

class AsiaClubCatalog {
  const AsiaClubCatalog._();

  static List<AsiaClubEntry> all() {
    final clubs = <AsiaClubEntry>[
      ...SaudiArabiaClubCatalog.all(),
      ...SouthKoreaClubCatalog.all(),
      ...JapanClubCatalog.all(),
    ];

    return List.unmodifiable(clubs);
  }

  static AsiaClubEntry? byId(String id) {
    final target = id.trim();
    if (target.isEmpty) return null;

    for (final club in all()) {
      if (club.id == target) return club;
    }

    return null;
  }

  static List<AsiaClubEntry> byCountry(String countryId) {
    final target = countryId.trim().toUpperCase();

    return List.unmodifiable(
      all().where((club) => club.countryId == target),
    );
  }
}
