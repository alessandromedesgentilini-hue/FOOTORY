part of '../game_state.dart';

extension MarketNegotiationHandler on GameState {
  NegotiationPreview? previewNegotiationFromScout(ScoutTarget target) {
    final player = _marketService
        .playersByListType(target.listType)
        .where((p) => p.id == target.jogadorId)
        .cast<Player?>()
        .firstWhere(
          (p) => p != null,
          orElse: () => null,
        );

    if (player == null) return null;

    final marketValue = estimatePlayerValueForUserClub(player);
    final fullSalary = _salaryForUserClubMarketValue(marketValue);

    final baseCost = _costToSignScoutPlayer(
      player: player,
      listType: target.listType,
    );

    return const NegotiationService().buildPreview(
      listType: target.listType,
      playerName: player.nome,
      marketValue: marketValue,
      baseCost: baseCost,
      fullSalary: fullSalary,
      financeLevel: userFinanceiroLevel,
      userDivisionId: divisionId,
      userBalance: userBalance,
      playerOvr: player.ovrCheio,
    );
  }
}
