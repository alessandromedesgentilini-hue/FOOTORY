import 'atlas_champions_club_fixture.dart';
import 'atlas_champions_club_group.dart';
import 'atlas_champions_club_group_table.dart';

class AtlasChampionsClubResult {
  final int seasonYear;
  final String championClubId;
  final String runnerUpClubId;

  final List<AtlasChampionsClubGroup> groups;
  final List<AtlasChampionsClubGroupTable> tables;
  final List<AtlasChampionsClubFixture> fixtures;

  const AtlasChampionsClubResult({
    required this.seasonYear,
    required this.championClubId,
    required this.runnerUpClubId,
    required this.groups,
    required this.tables,
    required this.fixtures,
  });

  AtlasChampionsClubFixture get finalFixture {
    return fixtures.firstWhere(
      (fixture) => fixture.stage == 'FINAL',
      orElse: () {
        throw StateError('Final da ATLAS Champions Club não encontrada.');
      },
    );
  }
}
