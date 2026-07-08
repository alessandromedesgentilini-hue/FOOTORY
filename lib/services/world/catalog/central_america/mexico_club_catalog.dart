import 'central_america_club_entry.dart';

class MexicoClubCatalog {
  const MexicoClubCatalog._();

  static List<CentralAmericaClubEntry> all() {
    return const [
      CentralAmericaClubEntry(
        id: 'MEX01',
        name: 'Anahuac',
        countryId: 'MEX',
        countryName: 'México',
        countryFolder: 'mexico',
        leagueId: 'mex_1',
        divisionFolder: 'first_division',
        badgeFileName: 'anahuac',
        basePower: 8.1,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 8,
      ),
      CentralAmericaClubEntry(
        id: 'MEX02',
        name: 'Union',
        countryId: 'MEX',
        countryName: 'México',
        countryFolder: 'mexico',
        leagueId: 'mex_1',
        divisionFolder: 'first_division',
        badgeFileName: 'union',
        basePower: 8.0,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 8,
      ),
    ];
  }
}
