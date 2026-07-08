class TransferOffer {
  final String playerId;
  final String playerName;
  final String fromClubId;
  final String toClubId;
  final int offeredValue;
  final int playerOvr;

  const TransferOffer({
    required this.playerId,
    required this.playerName,
    required this.fromClubId,
    required this.toClubId,
    required this.offeredValue,
    required this.playerOvr,
  });
}
