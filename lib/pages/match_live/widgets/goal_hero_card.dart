import 'package:flutter/material.dart';

import 'package:footory26/models/match_live_event.dart';
import 'package:footory26/pages/match_live/widgets/player_face.dart';

class GoalHeroCard extends StatelessWidget {
  final MatchLiveEvent event;

  const GoalHeroCard({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1F6B43),
            Color(0xFF153F28),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF2ECC71).withOpacity(0.95),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2ECC71).withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          if (event.playerFaceAsset != null) ...[
            PlayerFace(
              assetPath: event.playerFaceAsset!,
              size: 62,
            ),
            const SizedBox(width: 12),
          ] else ...[
            Container(
              width: 62,
              height: 62,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF06110B),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                '⚽',
                style: TextStyle(fontSize: 30),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GOOOOL! ${event.minute}’',
                  style: const TextStyle(
                    color: Color(0xFFB7F7CE),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.playerName ?? 'A rede balançou!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${event.homeGoals} x ${event.awayGoals}',
                  style: const TextStyle(
                    color: Color(0xFFB7F7CE),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
