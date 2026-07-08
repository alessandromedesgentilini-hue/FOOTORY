import 'package:flutter/material.dart';

import 'package:footory26/models/match_live_event.dart';
import 'package:footory26/pages/match_live/widgets/event_visuals.dart';

class MinuteBadge extends StatelessWidget {
  final MatchLiveEvent event;

  const MinuteBadge({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final isGoal = event.type == MatchLiveEventType.goal;
    final colors = EventVisuals.fromType(event.type);

    return Container(
      width: 46,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isGoal ? const Color(0xFF2ECC71) : colors.badge,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${event.minute}’',
        style: TextStyle(
          color: isGoal ? const Color(0xFF06110B) : Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
