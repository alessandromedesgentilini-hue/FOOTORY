import 'package:flutter/material.dart';

import 'package:footory26/models/match_live_event.dart';
import 'package:footory26/pages/match_live/widgets/event_label.dart';
import 'package:footory26/pages/match_live/widgets/event_visuals.dart';
import 'package:footory26/pages/match_live/widgets/minute_badge.dart';
import 'package:footory26/pages/match_live/widgets/player_face.dart';

class MatchEventCard extends StatelessWidget {
  final MatchLiveEvent event;

  const MatchEventCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final isGoal = event.type == MatchLiveEventType.goal;
    final isFinal = event.type == MatchLiveEventType.finalWhistle;
    final isHalfTime = event.type == MatchLiveEventType.halfTime;
    final isBigChance = event.type == MatchLiveEventType.bigChance;
    final isSave = event.type == MatchLiveEventType.save;

    final colors = EventVisuals.fromType(event.type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(isGoal ? 16 : 14),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(isGoal ? 20 : 18),
        border: Border.all(
          color: colors.border.withOpacity(isGoal ? 0.95 : 0.52),
          width: isGoal ? 1.6 : 1,
        ),
        boxShadow: isGoal || isBigChance
            ? [
                BoxShadow(
                  color: colors.border.withOpacity(isGoal ? 0.18 : 0.1),
                  blurRadius: isGoal ? 15 : 10,
                  spreadRadius: isGoal ? 1 : 0,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MinuteBadge(event: event),
          const SizedBox(width: 12),
          if (isGoal && event.playerFaceAsset != null) ...[
            PlayerFace(assetPath: event.playerFaceAsset!),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventLabel(event: event),
                const SizedBox(height: 5),
                Text(
                  event.text,
                  style: TextStyle(
                    color: isGoal ? Colors.white : const Color(0xFFEAF7EF),
                    fontSize: isGoal ? 16 : 14.5,
                    height: 1.35,
                    fontWeight: isGoal || isBigChance
                        ? FontWeight.w800
                        : FontWeight.w600,
                  ),
                ),
                if (isGoal && event.playerName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    event.playerName!,
                    style: const TextStyle(
                      color: Color(0xFFB7F7CE),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
                if (isFinal || isHalfTime || isSave) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: 42,
                    height: 3,
                    decoration: BoxDecoration(
                      color: colors.border.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
