import 'europe_club_entry.dart';

class SpainClubCatalog {
  const SpainClubCatalog._();

  static List<EuropeClubEntry> all() {
    return const [
      EuropeClubEntry(
        id: 'ESP01',
        name: 'Barcinona',
        countryId: 'ESP',
        countryName: 'Espanha',
        countryFolder: 'spain',
        leagueId: 'esp_1',
        divisionFolder: 'first_division',
        badgeFileName: 'barcinona',
        basePower: 9.0,
        cpuCoachLevel: 9,
        cpuStadiumLevel: 10,
      ),
      EuropeClubEntry(
        id: 'ESP02',
        name: 'Canillejas de las Rosas',
        countryId: 'ESP',
        countryName: 'Espanha',
        countryFolder: 'spain',
        leagueId: 'esp_1',
        divisionFolder: 'first_division',
        badgeFileName: 'canillejas_de_las_rosas',
        basePower: 8.7,
        cpuCoachLevel: 9,
        cpuStadiumLevel: 9,
      ),
      EuropeClubEntry(
        id: 'ESP03',
        name: 'El Madrid',
        countryId: 'ESP',
        countryName: 'Espanha',
        countryFolder: 'spain',
        leagueId: 'esp_1',
        divisionFolder: 'first_division',
        badgeFileName: 'el_madrid',
        basePower: 9.0,
        cpuCoachLevel: 9,
        cpuStadiumLevel: 10,
      ),
    ];
  }
}
