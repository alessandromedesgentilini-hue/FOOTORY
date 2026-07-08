import 'europe_club_entry.dart';

class TurkeyClubCatalog {
  const TurkeyClubCatalog._();

  static List<EuropeClubEntry> all() {
    return const [
      EuropeClubEntry(
        id: 'TUR01',
        name: 'Aslanlar',
        countryId: 'TUR',
        countryName: 'Turquia',
        countryFolder: 'turkey',
        leagueId: 'tur_1',
        divisionFolder: 'first_division',
        badgeFileName: 'aslanlar',
        basePower: 8.3,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 9,
      ),
    ];
  }
}
