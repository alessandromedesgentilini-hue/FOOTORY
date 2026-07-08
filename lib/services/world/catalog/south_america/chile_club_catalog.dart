import 'south_america_club_entry.dart';

class ChileClubCatalog {
  const ChileClubCatalog._();

  static const String countryId = 'CL';
  static const String countryName = 'Chile';
  static const String countryFolder = 'chile';
  static const String leagueId = 'CHI-A';
  static const String divisionFolder = 'league_a';

  static const int simonBolivarSlots = 3;

  static List<SouthAmericaClubEntry> all() => List.unmodifiable(_all);

  static List<SouthAmericaClubEntry> simonBolivarQualified() {
    return List.unmodifiable(_all.take(simonBolivarSlots));
  }

  static const List<SouthAmericaClubEntry> _all = [
    SouthAmericaClubEntry(
      id: 'CHI01',
      name: 'Cruzados',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'cruzados',
      basePower: 7.2,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
    SouthAmericaClubEntry(
      id: 'CHI02',
      name: 'Real San Felipe',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'real_san_felipe',
      basePower: 7.0,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
    SouthAmericaClubEntry(
      id: 'CHI03',
      name: 'Sábio Mapuche',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'sabio_mapuche',
      basePower: 7.0,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
  ];
}
