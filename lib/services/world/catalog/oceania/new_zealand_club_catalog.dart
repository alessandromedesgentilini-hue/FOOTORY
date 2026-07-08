import 'oceania_club_entry.dart';

class NewZealandClubCatalog {
  const NewZealandClubCatalog._();

  static List<OceaniaClubEntry> all() {
    return const [
      OceaniaClubEntry(
        id: 'NZL01',
        name: 'Aotearoa',
        countryId: 'NZL',
        countryName: 'Nova Zelândia',
        countryFolder: 'new_zealand',
        leagueId: 'nzl_1',
        divisionFolder: 'first_division',
        badgeFileName: 'aotearoa',
        basePower: 7.8,
        cpuCoachLevel: 8,
        cpuStadiumLevel: 8,
      ),
    ];
  }
}
