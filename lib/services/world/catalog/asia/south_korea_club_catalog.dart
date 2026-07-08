import 'asia_club_entry.dart';

class SouthKoreaClubCatalog {
  const SouthKoreaClubCatalog._();

  static List<AsiaClubEntry> all() {
    return const [
      AsiaClubEntry(
        id: 'KOR01',
        name: 'Goryeo',
        countryId: 'KOR',
        countryName: 'Coreia do Sul',
        countryFolder: 'south_korea',
        leagueId: 'kor_1',
        divisionFolder: 'first_division',
        badgeFileName: 'goryeo',
        basePower: 7.9,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 8,
      ),
    ];
  }
}
