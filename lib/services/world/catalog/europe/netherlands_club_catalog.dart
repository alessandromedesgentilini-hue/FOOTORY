import 'europe_club_entry.dart';

class NetherlandsClubCatalog {
  const NetherlandsClubCatalog._();

  static List<EuropeClubEntry> all() {
    return const [
      EuropeClubEntry(
        id: 'NED01',
        name: 'Unie 1883',
        countryId: 'NED',
        countryName: 'Holanda',
        countryFolder: 'netherlands',
        leagueId: 'ned_1',
        divisionFolder: 'first_division',
        badgeFileName: 'unie_1883',
        basePower: 8.4,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 9,
      ),
    ];
  }
}
