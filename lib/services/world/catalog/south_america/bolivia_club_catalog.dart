import 'south_america_club_entry.dart';

class BoliviaClubCatalog {
  const BoliviaClubCatalog._();

  static const String countryId = 'BO';
  static const String countryName = 'Bolívia';
  static const String countryFolder = 'bolivia';
  static const String leagueId = 'BOL-A';
  static const String divisionFolder = 'league_a';

  static const int simonBolivarSlots = 2;

  static List<SouthAmericaClubEntry> all() => List.unmodifiable(_all);

  static List<SouthAmericaClubEntry> simonBolivarQualified() {
    return List.unmodifiable(_all.take(simonBolivarSlots));
  }

  static const List<SouthAmericaClubEntry> _all = [
    SouthAmericaClubEntry(
      id: 'BOL01',
      name: 'Eterna Primavera',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'eterna_primavera',
      basePower: 7.0,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
    SouthAmericaClubEntry(
      id: 'BOL02',
      name: 'Império Incaico',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'imperio_incaico',
      basePower: 7.0,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 8,
    ),
  ];
}
