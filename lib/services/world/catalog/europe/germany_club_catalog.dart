import 'europe_club_entry.dart';

class GermanyClubCatalog {
  const GermanyClubCatalog._();

  static List<EuropeClubEntry> all() {
    return const [
      EuropeClubEntry(
        id: 'GER01',
        name: 'Gigant Bayerns',
        countryId: 'GER',
        countryName: 'Alemanha',
        countryFolder: 'germany',
        leagueId: 'ger_1',
        divisionFolder: 'first_division',
        badgeFileName: 'gigant_bayerns',
        basePower: 9.0,
        cpuCoachLevel: 10,
        cpuStadiumLevel: 9,
      ),
      EuropeClubEntry(
        id: 'GER02',
        name: 'Preuben',
        countryId: 'GER',
        countryName: 'Alemanha',
        countryFolder: 'germany',
        leagueId: 'ger_1',
        divisionFolder: 'first_division',
        badgeFileName: 'preuben',
        basePower: 8.5,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 8,
      ),
    ];
  }
}
