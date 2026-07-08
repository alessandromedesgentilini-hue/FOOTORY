import 'europe_club_entry.dart';

class EnglandClubCatalog {
  const EnglandClubCatalog._();

  static List<EuropeClubEntry> all() {
    return const [
      EuropeClubEntry(
        id: 'ENG01',
        name: 'West Gorton',
        countryId: 'ENG',
        countryName: 'Inglaterra',
        countryFolder: 'england',
        leagueId: 'eng_1',
        divisionFolder: 'first_division',
        badgeFileName: 'west_gorton',
        basePower: 8.9,
        cpuCoachLevel: 10,
        cpuStadiumLevel: 9,
      ),
      EuropeClubEntry(
        id: 'ENG02',
        name: 'Liverpul',
        countryId: 'ENG',
        countryName: 'Inglaterra',
        countryFolder: 'england',
        leagueId: 'eng_1',
        divisionFolder: 'first_division',
        badgeFileName: 'liverpul',
        basePower: 8.8,
        cpuCoachLevel: 9,
        cpuStadiumLevel: 9,
      ),
      EuropeClubEntry(
        id: 'ENG03',
        name: 'Kenington',
        countryId: 'ENG',
        countryName: 'Inglaterra',
        countryFolder: 'england',
        leagueId: 'eng_1',
        divisionFolder: 'first_division',
        badgeFileName: 'kenington',
        basePower: 8.6,
        cpuCoachLevel: 9,
        cpuStadiumLevel: 8,
      ),
      EuropeClubEntry(
        id: 'ENG04',
        name: 'Newton Heath',
        countryId: 'ENG',
        countryName: 'Inglaterra',
        countryFolder: 'england',
        leagueId: 'eng_1',
        divisionFolder: 'first_division',
        badgeFileName: 'newton_heath',
        basePower: 8.5,
        cpuCoachLevel: 9,
        cpuStadiumLevel: 9,
      ),
    ];
  }
}
