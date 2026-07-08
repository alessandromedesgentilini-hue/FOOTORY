import 'north_america_club_entry.dart';

class UsaClubCatalog {
  const UsaClubCatalog._();

  static List<NorthAmericaClubEntry> all() {
    return const [
      NorthAmericaClubEntry(
        id: 'USA01',
        name: 'Los Angeles',
        countryId: 'USA',
        countryName: 'Estados Unidos',
        countryFolder: 'usa',
        leagueId: 'usa_1',
        divisionFolder: 'first_division',
        badgeFileName: 'los_angeles',
        basePower: 8.0,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 8,
      ),
    ];
  }
}
