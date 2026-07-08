import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/providers.dart';
import 'package:footory26/services/reports/season_report_builder.dart';

class SeasonReportPage extends ConsumerWidget {
  final SeasonReport report;

  const SeasonReportPage({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gs = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(report.title),
      ),
      body: Column(
        children: [
          _Header(
            report: report,
            legacyLine: gs.userLegacySummaryLine,
            legacyShortLabel: gs.userLegacyShortLabel,
            legacyPressureLabel: gs.userLegacyPressureLabel,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                const _SectionTitle(
                  title: 'Destaques da Temporada',
                  icon: Icons.star_rounded,
                ),
                const SizedBox(height: 10),
                _HighlightCard(
                  emoji: '🔥',
                  text: report.bestPlayer,
                ),
                const SizedBox(height: 10),
                _HighlightCard(
                  emoji: '📉',
                  text: report.worstPlayer,
                ),
                const SizedBox(height: 10),
                _HighlightCard(
                  emoji: '⚽',
                  text: report.topScorer,
                ),
                const SizedBox(height: 10),
                _HighlightCard(
                  emoji: '🎯',
                  text: report.topAssister,
                ),
                const SizedBox(height: 10),
                _HighlightCard(
                  emoji: '👑',
                  text: report.mostDecisivePlayer,
                ),
                const SizedBox(height: 20),
                const _SectionTitle(
                  title: 'Memória da Temporada',
                  icon: Icons.history_edu_rounded,
                ),
                const SizedBox(height: 10),
                if (report.seasonHighlights.isEmpty)
                  const _EmptyCard(
                    text: 'Nenhum destaque narrativo registrado.',
                  )
                else
                  _BulletListCard(
                    items: report.seasonHighlights,
                  ),
                const SizedBox(height: 20),
                const _SectionTitle(
                  title: 'Top 5 Evolução',
                  icon: Icons.trending_up_rounded,
                ),
                const SizedBox(height: 10),
                if (report.topEvolutions.isEmpty)
                  const _EmptyCard(
                    text: 'Nenhum jogador evoluiu de forma relevante.',
                  )
                else
                  _DeltaListCard(
                    items: report.topEvolutions,
                    detailed: false,
                  ),
                const SizedBox(height: 20),
                const _SectionTitle(
                  title: 'Top 5 Quedas',
                  icon: Icons.trending_down_rounded,
                ),
                const SizedBox(height: 10),
                if (report.topDeclines.isEmpty)
                  const _EmptyCard(
                    text: 'Nenhuma queda relevante registrada.',
                  )
                else
                  _DeltaListCard(
                    items: report.topDeclines,
                    detailed: false,
                  ),
                const SizedBox(height: 20),
                const _SectionTitle(
                  title: 'Elenco Completo',
                  icon: Icons.groups_rounded,
                ),
                const SizedBox(height: 10),
                if (report.playerDeltas.isEmpty)
                  const _EmptyCard(
                    text: 'Nenhum jogador no relatório.',
                  )
                else
                  _DeltaListCard(
                    items: report.playerDeltas,
                    detailed: true,
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final gs = ref.read(gameStateProvider);

                    if (gs.seasonEnded) {
                      gs.startNextSeason();
                    }

                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('Finalizar Temporada'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final SeasonReport report;
  final String legacyLine;
  final String legacyShortLabel;
  final String legacyPressureLabel;

  const _Header({
    required this.report,
    required this.legacyLine,
    required this.legacyShortLabel,
    required this.legacyPressureLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      color: Colors.grey.shade900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fechamento da temporada',
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            report.summary,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              height: 1.45,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _LegacyMiniCard(
            legacyLine: legacyLine,
            legacyShortLabel: legacyShortLabel,
            legacyPressureLabel: legacyPressureLabel,
          ),
        ],
      ),
    );
  }
}

class _LegacyMiniCard extends StatelessWidget {
  final String legacyLine;
  final String legacyShortLabel;
  final String legacyPressureLabel;

  const _LegacyMiniCard({
    required this.legacyLine,
    required this.legacyShortLabel,
    required this.legacyPressureLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DarkChip(
                icon: Icons.military_tech_rounded,
                label: legacyShortLabel,
              ),
              _DarkChip(
                icon: Icons.psychology_alt_rounded,
                label: legacyPressureLabel,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            legacyLine,
            style: const TextStyle(
              color: Colors.white,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DarkChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: Colors.white70,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String emoji;
  final String text;

  const _HighlightCard({
    required this.emoji,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletListCard extends StatelessWidget {
  final List<String> items;

  const _BulletListCard({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _DeltaListCard extends StatelessWidget {
  final List<SeasonPlayerDelta> items;
  final bool detailed;

  const _DeltaListCard({
    required this.items,
    required this.detailed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final p = items[index];
          final isLast = index == items.length - 1;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: detailed
                    ? _PlayerRowDetailed(player: p)
                    : _PlayerRow(player: p),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  color: Colors.grey.shade300,
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String text;

  const _EmptyCard({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final SeasonPlayerDelta player;

  const _PlayerRow({
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final color = _deltaColor(player.delta);

    return Row(
      children: [
        Expanded(
          child: Text(
            player.playerName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        Text('${player.fromOvr} → ${player.toOvr}'),
        const SizedBox(width: 10),
        Text(
          _deltaText(player.delta),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _PlayerRowDetailed extends StatelessWidget {
  final SeasonPlayerDelta player;

  const _PlayerRowDetailed({
    required this.player,
  });

  @override
  Widget build(BuildContext context) {
    final color = _deltaColor(player.delta);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                player.playerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Text('${player.fromOvr} → ${player.toOvr}'),
            const SizedBox(width: 10),
            Text(
              _deltaText(player.delta),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          player.message,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

Color _deltaColor(int delta) {
  if (delta > 0) return Colors.green;
  if (delta < 0) return Colors.red;
  return Colors.grey;
}

String _deltaText(int d) {
  if (d > 0) return '+$d';
  return '$d';
}
