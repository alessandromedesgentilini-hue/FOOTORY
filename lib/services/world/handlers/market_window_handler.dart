part of '../game_state.dart';

extension MarketWindowHandler on GameState {
  void _maybeRefreshJulyMarketAndScout({
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    final crossedIntoJuly = fromDate.month != 7 &&
        toDate.month == 7 &&
        fromDate.year == toDate.year;

    if (!crossedIntoJuly) return;

    _refreshMarketAndScoutForTransferWindow(
      month: 7,
      announce: true,
    );

    _processFutureArrivalsForCurrentWindow();

    _runCpuTransferWindow();
  }

  void _refreshMarketAndScoutForTransferWindow({
    required int month,
    required bool announce,
  }) {
    if (month != 1 && month != 7) return;

    _scoutTransfers.clear();
    _scoutLoans.clear();
    _scoutFrees.clear();

    _bootstrapMarketAndScout();

    if (!announce) return;

    final monthLabel = month == 7 ? 'julho' : 'janeiro';

    _insertNewsIfNew(
      'Mercado aberto — A janela de $monthLabel renovou as opções de transferência, empréstimo e agentes livres observados pelo scout.',
    );
  }
}
