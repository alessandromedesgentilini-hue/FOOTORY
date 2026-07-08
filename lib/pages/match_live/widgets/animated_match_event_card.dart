import 'package:flutter/material.dart';

import 'package:footory26/models/match_live_event.dart';
import 'package:footory26/pages/match_live/widgets/match_event_card.dart';

class AnimatedMatchEventCard extends StatelessWidget {
  final MatchLiveEvent event;
  final int index;

  const AnimatedMatchEventCard({
    super.key,
    required this.event,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(
        milliseconds: index == 0 ? 330 : 180,
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: MatchEventCard(event: event),
    );
  }
}
