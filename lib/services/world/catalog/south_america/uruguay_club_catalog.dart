import 'south_america_club_entry.dart';

class UruguayClubCatalog {
  const UruguayClubCatalog._();

  static const String countryId = 'UY';
  static const String countryName = 'Uruguai';
  static const String countryFolder = 'uruguay';
  static const String leagueId = 'URU-A';
  static const String divisionFolder = 'league_a';

  static const int simonBolivarSlots = 4;

  static List<SouthAmericaClubEntry> all() => List.unmodifiable(_all);

  static List<SouthAmericaClubEntry> simonBolivarQualified() {
    return List.unmodifiable(_all.take(simonBolivarSlots));
  }

  static const List<SouthAmericaClubEntry> _all = [
    SouthAmericaClubEntry(
      id: 'URU01',
      name: 'Los Carboneros',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'los_carboneros',
      basePower: 7.6,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
    SouthAmericaClubEntry(
      id: 'URU02',
      name: 'Rey de Copas',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'rey_de_copas',
      basePower: 7.6,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
    SouthAmericaClubEntry(
      id: 'URU03',
      name: 'Los Violetas',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'los_violetas',
      basePower: 7.1,
      cpuCoachLevel: 5,
      cpuStadiumLevel: 5,
    ),
    SouthAmericaClubEntry(
      id: 'URU04',
      name: 'Rio Búlgaro',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'rio_bulgaro',
      basePower: 7.0,
      cpuCoachLevel: 5,
      cpuStadiumLevel: 4,
    ),
  ];
}
