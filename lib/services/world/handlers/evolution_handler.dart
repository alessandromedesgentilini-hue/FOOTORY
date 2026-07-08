part of '../game_state.dart';

extension EvolutionHandler on GameState {
  void _maybeApplyQuarterEvolution() {
    final month = _currentDate.month;
    const validMonths = <int>{3, 6, 10};

    if (!validMonths.contains(month)) return;
    if (_processedEvolutionMonths.contains(month)) return;

    _processedEvolutionMonths.add(month);
    _applyQuarterEvolution();
  }

  void _applyQuarterEvolution() {
    final squad = _proSquads[userClubId];
    if (squad == null || squad.isEmpty) return;

    final highlights = <String>[];
    final updatedSquad = <Player>[];

    for (final player in squad) {
      final result = PlayerEvolutionService.applyEvolution(
        player: player,
        ctLevel: userCtLevel,
      );

      final evolvedPlayer = PlayerEvolutionService.applyDeltaToPlayer(
        player: player,
        delta: result.delta,
      );

      updatedSquad.add(evolvedPlayer);

      if (result.delta != 0) {
        final signal = result.delta > 0 ? '+' : '';
        highlights.add(
          '${player.nome}: ${result.message} ($signal${result.delta})',
        );
      }
    }

    _proSquads[userClubId] = updatedSquad;
    _recalculateMonthlyWageForClub(userClubId);

    _newsFeed.insert(
      0,
      'CT — Relatório de treinamentos (${_monthLabel(_currentDate.month)}).',
    );

    if (highlights.isEmpty) {
      _newsFeed.insert(
        0,
        'CT — O elenco manteve estabilidade no período de treinamentos.',
      );
      return;
    }

    for (final line in highlights.take(4).toList().reversed) {
      _newsFeed.insert(0, line);
    }
  }

  String _monthLabel(int month) {
    switch (month) {
      case 1:
        return 'Janeiro';
      case 2:
        return 'Fevereiro';
      case 3:
        return 'Março';
      case 4:
        return 'Abril';
      case 5:
        return 'Maio';
      case 6:
        return 'Junho';
      case 7:
        return 'Julho';
      case 8:
        return 'Agosto';
      case 9:
        return 'Setembro';
      case 10:
        return 'Outubro';
      case 11:
        return 'Novembro';
      case 12:
        return 'Dezembro';
      default:
        return 'Mês';
    }
  }
}
