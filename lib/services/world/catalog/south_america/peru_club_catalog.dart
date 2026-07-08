import 'south_america_club_entry.dart';

class PeruClubCatalog {
  const PeruClubCatalog._();

  static const String countryId = 'PE';
  static const String countryName = 'Peru';
  static const String countryFolder = 'peru';
  static const String leagueId = 'PER-A';
  static const String divisionFolder = 'league_a';

  static const int simonBolivarSlots = 1;

  static List<SouthAmericaClubEntry> all() => List.unmodifiable(_all);

  static List<SouthAmericaClubEntry> simonBolivarQualified() {
    return List.unmodifiable(_all.take(simonBolivarSlots));
  }

  static const List<SouthAmericaClubEntry> _all = [
    SouthAmericaClubEntry(
      id: 'PER01',
      name: 'Sport Alianza',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'sport_alianza',
      basePower: 7.3,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
  ];
}
