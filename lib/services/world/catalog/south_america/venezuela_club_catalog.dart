import 'south_america_club_entry.dart';

class VenezuelaClubCatalog {
  const VenezuelaClubCatalog._();

  static const String countryId = 'VE';
  static const String countryName = 'Venezuela';
  static const String countryFolder = 'venezuela';
  static const String leagueId = 'VEN-A';
  static const String divisionFolder = 'league_a';

  static const int simonBolivarSlots = 2;

  static List<SouthAmericaClubEntry> all() => List.unmodifiable(_all);

  static List<SouthAmericaClubEntry> simonBolivarQualified() {
    return List.unmodifiable(_all.take(simonBolivarSlots));
  }

  static const List<SouthAmericaClubEntry> _all = [
    SouthAmericaClubEntry(
      id: 'VEN01',
      name: 'Unión Táchira',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'union_tachira',
      basePower: 7.2,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
    SouthAmericaClubEntry(
      id: 'VEN02',
      name: 'Rio Guaire',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'rio_guaire',
      basePower: 7.0,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
  ];
}
