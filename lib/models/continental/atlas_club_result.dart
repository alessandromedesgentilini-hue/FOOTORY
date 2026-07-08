import 'atlas_club_fixture.dart';

class AtlasClubResult {
  final int seasonYear;
  final String championClubId;
  final String runnerUpClubId;
  final List<AtlasClubFixture> fixtures;

  const AtlasClubResult({
    required this.seasonYear,
    required this.championClubId,
    required this.runnerUpClubId,
    required this.fixtures,
  });

  AtlasClubFixture get finalFixture {
    return fixtures.firstWhere(
      (fixture) => fixture.stage == 'FINAL',
      orElse: () => throw StateError('Final da ATLAS Club não encontrada.'),
    );
  }
}
