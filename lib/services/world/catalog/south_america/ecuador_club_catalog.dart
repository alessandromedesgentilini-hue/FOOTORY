import 'south_america_club_entry.dart';

class EcuadorClubCatalog {
  const EcuadorClubCatalog._();

  static const String countryId = 'EC';
  static const String countryName = 'Equador';
  static const String countryFolder = 'ecuador';
  static const String leagueId = 'ECU-A';
  static const String divisionFolder = 'league_a';

  static const int simonBolivarSlots = 3;

  static List<SouthAmericaClubEntry> all() => List.unmodifiable(_all);

  static List<SouthAmericaClubEntry> simonBolivarQualified() {
    return List.unmodifiable(_all.take(simonBolivarSlots));
  }

  static const List<SouthAmericaClubEntry> _all = [
    SouthAmericaClubEntry(
      id: 'ECU01',
      name: 'Ballet Azul',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'ballet_azul',
      basePower: 7.4,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
    SouthAmericaClubEntry(
      id: 'ECU02',
      name: 'Catalán Guayaquil',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'catalan_guayaquil',
      basePower: 7.4,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 8,
    ),
    SouthAmericaClubEntry(
      id: 'ECU03',
      name: 'Doctorcitos',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'doctorcitos',
      basePower: 7.3,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
  ];
}
