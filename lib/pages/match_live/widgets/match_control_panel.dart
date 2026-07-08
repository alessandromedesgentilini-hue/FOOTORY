import 'package:flutter/material.dart';

import 'package:footory26/pages/match_live/models/live_stats.dart';
import 'package:footory26/pages/match_live/widgets/momentum_bar.dart';
import 'package:footory26/pages/match_live/widgets/stat_pill.dart';
import 'package:footory26/pages/match_live/widgets/timeline_bar.dart';

class MatchControlPanel extends StatelessWidget {
  final int minute;
  final LiveStats stats;

  final String homeClubName;
  final String awayClubName;

  const MatchControlPanel({
    super.key,
    required this.minute,
    required this.stats,
    required this.homeClubName,
    required this.awayClubName,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (minute / 90).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1810),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF244B35).withOpacity(0.72),
        ),
      ),
      child: Column(
        children: [
          TimelineBar(progress: progress),
          const SizedBox(height: 13),
          MomentumBar(
            homeClubName: homeClubName,
            awayClubName: awayClubName,
            homeMomentum: stats.homeMomentum,
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: StatPill(
                  label: 'POSSE',
                  value: '${stats.homePossession}% - ${stats.awayPossession}%',
                  icon: Icons.pie_chart_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatPill(
                  label: 'FINALIZAÇÕES',
                  value: '${stats.homeShots} - ${stats.awayShots}',
                  icon: Icons.sports_soccer_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatPill(
                  label: 'CHANCES',
                  value: '${stats.homeChances} - ${stats.awayChances}',
                  icon: Icons.flash_on_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
