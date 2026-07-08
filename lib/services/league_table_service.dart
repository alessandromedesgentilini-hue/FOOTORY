import 'package:footory26/models/fixture.dart';
import 'package:footory26/models/league_table.dart';

class LeagueTableService {
  const LeagueTableService();

  void applyMatchResult({
    required LeagueTable table,
    required String homeId,
    required String awayId,
    required int homeGoals,
    required int awayGoals,
  }) {
    table.ensureClub(homeId);
    table.ensureClub(awayId);

    final home = table.getEntry(homeId)!;
    final away = table.getEntry(awayId)!;

    home.played++;
    away.played++;

    home.goalsFor += homeGoals;
    home.goalsAgainst += awayGoals;

    away.goalsFor += awayGoals;
    away.goalsAgainst += homeGoals;

    if (homeGoals > awayGoals) {
      home.wins++;
      home.points += 3;
      away.losses++;
    } else if (homeGoals < awayGoals) {
      away.wins++;
      away.points += 3;
      home.losses++;
    } else {
      home.draws++;
      away.draws++;
      home.points += 1;
      away.points += 1;
    }
  }

  LeagueTable buildFromFixtures({
    required List<String> clubIds,
    required List<Fixture> fixtures,
  }) {
    final table = LeagueTable();
    table.initialize(clubIds);

    for (final fx in fixtures) {
      if (!fx.played) continue;

      applyMatchResult(
        table: table,
        homeId: fx.homeClubId,
        awayId: fx.awayClubId,
        homeGoals: fx.homeGoals!,
        awayGoals: fx.awayGoals!,
      );
    }

    return table;
  }
}
