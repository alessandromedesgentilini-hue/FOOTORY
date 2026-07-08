import 'asia_club_entry.dart';

class JapanClubCatalog {
  const JapanClubCatalog._();

  static List<AsiaClubEntry> all() {
    return const [
      AsiaClubEntry(
        id: 'JPN01',
        name: 'Kinzoku',
        countryId: 'JPN',
        countryName: 'Japão',
        countryFolder: 'japan',
        leagueId: 'jpn_1',
        divisionFolder: 'first_division',
        badgeFileName: 'kinzoku',
        basePower: 7.9,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 8,
      ),
    ];
  }
}
