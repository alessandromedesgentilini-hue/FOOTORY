import 'south_america_club_entry.dart';

class ColombiaClubCatalog {
  const ColombiaClubCatalog._();

  static const String countryId = 'CO';
  static const String countryName = 'Colômbia';
  static const String countryFolder = 'colombia';
  static const String leagueId = 'COL-A';
  static const String divisionFolder = 'league_a';

  static const int simonBolivarSlots = 3;

  static List<SouthAmericaClubEntry> all() => List.unmodifiable(_all);

  static List<SouthAmericaClubEntry> simonBolivarQualified() {
    return List.unmodifiable(_all.take(simonBolivarSlots));
  }

  static const List<SouthAmericaClubEntry> _all = [
    SouthAmericaClubEntry(
      id: 'COL01',
      name: 'Los Diablos',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'los_diablos',
      basePower: 7.5,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
    SouthAmericaClubEntry(
      id: 'COL02',
      name: 'Municipal Medellín',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'municipal_medellin',
      basePower: 7.4,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
    SouthAmericaClubEntry(
      id: 'COL03',
      name: 'Unión Bogotana',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'union_bogotana',
      basePower: 7.3,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 7,
    ),
  ];
}
