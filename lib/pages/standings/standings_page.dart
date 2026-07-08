import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/pages/standings/simon_bolivar_page.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';
import 'package:footory26/services/world/game_state.dart';

class StandingsPage extends ConsumerWidget {
  const StandingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState gs = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Classificação'),
      ),
      body: !gs.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _CompetitionHero(gs: gs),
                const SizedBox(height: 16),
                _CompetitionCard(
                  title: 'Campeonato Brasileiro',
                  subtitle: 'Tabela da divisão atual',
                  icon: Icons.table_chart_rounded,
                  status: 'Disponível',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const _BrazilianStandingsPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _CompetitionCard(
                  title: 'Copa do Brasil',
                  subtitle: 'Mata-mata nacional',
                  icon: Icons.emoji_events_rounded,
                  status: 'Em breve',
                  onTap: () {
                    _showSoon(context, 'Copa do Brasil');
                  },
                ),
                const SizedBox(height: 12),
                _CompetitionCard(
                  title: 'Taça Simón Bolívar',
                  subtitle: 'Grupos, rodadas e mata-mata continental',
                  icon: Icons.public_rounded,
                  status: gs.hasSimonBolivarGroupStage
                      ? 'Disponível'
                      : 'Aguardando sorteio',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SimonBolivarPage(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _CompetitionCard(
                  title: 'Mundial',
                  subtitle: 'Competição internacional anual',
                  icon: Icons.language_rounded,
                  status: 'Em breve',
                  onTap: () {
                    _showSoon(context, 'Mundial');
                  },
                ),
                const SizedBox(height: 12),
                _CompetitionCard(
                  title: 'Super Mundial',
                  subtitle: 'Grande torneio internacional',
                  icon: Icons.workspace_premium_rounded,
                  status: 'Em breve',
                  onTap: () {
                    _showSoon(context, 'Super Mundial');
                  },
                ),
              ],
            ),
    );
  }

  static void _showSoon(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$name ainda será liberada nesta área.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _CompetitionHero extends StatelessWidget {
  final GameState gs;

  const _CompetitionHero({
    required this.gs,
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
      child: Padding(
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
              child: const Icon(
                Icons.emoji_events_rounded,
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
                    'Competições',
                    style: t.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${gs.userClubName} • ${gs.dateStr}',
                    style: t.bodyMedium?.copyWith(
                      color: AppColors.white.withOpacity(0.88),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String status;
  final VoidCallback onTap;

  const _CompetitionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.cardShadow,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: t.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  status,
                  style: t.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BrazilianStandingsPage extends ConsumerWidget {
  const _BrazilianStandingsPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState gs = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campeonato Brasileiro'),
      ),
      body: !gs.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : _StandingsTable(gs: gs),
    );
  }
}

class _StandingsTable extends StatelessWidget {
  final GameState gs;

  const _StandingsTable({
    required this.gs,
  });

  static const double _tableMinWidth = 760;
  static const double _posW = 40;
  static const double _clubW = 220;
  static const double _playedW = 40;
  static const double _smallStatW = 36;
  static const double _goalW = 42;
  static const double _pointsW = 50;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final rows = _buildRows();

    if (rows.isEmpty) {
      return Center(
        child: Text(
          'Sem dados de classificação.',
          style: t.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final total = rows.length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(26),
            boxShadow: AppColors.cardShadow,
          ),
          child: Padding(
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
                  child: const Icon(
                    Icons.emoji_events_rounded,
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
                        'Liga ${gs.divisionId}',
                        style: t.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rodada ${gs.roundDisplay}/${gs.totalRounds}',
                        style: t.bodyMedium?.copyWith(
                          color: AppColors.white.withOpacity(0.88),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.cardShadow,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: _tableMinWidth,
              child: Column(
                children: [
                  _buildHeader(context),
                  ...List.generate(rows.length, (index) {
                    final row = rows[index];
                    final pos = index + 1;
                    return _buildRow(
                      context: context,
                      row: row,
                      pos: pos,
                      total: total,
                    );
                  }),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                    ),
                    child: Text(
                      _legendText(gs.divisionId),
                      style: t.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final headerStyle = t.labelLarge?.copyWith(
      fontWeight: FontWeight.w900,
      color: AppColors.textSecondary,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          _cell('#', w: _posW, align: TextAlign.start, style: headerStyle),
          SizedBox(
            width: _clubW,
            child: Text('Clube', style: headerStyle),
          ),
          _cell('J', w: _playedW, align: TextAlign.end, style: headerStyle),
          _gap(6),
          _cell('V', w: _smallStatW, align: TextAlign.end, style: headerStyle),
          _gap(6),
          _cell('E', w: _smallStatW, align: TextAlign.end, style: headerStyle),
          _gap(6),
          _cell('D', w: _smallStatW, align: TextAlign.end, style: headerStyle),
          _gap(10),
          _cell('GP', w: _goalW, align: TextAlign.end, style: headerStyle),
          _gap(6),
          _cell('GC', w: _goalW, align: TextAlign.end, style: headerStyle),
          _gap(6),
          _cell('SG', w: _goalW, align: TextAlign.end, style: headerStyle),
          _gap(10),
          _cell('PTS', w: _pointsW, align: TextAlign.end, style: headerStyle),
        ],
      ),
    );
  }

  Widget _buildRow({
    required BuildContext context,
    required _StandingRowData row,
    required int pos,
    required int total,
  }) {
    final t = Theme.of(context).textTheme;
    final bg = _rowBg(pos, total, row.clubId);
    final fg = _rowFg(pos, total, row.clubId);
    final name = gs.clubName(row.clubId);

    final baseStyle = t.bodyMedium?.copyWith(
      color: fg,
      fontWeight:
          row.clubId == gs.userClubId ? FontWeight.w900 : FontWeight.w700,
    );

    final numStyle = t.bodyMedium?.copyWith(
      color: fg,
      fontWeight: FontWeight.w900,
    );

    return Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Column(
        children: [
          Row(
            children: [
              _cell('$pos', w: _posW, align: TextAlign.start, style: numStyle),
              SizedBox(
                width: _clubW,
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: baseStyle,
                ),
              ),
              _cell('${row.played}',
                  w: _playedW, align: TextAlign.end, style: baseStyle),
              _gap(6),
              _cell('${row.wins}',
                  w: _smallStatW, align: TextAlign.end, style: baseStyle),
              _gap(6),
              _cell('${row.draws}',
                  w: _smallStatW, align: TextAlign.end, style: baseStyle),
              _gap(6),
              _cell('${row.losses}',
                  w: _smallStatW, align: TextAlign.end, style: baseStyle),
              _gap(10),
              _cell('${row.goalsFor}',
                  w: _goalW, align: TextAlign.end, style: baseStyle),
              _gap(6),
              _cell('${row.goalsAgainst}',
                  w: _goalW, align: TextAlign.end, style: baseStyle),
              _gap(6),
              _cell('${row.goalDiff}',
                  w: _goalW, align: TextAlign.end, style: baseStyle),
              _gap(10),
              _cell('${row.points}',
                  w: _pointsW, align: TextAlign.end, style: numStyle),
            ],
          ),
          if (pos < total)
            const Padding(
              padding: EdgeInsets.only(top: 11),
              child: Divider(height: 1, color: AppColors.border),
            ),
        ],
      ),
    );
  }

  List<_StandingRowData> _buildRows() {
    final realRows = gs.table.getSorted().map((e) {
      return _StandingRowData(
        clubId: e.clubId,
        played: e.played,
        wins: e.wins,
        draws: e.draws,
        losses: e.losses,
        goalsFor: e.goalsFor,
        goalsAgainst: e.goalsAgainst,
        goalDiff: e.goalDiff,
        points: e.points,
      );
    }).toList();

    if (realRows.isNotEmpty) return realRows;

    final division = _parseDivision(gs.divisionId);
    if (division == null) return const [];

    final clubs = BrazilClubCatalog.byDivision(division);
    if (clubs.isEmpty) return const [];

    return clubs.map((club) {
      return _StandingRowData(
        clubId: club.id,
        played: 0,
        wins: 0,
        draws: 0,
        losses: 0,
        goalsFor: 0,
        goalsAgainst: 0,
        goalDiff: 0,
        points: 0,
      );
    }).toList();
  }

  DivisionId? _parseDivision(String divisionId) {
    switch (divisionId.trim().toUpperCase()) {
      case 'BR-A':
        return DivisionId.brA;
      case 'BR-B':
        return DivisionId.brB;
      case 'BR-C':
        return DivisionId.brC;
      case 'BR-D':
        return DivisionId.brD;
      default:
        return null;
    }
  }

  String _legendText(String divisionId) {
    final div = divisionId.trim().toUpperCase();

    if (div == 'BR-A') {
      return 'Legenda: 1–4 = Briga pelo título + Super Taça Sul-Americana • 5–8 = Taça América do Sul • 17–20 = Rebaixamento';
    }

    if (div == 'BR-D') {
      return 'Legenda: 1–4 = Acesso • 17–20 = Baixa tabela (sem rebaixamento na Série D)';
    }

    return 'Legenda: 1–4 = Acesso • 17–20 = Rebaixamento';
  }

  Color? _rowBg(int pos, int total, String clubId) {
    final div = gs.divisionId.trim().toUpperCase();

    if (clubId == gs.userClubId) return AppColors.primarySoft;

    if (div == 'BR-A') {
      if (pos >= 1 && pos <= 4) return const Color(0xFFE7F6EC);
      if (pos >= 5 && pos <= 8) return AppColors.accentSoft;
      if (pos >= 17 && pos <= total) return const Color(0xFFFFE4E2);
      return null;
    }

    if (div == 'BR-D') {
      if (pos >= 1 && pos <= 4) return AppColors.accentSoft;
      if (pos > total - 4) return AppColors.surfaceSoft;
      return null;
    }

    if (pos >= 1 && pos <= 4) return AppColors.accentSoft;
    if (pos >= 17 && pos <= total) return const Color(0xFFFFE4E2);
    return null;
  }

  Color _rowFg(int pos, int total, String clubId) {
    final div = gs.divisionId.trim().toUpperCase();
    final bg = _rowBg(pos, total, clubId);

    if (bg == null) return AppColors.text;
    if (clubId == gs.userClubId) return AppColors.primaryDark;

    if (div == 'BR-A') {
      if (pos >= 1 && pos <= 4) return AppColors.success;
      if (pos >= 5 && pos <= 8) return AppColors.accentDark;
      if (pos >= 17 && pos <= total) return AppColors.danger;
    }

    if (div == 'BR-D') {
      if (pos >= 1 && pos <= 4) return AppColors.accentDark;
      return AppColors.textSecondary;
    }

    if (pos >= 1 && pos <= 4) return AppColors.accentDark;
    if (pos >= 17 && pos <= total) return AppColors.danger;

    return AppColors.text;
  }

  static Widget _gap(double value) => SizedBox(width: value);

  static Widget _cell(
    String text, {
    required double w,
    required TextAlign align,
    required TextStyle? style,
  }) {
    return SizedBox(
      width: w,
      child: Text(text, textAlign: align, style: style),
    );
  }
}

class _StandingRowData {
  final String clubId;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDiff;
  final int points;

  const _StandingRowData({
    required this.clubId,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDiff,
    required this.points,
  });
}
