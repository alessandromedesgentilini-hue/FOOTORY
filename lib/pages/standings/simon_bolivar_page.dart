import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/continental/simon_bolivar_group_table.dart';
import 'package:footory26/services/world/game_state.dart';

class SimonBolivarPage extends ConsumerWidget {
  const SimonBolivarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState gs = ref.watch(gameStateProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Taça Simón Bolívar'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Grupos'),
              Tab(text: 'Mata-mata'),
            ],
          ),
        ),
        body: !gs.isInitialized
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _GroupsTab(gs: gs),
                  _KnockoutTab(gs: gs),
                ],
              ),
      ),
    );
  }
}

class _GroupsTab extends StatelessWidget {
  final GameState gs;

  const _GroupsTab({
    required this.gs,
  });

  @override
  Widget build(BuildContext context) {
    final fixtures = gs.simonBolivarGroupFixtures;

    if (fixtures.isEmpty) {
      return const _EmptyCompetitionState(
        icon: Icons.public_rounded,
        title: 'Fase de grupos ainda não sorteada',
        message:
            'A Taça Simón Bolívar será exibida aqui quando os grupos forem gerados.',
      );
    }

    final tables = _buildTables();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _HeaderCard(
          title: 'Fase de Grupos',
          subtitle: '${tables.length} grupos • ${fixtures.length} jogos',
          icon: Icons.public_rounded,
        ),
        const SizedBox(height: 16),
        ...tables.map((table) {
          final groupFixtures =
              fixtures.where((fx) => fx.groupId == table.groupId).toList()
                ..sort((a, b) {
                  final r = a.round.compareTo(b.round);
                  if (r != 0) return r;
                  return a.id.compareTo(b.id);
                });

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _GroupCard(
              gs: gs,
              table: table,
              fixtures: groupFixtures,
            ),
          );
        }),
      ],
    );
  }

  List<SimonBolivarGroupTable> _buildTables() {
    final fixtures = gs.simonBolivarGroupFixtures;
    final clubsByGroup = <String, Set<String>>{};

    for (final fx in fixtures) {
      clubsByGroup.putIfAbsent(fx.groupId, () => <String>{});
      clubsByGroup[fx.groupId]!.add(fx.homeClubId);
      clubsByGroup[fx.groupId]!.add(fx.awayClubId);
    }

    final tables = <String, SimonBolivarGroupTable>{};

    for (final entry in clubsByGroup.entries) {
      tables[entry.key] = SimonBolivarGroupTable(
        groupId: entry.key,
        clubIds: entry.value.toList(),
      );
    }

    for (final fx in fixtures) {
      if (!fx.isPlayed) continue;

      final table = tables[fx.groupId];
      if (table == null) continue;

      table.applyMatch(
        homeClubId: fx.homeClubId,
        awayClubId: fx.awayClubId,
        homeGoals: fx.homeGoals!,
        awayGoals: fx.awayGoals!,
      );
    }

    final out = tables.values.toList();
    out.sort((a, b) => a.groupId.compareTo(b.groupId));

    return out;
  }
}

class _GroupCard extends StatelessWidget {
  final GameState gs;
  final SimonBolivarGroupTable table;
  final List<dynamic> fixtures;

  const _GroupCard({
    required this.gs,
    required this.table,
    required this.fixtures,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final rows = table.sorted();

    final rounds = fixtures.map((fx) => fx.round as int).toSet().toList()
      ..sort();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Grupo ${table.groupId}',
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const Spacer(),
                Text(
                  '${fixtures.where((fx) => fx.isPlayed == true).length}/${fixtures.length} jogos',
                  style: t.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _GroupTableRows(gs: gs, rows: rows),
          const Divider(height: 24, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jogos',
                  style: t.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 10),
                ...rounds.map((round) {
                  final roundFixtures =
                      fixtures.where((fx) => fx.round == round).toList();

                  return _RoundBlock(
                    gs: gs,
                    round: round,
                    fixtures: roundFixtures,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupTableRows extends StatelessWidget {
  final GameState gs;
  final List<SimonBolivarGroupTableEntry> rows;

  const _GroupTableRows({
    required this.gs,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Row(
            children: [
              _cell('#', 28, t.labelSmall, TextAlign.start),
              Expanded(
                child: Text(
                  'Clube',
                  style: t.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _cell('J', 28, t.labelSmall, TextAlign.end),
              _cell('SG', 36, t.labelSmall, TextAlign.end),
              _cell('PTS', 42, t.labelSmall, TextAlign.end),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(rows.length, (index) {
            final row = rows[index];
            final pos = index + 1;
            final isUser = row.clubId == gs.userClubId;
            final isQualified = pos <= 2;

            final color = isUser
                ? AppColors.primaryDark
                : isQualified
                    ? AppColors.success
                    : AppColors.text;

            final bg = isUser
                ? AppColors.primarySoft
                : isQualified
                    ? const Color(0xFFE7F6EC)
                    : null;

            return Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              margin: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    child: Text(
                      '$pos',
                      style: t.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      gs.clubName(row.clubId),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall?.copyWith(
                        fontWeight: isUser ? FontWeight.w900 : FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                  _value('${row.played}', 28, color, t),
                  _value('${row.goalDifference}', 36, color, t),
                  _value('${row.points}', 42, color, t),
                ],
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Legenda: 1º e 2º colocados avançam às oitavas.',
              style: t.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _cell(
    String text,
    double width,
    TextStyle? style,
    TextAlign align,
  ) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: align,
        style: style?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  static Widget _value(
    String text,
    double width,
    Color color,
    TextTheme t,
  ) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: t.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _RoundBlock extends StatelessWidget {
  final GameState gs;
  final int round;
  final List<dynamic> fixtures;

  const _RoundBlock({
    required this.gs,
    required this.round,
    required this.fixtures,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rodada $round',
              style: t.labelLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            ...fixtures.map((fx) {
              final played = fx.isPlayed == true;
              final score = played ? '${fx.homeGoals} x ${fx.awayGoals}' : 'x';

              final isUser = fx.homeClubId == gs.userClubId ||
                  fx.awayClubId == gs.userClubId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        gs.clubName(fx.homeClubId),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        style: t.bodySmall?.copyWith(
                          fontWeight:
                              isUser ? FontWeight.w900 : FontWeight.w600,
                          color:
                              isUser ? AppColors.primaryDark : AppColors.text,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 62,
                      child: Text(
                        score,
                        textAlign: TextAlign.center,
                        style: t.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color:
                              played ? AppColors.text : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        gs.clubName(fx.awayClubId),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall?.copyWith(
                          fontWeight:
                              isUser ? FontWeight.w900 : FontWeight.w600,
                          color:
                              isUser ? AppColors.primaryDark : AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _KnockoutTab extends StatelessWidget {
  final GameState gs;

  const _KnockoutTab({
    required this.gs,
  });

  @override
  Widget build(BuildContext context) {
    final fixtures = gs.simonBolivarKnockoutFixtures;

    if (fixtures.isEmpty) {
      return const _EmptyCompetitionState(
        icon: Icons.account_tree_rounded,
        title: 'Mata-mata ainda não definido',
        message:
            'As oitavas aparecerão aqui quando a fase de grupos for encerrada.',
      );
    }

    final phases = fixtures.map((fx) => fx.phase).toSet().toList()..sort();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _HeaderCard(
          title: 'Mata-mata',
          subtitle: '${fixtures.length} jogos definidos',
          icon: Icons.account_tree_rounded,
        ),
        const SizedBox(height: 16),
        ...phases.map((phase) {
          final phaseFixtures =
              fixtures.where((fx) => fx.phase == phase).toList()
                ..sort((a, b) {
                  final leg = a.leg.compareTo(b.leg);
                  if (leg != 0) return leg;
                  return a.id.compareTo(b.id);
                });

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _KnockoutPhaseCard(
              gs: gs,
              phase: phase,
              fixtures: phaseFixtures,
            ),
          );
        }),
      ],
    );
  }
}

class _KnockoutPhaseCard extends StatelessWidget {
  final GameState gs;
  final int phase;
  final List<dynamic> fixtures;

  const _KnockoutPhaseCard({
    required this.gs,
    required this.phase,
    required this.fixtures,
  });

  String get _title {
    switch (phase) {
      case 1:
        return 'Oitavas de final';
      case 2:
        return 'Quartas de final';
      case 3:
        return 'Semifinais';
      case 4:
        return 'Final';
      default:
        return 'Fase $phase';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _title,
            style: t.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 12),
          ...fixtures.map((fx) {
            final played = fx.isPlayed == true;
            final score = played ? '${fx.homeGoals} x ${fx.awayGoals}' : 'x';
            final isUser = fx.homeClubId == gs.userClubId ||
                fx.awayClubId == gs.userClubId;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primarySoft : AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 54,
                    child: Text(
                      phase == 4 ? 'Final' : 'Jogo ${fx.leg}',
                      style: t.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      gs.clubName(fx.homeClubId),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: t.bodySmall?.copyWith(
                        fontWeight: isUser ? FontWeight.w900 : FontWeight.w600,
                        color: isUser ? AppColors.primaryDark : AppColors.text,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 62,
                    child: Text(
                      score,
                      textAlign: TextAlign.center,
                      style: t.bodySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color:
                            played ? AppColors.text : AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      gs.clubName(fx.awayClubId),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodySmall?.copyWith(
                        fontWeight: isUser ? FontWeight.w900 : FontWeight.w600,
                        color: isUser ? AppColors.primaryDark : AppColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: AppColors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.88),
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

class _EmptyCompetitionState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyCompetitionState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 46,
                color: AppColors.primary,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: t.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: t.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
