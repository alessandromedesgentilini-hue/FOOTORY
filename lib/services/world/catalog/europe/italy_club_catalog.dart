import 'europe_club_entry.dart';

class ItalyClubCatalog {
  const ItalyClubCatalog._();

  static List<EuropeClubEntry> all() {
    return const [
      EuropeClubEntry(
        id: 'ITA01',
        name: 'La Vecchia Signora',
        countryId: 'ITA',
        countryName: 'Itália',
        countryFolder: 'italy',
        leagueId: 'ita_1',
        divisionFolder: 'first_division',
        badgeFileName: 'la_vecchia_signora',
        basePower: 8.6,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 9,
      ),
      EuropeClubEntry(
        id: 'ITA02',
        name: 'Milano',
        countryId: 'ITA',
        countryName: 'Itália',
        countryFolder: 'italy',
        leagueId: 'ita_1',
        divisionFolder: 'first_division',
        badgeFileName: 'milano',
        basePower: 8.5,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 9,
      ),
      EuropeClubEntry(
        id: 'ITA03',
        name: 'Nerazurri',
        countryId: 'ITA',
        countryName: 'Itália',
        countryFolder: 'italy',
        leagueId: 'ita_1',
        divisionFolder: 'first_division',
        badgeFileName: 'nerazurri',
        basePower: 8.7,
        cpuCoachLevel: 9,
        cpuStadiumLevel: 9,
      ),
    ];
  }
}
