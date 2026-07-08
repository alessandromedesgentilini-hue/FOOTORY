import 'package:flutter/material.dart';

import 'package:footory26/models/match_live_event.dart';

class EventVisuals {
  final Color background;
  final Color border;
  final Color accent;
  final Color badge;

  const EventVisuals({
    required this.background,
    required this.border,
    required this.accent,
    required this.badge,
  });

  factory EventVisuals.fromType(MatchLiveEventType type) {
    switch (type) {
      case MatchLiveEventType.goal:
        return const EventVisuals(
          background: Color(0xFF123D25),
          border: Color(0xFF2ECC71),
          accent: Color(0xFF2ECC71),
          badge: Color(0xFF2ECC71),
        );

      case MatchLiveEventType.bigChance:
        return const EventVisuals(
          background: Color(0xFF182D1F),
          border: Color(0xFFB7F7CE),
          accent: Color(0xFFB7F7CE),
          badge: Color(0xFF244B35),
        );

      case MatchLiveEventType.chance:
      case MatchLiveEventType.counterAttack:
        return const EventVisuals(
          background: Color(0xFF102A1B),
          border: Color(0xFF2ECC71),
          accent: Color(0xFFB7F7CE),
          badge: Color(0xFF183824),
        );

      case MatchLiveEventType.save:
        return const EventVisuals(
          background: Color(0xFF101F1A),
          border: Color(0xFF5ECF98),
          accent: Color(0xFFB7F7CE),
          badge: Color(0xFF183824),
        );

      case MatchLiveEventType.pressure:
      case MatchLiveEventType.crowd:
        return const EventVisuals(
          background: Color(0xFF102417),
          border: Color(0xFF2ECC71),
          accent: Color(0xFF2ECC71),
          badge: Color(0xFF183824),
        );

      case MatchLiveEventType.substitution:
        return const EventVisuals(
          background: Color(0xFF101F2D),
          border: Color(0xFF4DA3FF),
          accent: Color(0xFF8FC7FF),
          badge: Color(0xFF18324A),
        );

      case MatchLiveEventType.yellowCard:
        return const EventVisuals(
          background: Color(0xFF2A240B),
          border: Color(0xFFFFD54F),
          accent: Color(0xFFFFE082),
          badge: Color(0xFF4A3F16),
        );

      case MatchLiveEventType.medicalAttention:
        return const EventVisuals(
          background: Color(0xFF2A1212),
          border: Color(0xFFFF6B6B),
          accent: Color(0xFFFFA0A0),
          badge: Color(0xFF4A1E1E),
        );

      case MatchLiveEventType.halfTime:
      case MatchLiveEventType.finalWhistle:
        return const EventVisuals(
          background: Color(0xFF102A1B),
          border: Color(0xFF244B35),
          accent: Color(0xFFB7F7CE),
          badge: Color(0xFF183824),
        );

      case MatchLiveEventType.intro:
      case MatchLiveEventType.tactical:
        return const EventVisuals(
          background: Color(0xFF0C1B13),
          border: Color(0xFF244B35),
          accent: Color(0xFFB7F7CE),
          badge: Color(0xFF183824),
        );
    }
  }
}
