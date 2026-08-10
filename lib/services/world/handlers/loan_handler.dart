part of '../game_state.dart';

extension LoanHandler on GameState {
  void processEndOfSeasonLoans() {
    final squad = _proSquads[userClubId];
    if (squad == null || squad.isEmpty) return;

    final loans = squad.where((p) => p.isLoan).toList();
    if (loans.isEmpty) return;

    for (final player in loans) {
      squad.removeWhere((p) => p.id == player.id);

      addToObservationList(
        player: player.copyWith(isLoan: false),
        clubDestinoId: player.loanOriginClubId ?? 'unknown',
      );

      _newsFeed.insert(
        0,
        _buildLoanReturnNews(player),
      );
    }

    notifyListeners();
  }

  String _buildLoanReturnNews(Player player) {
    final pos = _posLabelCompact(player.posDet);

    return 'MERCADO — ${player.nome} retornou ao clube de origem após o fim do empréstimo. '
        'O jogador atuava como $pos (OVR ${player.ovrCheio}) e agora passa a ser monitorado pelo clube.';
  }
}
