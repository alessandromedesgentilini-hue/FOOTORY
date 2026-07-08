import 'south_america_club_entry.dart';

class ArgentinaClubCatalog {
  const ArgentinaClubCatalog._();

  static const String countryId = 'AR';
  static const String countryName = 'Argentina';
  static const String countryFolder = 'argentina';
  static const String leagueId = 'ARG-A';
  static const String divisionFolder = 'league_a';

  static const int simonBolivarSlots = 6;

  static List<SouthAmericaClubEntry> all() => List.unmodifiable(_all);

  static List<SouthAmericaClubEntry> simonBolivarQualified() {
    return List.unmodifiable(_all.take(simonBolivarSlots));
  }

  static const List<SouthAmericaClubEntry> _all = [
    SouthAmericaClubEntry(
      id: 'ARG01',
      name: 'La Boca',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'la_boca',
      basePower: 7.9,
      cpuCoachLevel: 8,
      cpuStadiumLevel: 9,
    ),
    SouthAmericaClubEntry(
      id: 'ARG02',
      name: 'Rio de la Plata',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'rio_de_la_plata',
      basePower: 7.9,
      cpuCoachLevel: 8,
      cpuStadiumLevel: 10,
    ),
    SouthAmericaClubEntry(
      id: 'ARG03',
      name: 'La Academia',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'la_academia',
      basePower: 7.6,
      cpuCoachLevel: 8,
      cpuStadiumLevel: 10,
    ),
    SouthAmericaClubEntry(
      id: 'ARG04',
      name: 'Pincharratas',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'pincharratas',
      basePower: 7.4,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 8,
    ),
    SouthAmericaClubEntry(
      id: 'ARG05',
      name: 'Los Forzosos de Almagro',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'los_forzosos_de_almagro',
      basePower: 7.2,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 8,
    ),
    SouthAmericaClubEntry(
      id: 'ARG06',
      name: 'Atlanta Buenos Aires',
      countryId: countryId,
      countryName: countryName,
      countryFolder: countryFolder,
      leagueId: leagueId,
      divisionFolder: divisionFolder,
      badgeFileName: 'atlanta_buenos_aires',
      basePower: 7.1,
      cpuCoachLevel: 7,
      cpuStadiumLevel: 8,
    ),
  ];
}
