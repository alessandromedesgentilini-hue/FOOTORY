import 'asia_club_entry.dart';

class SaudiArabiaClubCatalog {
  const SaudiArabiaClubCatalog._();

  static List<AsiaClubEntry> all() {
    return const [
      AsiaClubEntry(
        id: 'KSA01',
        name: 'Al Zaeem',
        countryId: 'KSA',
        countryName: 'Arábia Saudita',
        countryFolder: 'saudi_arabia',
        leagueId: 'ksa_1',
        divisionFolder: 'first_division',
        badgeFileName: 'al_zaeem',
        basePower: 8.2,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 8,
      ),
    ];
  }
}
