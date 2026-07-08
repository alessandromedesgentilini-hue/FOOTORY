import 'south_america_club_entry.dart';

class ParaguayClubCatalog {
  const ParaguayClubCatalog._();

  static const String countryId = 'PY';
  static const String countryName = 'Paraguai';
  static const String countryFolder = 'paraguay';
  static const String leagueId = 'PAR-A';
  static const String divisionFolder = 'league_a';

  static const int simonBolivarSlots = 3;

  static List<SouthAmericaClubEntry> all() => List.unmodifiable(_all);

  static List<SouthAmericaClubEntry> simonBolivarQualified() {
    return List.unmodifiable(_all.take(simonBolivarSlots));
  }

  static const List<SouthAmericaClubEntry> _all = [
    SouthAmericaClubEntry(
      id: 'PAR01',
      name: 'Chacho Boreal',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'chacho_boreal',
      basePower: 7.4,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 8,
    ),
    SouthAmericaClubEntry(
      id: 'PAR02',
      name: 'Club Pueblo',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'club_pueblo',
      basePower: 7.4,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 8,
    ),
    SouthAmericaClubEntry(
      id: 'PAR03',
      name: 'Gumalero',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'gumalero',
      basePower: 7.3,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 8,
    ),
  ];
}
