class MatchPreviewPlayer {
  final String name;
  final String position;
  final int overall;
  final String? faceAsset;

  const MatchPreviewPlayer({
    required this.name,
    required this.position,
    required this.overall,
    this.faceAsset,
  });
}
