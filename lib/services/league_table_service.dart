// lib/services/league_table_service.dart
//
// LeagueTableService – manipula a tabela de classificação utilizando
// os modelos: LeagueTable e TableRowEntry (models/league_table.dart).

import '../models/league_table.dart';

class LeagueTableService {
  /// Cria uma tabela inicial a partir de uma lista de clubes:
  /// cada item deve ter pelo menos: { 'id': String, 'name': String }.
  LeagueTable createInitialTable({
    required String divisionId,
    required List<Map<String, dynamic>> clubs,
  }) {
    final rows = clubs
        .map(
          (c) => TableRowEntry(
            clubId: c['id'] as String,
            clubName: c['name'] as String,
          ),
        )
        .toList();

    return LeagueTable(
      divisionId: divisionId,
      initial: rows,
    );
  }

  /// Aplica o resultado de UM jogo na tabela.
  void applyMatch({
    required LeagueTable table,
    required String homeId,
    required String awayId,
    required int golsHome,
    required int golsAway,
  }) {
    // Usa a API do próprio LeagueTable (rowOf + TableRowEntry.applyMatch)
    final home = table.rowOf(homeId);
    final away = table.rowOf(awayId);

    home.applyMatch(
      isHome: true,
      goalsFor: golsHome,
      goalsAgainst: golsAway,
    );

    away.applyMatch(
      isHome: false,
      goalsFor: golsAway,
      goalsAgainst: golsHome,
    );
  }

  /// Aplica uma rodada inteira na tabela.
  ///
  /// [results] = lista de maps no formato:
  ///   { 'homeId': String, 'awayId': String, 'gh': int, 'ga': int }
  void applyRound({
    required LeagueTable table,
    required List<Map<String, dynamic>> results,
  }) {
    for (final r in results) {
      applyMatch(
        table: table,
        homeId: r['homeId'] as String,
        awayId: r['awayId'] as String,
        golsHome: r['gh'] as int,
        golsAway: r['ga'] as int,
      );
    }
  }

  /// Retorna os IDs promovidos / rebaixados com base na classificação.
  Map<String, List<String>> promotionsRelegations({
    required LeagueTable table,
    required int promote,
    required int relegate,
  }) {
    final sorted = table.rowsSorted;
    final top = sorted.take(promote).map((e) => e.clubId).toList();
    final bottom = sorted.reversed.take(relegate).map((e) => e.clubId).toList();

    return {
      'promote': top,
      'relegate': bottom,
    };
  }
}
