class MatchFixture {
  final String homeId;
  final String awayId;
  final int round; // 1..N
  MatchFixture(
      {required this.homeId, required this.awayId, required this.round});
}

class RoundFixtures {
  final int round; // 1..N
  final List<MatchFixture> matches;
  RoundFixtures({required this.round, required this.matches});
}
