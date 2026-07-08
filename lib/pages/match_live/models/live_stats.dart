import 'package:footory26/models/match_live_event.dart';

class LiveStats {
  final int homePossession;
  final int awayPossession;

  final int homeShots;
  final int awayShots;

  final int homeChances;
  final int awayChances;

  final double homeMomentum;

  const LiveStats({
    required this.homePossession,
    required this.awayPossession,
    required this.homeShots,
    required this.awayShots,
    required this.homeChances,
    required this.awayChances,
    required this.homeMomentum,
  });

  factory LiveStats.fromEvents({
    required List<MatchLiveEvent> events,
    required int homeGoals,
    required int awayGoals,
  }) {
    var homeActivity = 1;
    var awayActivity = 1;

    var homeShots = homeGoals;
    var awayShots = awayGoals;

    var homeChances = homeGoals;
    var awayChances = awayGoals;

    for (final event in events) {
      final side = _guessEventSide(event);
      final weight = _eventWeight(event.type);

      if (side == EventSide.home) {
        homeActivity += weight;

        if (_isShotEvent(event.type)) homeShots++;
        if (_isChanceEvent(event.type)) homeChances++;
      } else if (side == EventSide.away) {
        awayActivity += weight;

        if (_isShotEvent(event.type)) awayShots++;
        if (_isChanceEvent(event.type)) awayChances++;
      } else {
        homeActivity += 1;
        awayActivity += 1;
      }
    }

    homeShots = homeShots.clamp(homeGoals, 99);
    awayShots = awayShots.clamp(awayGoals, 99);

    homeChances = homeChances.clamp(homeGoals, 99);
    awayChances = awayChances.clamp(awayGoals, 99);

    final totalActivity = homeActivity + awayActivity;

    final homePossession = ((homeActivity / totalActivity) * 100).round();

    final awayPossession = 100 - homePossession;

    final recent = events.take(5).toList();

    var recentHome = 1;
    var recentAway = 1;

    for (final event in recent) {
      final side = _guessEventSide(event);
      final weight = _eventWeight(event.type);

      if (side == EventSide.home) {
        recentHome += weight;
      } else if (side == EventSide.away) {
        recentAway += weight;
      } else {
        recentHome += 1;
        recentAway += 1;
      }
    }

    final momentum = recentHome / (recentHome + recentAway);

    return LiveStats(
      homePossession: homePossession,
      awayPossession: awayPossession,
      homeShots: homeShots,
      awayShots: awayShots,
      homeChances: homeChances,
      awayChances: awayChances,
      homeMomentum: momentum,
    );
  }

  static bool _isShotEvent(MatchLiveEventType type) {
    return type == MatchLiveEventType.goal ||
        type == MatchLiveEventType.chance ||
        type == MatchLiveEventType.bigChance ||
        type == MatchLiveEventType.save;
  }

  static bool _isChanceEvent(MatchLiveEventType type) {
    return type == MatchLiveEventType.goal ||
        type == MatchLiveEventType.chance ||
        type == MatchLiveEventType.bigChance;
  }

  static int _eventWeight(MatchLiveEventType type) {
    switch (type) {
      case MatchLiveEventType.goal:
        return 5;

      case MatchLiveEventType.bigChance:
        return 4;

      case MatchLiveEventType.chance:
      case MatchLiveEventType.save:
        return 3;

      case MatchLiveEventType.pressure:
      case MatchLiveEventType.counterAttack:
        return 2;

      case MatchLiveEventType.tactical:
      case MatchLiveEventType.crowd:
      case MatchLiveEventType.substitution:
      case MatchLiveEventType.yellowCard:
      case MatchLiveEventType.medicalAttention:
        return 1;

      case MatchLiveEventType.intro:
      case MatchLiveEventType.halfTime:
      case MatchLiveEventType.finalWhistle:
        return 0;
    }
  }

  static EventSide _guessEventSide(MatchLiveEvent event) {
    if (event.isHomeTeamEvent) return EventSide.home;

    final text = event.text.toLowerCase();

    final awayWords = [
      'visitante',
      'fora',
      'time de fora',
      'lado visitante',
      'silencia',
    ];

    for (final word in awayWords) {
      if (text.contains(word)) {
        return EventSide.away;
      }
    }

    return EventSide.away;
  }
}

enum EventSide {
  home,
  away,
  neutral,
}
