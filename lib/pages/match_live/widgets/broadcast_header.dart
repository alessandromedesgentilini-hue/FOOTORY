import 'package:flutter/material.dart';

import 'package:footory26/pages/match_live/widgets/club_side.dart';
import 'package:footory26/pages/match_live/widgets/live_badge.dart';

class BroadcastHeader extends StatelessWidget {
  final int minute;
  final bool finished;

  final String homeClubName;
  final String awayClubName;

  final int homeGoals;
  final int awayGoals;

  final bool pulse;

  const BroadcastHeader({
    super.key,
    required this.minute,
    required this.finished,
    required this.homeClubName,
    required this.awayClubName,
    required this.homeGoals,
    required this.awayGoals,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = finished ? 'FIM DE JOGO' : "$minute'";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      padding: EdgeInsets.fromLTRB(
        14,
        pulse ? 18 : 16,
        14,
        pulse ? 18 : 16,
      ),
      decoration: BoxDecoration(
        color: pulse ? const Color(0xFF123D25) : const Color(0xFF0D2117),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: pulse
              ? const Color(0xFF2ECC71)
              : const Color(0xFF2ECC71).withOpacity(0.28),
          width: pulse ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: pulse
                ? const Color(0xFF2ECC71).withOpacity(0.22)
                : Colors.black.withOpacity(0.22),
            blurRadius: pulse ? 22 : 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: LiveBadge(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF06110B),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF2ECC71).withOpacity(0.48),
                  ),
                ),
                child: Text(
                  timeLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: finished ? Colors.white : const Color(0xFF2ECC71),
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ClubSide(
                  name: homeClubName,
                  alignRight: false,
                ),
              ),
              AnimatedScale(
                duration: const Duration(milliseconds: 260),
                scale: pulse ? 1.12 : 1.0,
                curve: Curves.easeOutBack,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06110B),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF2ECC71).withOpacity(
                        pulse ? 0.9 : 0.38,
                      ),
                    ),
                  ),
                  child: Text(
                    '$homeGoals  x  $awayGoals',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ClubSide(
                  name: awayClubName,
                  alignRight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
