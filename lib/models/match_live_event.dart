enum MatchLiveEventType {
  intro,
  pressure,
  tactical,
  chance,
  bigChance,
  save,
  counterAttack,
  goal,
  substitution,
  yellowCard,
  medicalAttention,
  crowd,
  halfTime,
  finalWhistle,
}

class MatchLiveEvent {
  final int minute;
  final MatchLiveEventType type;

  final String text;

  final bool isHomeTeamEvent;

  final String? teamName;
  final String? opponentName;

  final String? playerId;
  final String? playerName;
  final String? playerFaceAsset;

  final int homeGoals;
  final int awayGoals;

  const MatchLiveEvent({
    required this.minute,
    required this.type,
    required this.text,
    required this.isHomeTeamEvent,
    this.teamName,
    this.opponentName,
    this.playerId,
    this.playerName,
    this.playerFaceAsset,
    required this.homeGoals,
    required this.awayGoals,
  });

  MatchLiveEvent copyWith({
    int? minute,
    MatchLiveEventType? type,
    String? text,
    bool? isHomeTeamEvent,
    String? teamName,
    String? opponentName,
    String? playerId,
    String? playerName,
    String? playerFaceAsset,
    int? homeGoals,
    int? awayGoals,
  }) {
    return MatchLiveEvent(
      minute: minute ?? this.minute,
      type: type ?? this.type,
      text: text ?? this.text,
      isHomeTeamEvent: isHomeTeamEvent ?? this.isHomeTeamEvent,
      teamName: teamName ?? this.teamName,
      opponentName: opponentName ?? this.opponentName,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      playerFaceAsset: playerFaceAsset ?? this.playerFaceAsset,
      homeGoals: homeGoals ?? this.homeGoals,
      awayGoals: awayGoals ?? this.awayGoals,
    );
  }

  bool get isGoal => type == MatchLiveEventType.goal;

  bool get isSubstitution => type == MatchLiveEventType.substitution;

  bool get isYellowCard => type == MatchLiveEventType.yellowCard;

  bool get isMedicalAttention => type == MatchLiveEventType.medicalAttention;

  bool get hasPlayer => playerName != null && playerName!.trim().isNotEmpty;
}
