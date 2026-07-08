import 'europe_club_entry.dart';

class FranceClubCatalog {
  const FranceClubCatalog._();

  static List<EuropeClubEntry> all() {
    return const [
      EuropeClubEntry(
        id: 'FRA01',
        name: 'Lutéce',
        countryId: 'FRA',
        countryName: 'França',
        countryFolder: 'france',
        leagueId: 'fra_1',
        divisionFolder: 'first_division',
        badgeFileName: 'lutece',
        basePower: 8.9,
        cpuCoachLevel: 10,
        cpuStadiumLevel: 9,
      ),
    ];
  }
}
