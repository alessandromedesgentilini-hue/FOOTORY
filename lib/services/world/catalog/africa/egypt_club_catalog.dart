import 'africa_club_entry.dart';

class EgyptClubCatalog {
  const EgyptClubCatalog._();

  static List<AfricaClubEntry> all() {
    return const [
      AfricaClubEntry(
        id: 'EGY01',
        name: 'Mawtini',
        countryId: 'EGY',
        countryName: 'Egito',
        countryFolder: 'egypt',
        leagueId: 'egy_1',
        divisionFolder: 'first_division',
        badgeFileName: 'mawtini',
        basePower: 8.0,
        cpuCoachLevel: 9,
        cpuStadiumLevel: 8,
      ),
    ];
  }
}
