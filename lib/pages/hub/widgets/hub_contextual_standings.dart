import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/models/league_table.dart';
import 'package:footory26/services/world/game_state.dart';

class HubContextualStandings extends StatelessWidget {
  final List<TableEntry> table;
  final String userClubId;
  final GameState gs;
  final VoidCallback onOpenStandings;

  const HubContextualStandings({
    super.key,
    required this.table,
    required this.userClubId,
    required this.gs,
    required this.onOpenStandings,
  });

  @override
  Widget build(BuildContext context) {
    final userIndex = table.indexWhere(
      (entry) => entry.clubId == userClubId,
    );

    if (userIndex < 0 || table.isEmpty) {
      return const SizedBox.shrink();
    }

    final contextualEntries = _buildContextualEntries(
      table: table,
      userIndex: userIndex,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenStandings,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _StandingsHeader(),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var index = 0;
                        index < contextualEntries.length;
                        index++) ...[
                      _StandingsRow(
                        position: contextualEntries[index].position,
                        clubName: gs.clubName(
                          contextualEntries[index].entry.clubId,
                        ),
                        points: contextualEntries[index].entry.points,
                        played: contextualEntries[index].entry.played,
                        isUser:
                            contextualEntries[index].entry.clubId == userClubId,
                      ),
                      if (index < contextualEntries.length - 1)
                        const SizedBox(height: 4),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_ContextualEntry> _buildContextualEntries({
    required List<TableEntry> table,
    required int userIndex,
  }) {
    final selectedIndexes = <int>[];

    if (table.length <= 3) {
      selectedIndexes.addAll(
        List<int>.generate(
          table.length,
          (index) => index,
        ),
      );
    } else if (userIndex == 0) {
      selectedIndexes.addAll(<int>[0, 1, 2]);
    } else if (userIndex == table.length - 1) {
      selectedIndexes.addAll(<int>[
        table.length - 3,
        table.length - 2,
        table.length - 1,
      ]);
    } else {
      selectedIndexes.addAll(<int>[
        userIndex - 1,
        userIndex,
        userIndex + 1,
      ]);
    }

    return selectedIndexes
        .map(
          (index) => _ContextualEntry(
            entry: table[index],
            position: index + 1,
          ),
        )
        .toList();
  }
}

class _StandingsHeader extends StatelessWidget {
  const _StandingsHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 31,
          height: 31,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.leaderboard_rounded,
            size: 18,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Classificação',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Sua posição e os adversários mais próximos',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.primarySoft.withOpacity(0.65),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
            size: 21,
          ),
        ),
      ],
    );
  }
}

class _StandingsRow extends StatelessWidget {
  final int position;
  final String clubName;
  final int points;
  final int played;
  final bool isUser;

  const _StandingsRow({
    required this.position,
    required this.clubName,
    required this.points,
    required this.played,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 7, 9, 7),
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.primarySoft.withOpacity(0.78)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUser
              ? AppColors.primary.withOpacity(0.22)
              : AppColors.border.withOpacity(0.75),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isUser ? AppColors.primary : AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(9),
              border: isUser
                  ? null
                  : Border.all(
                      color: AppColors.border,
                    ),
            ),
            child: Text(
              '$positionº',
              style: textTheme.labelSmall?.copyWith(
                color: isUser ? AppColors.white : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: isUser ? AppColors.primaryDark : AppColors.text,
                    fontWeight: isUser ? FontWeight.w900 : FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isUser ? 'Seu clube' : '$played jogos',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$points',
                style: textTheme.titleSmall?.copyWith(
                  color: isUser ? AppColors.primary : AppColors.text,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'pontos',
                style: textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContextualEntry {
  final TableEntry entry;
  final int position;

  const _ContextualEntry({
    required this.entry,
    required this.position,
  });
}
