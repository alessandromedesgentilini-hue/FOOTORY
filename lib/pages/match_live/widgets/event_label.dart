import 'package:flutter/material.dart';

import 'package:footory26/models/match_live_event.dart';
import 'package:footory26/pages/match_live/widgets/event_visuals.dart';

class EventLabel extends StatelessWidget {
  final MatchLiveEvent event;

  const EventLabel({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final label = _label(event.type);

    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = EventVisuals.fromType(event.type);

    return Text(
      label,
      style: TextStyle(
        color: colors.accent,
        fontSize: 12.5,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.05,
      ),
    );
  }

  String _label(MatchLiveEventType type) {
    switch (type) {
      case MatchLiveEventType.intro:
        return '▶ BOLA ROLANDO';

      case MatchLiveEventType.pressure:
        return '🔥 PRESSÃO';

      case MatchLiveEventType.tactical:
        return '♟ TÁTICA';

      case MatchLiveEventType.chance:
        return '⚡ CHANCE';

      case MatchLiveEventType.bigChance:
        return '🚨 GRANDE CHANCE';

      case MatchLiveEventType.save:
        return '🧤 DEFESA';

      case MatchLiveEventType.counterAttack:
        return '💨 CONTRA-ATAQUE';

      case MatchLiveEventType.goal:
        return '⚽ GOL';

      case MatchLiveEventType.substitution:
        return '🔄 SUBSTITUIÇÃO';

      case MatchLiveEventType.yellowCard:
        return '🟨 CARTÃO';

      case MatchLiveEventType.medicalAttention:
        return '🩺 ATENDIMENTO';

      case MatchLiveEventType.crowd:
        return '📣 TORCIDA';

      case MatchLiveEventType.halfTime:
        return '⏸ INTERVALO';

      case MatchLiveEventType.finalWhistle:
        return '🏁 FIM DE JOGO';
    }
  }
}
