import 'europe_club_entry.dart';

class PortugalClubCatalog {
  const PortugalClubCatalog._();

  static List<EuropeClubEntry> all() {
    return const [
      EuropeClubEntry(
        id: 'POR01',
        name: 'Portus Cale',
        countryId: 'POR',
        countryName: 'Portugal',
        countryFolder: 'portugal',
        leagueId: 'por_1',
        divisionFolder: 'first_division',
        badgeFileName: 'portus_cale',
        basePower: 8.4,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 9,
      ),
      EuropeClubEntry(
        id: 'POR02',
        name: 'Encarnados',
        countryId: 'POR',
        countryName: 'Portugal',
        countryFolder: 'portugal',
        leagueId: 'por_1',
        divisionFolder: 'first_division',
        badgeFileName: 'encarnados',
        basePower: 8.4,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 9,
      ),
    ];
  }
}
