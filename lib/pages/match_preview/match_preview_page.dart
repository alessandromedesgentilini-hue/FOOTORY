import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/pages/match_live/match_live_page.dart';
import 'package:footory26/pages/match_preview/models/match_preview_player.dart';
import 'package:footory26/pages/match_preview/widgets/match_preview_cards.dart';
import 'package:footory26/services/tactics/formation_asset_service.dart';
import 'package:footory26/services/world/catalog/coach_tactical_catalog.dart';

enum _PreviewTab {
  plan,
  starters,
  reserves,
  analysis,
}

class MatchPreviewPage extends StatefulWidget {
  final String homeClubName;
  final String awayClubName;
  final String userClubName;
  final String tacticalIdentityId;

  final List<MatchPreviewPlayer> starters;
  final List<MatchPreviewPlayer> reserves;

  final String momentText;
  final String opponentReport;

  const MatchPreviewPage({
    super.key,
    required this.homeClubName,
    required this.awayClubName,
    required this.userClubName,
    required this.tacticalIdentityId,
    required this.starters,
    required this.reserves,
    required this.momentText,
    required this.opponentReport,
  });

  @override
  State<MatchPreviewPage> createState() => _MatchPreviewPageState();
}

class _MatchPreviewPageState extends State<MatchPreviewPage> {
  _PreviewTab _selectedTab = _PreviewTab.plan;

  @override
  Widget build(BuildContext context) {
    final identity = CoachTacticalCatalog.fromId(widget.tacticalIdentityId);
    final formationAsset =
        const FormationAssetService().assetPath(identity.mainFormation);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Prévia da Partida'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Column(
            children: [
              _MatchHeroCard(
                homeClubName: widget.homeClubName,
                awayClubName: widget.awayClubName,
                styleName: identity.name,
                formation: identity.mainFormation,
              ),
              const SizedBox(height: 8),
              _PreviewQuickGrid(
                formation: identity.mainFormation,
                startersCount: widget.starters.length,
                reservesCount: widget.reserves.length,
                styleName: identity.name,
              ),
              const SizedBox(height: 8),
              _PreviewMiniTabs(
                selected: _selectedTab,
                onChanged: (tab) {
                  setState(() {
                    _selectedTab = tab;
                  });
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _PreviewContentPanel(
                  selectedTab: _selectedTab,
                  formationAsset: formationAsset,
                  starters: widget.starters,
                  reserves: widget.reserves,
                  philosophyDescription: identity.philosophyDescription,
                  momentText: widget.momentText,
                  opponentReport: widget.opponentReport,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 54,
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Ir para transmissão'),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const MatchLivePage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchHeroCard extends StatelessWidget {
  final String homeClubName;
  final String awayClubName;
  final String styleName;
  final String formation;

  const _MatchHeroCard({
    required this.homeClubName,
    required this.awayClubName,
    required this.styleName,
    required this.formation,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      height: 118,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.actionGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.white.withOpacity(0.18),
              ),
            ),
            child: const Icon(
              Icons.sports_soccer_rounded,
              color: AppColors.white,
              size: 42,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$homeClubName x $awayClubName',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  styleName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.94),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _HeroPill(label: formation.toUpperCase()),
                    const SizedBox(width: 6),
                    const _HeroPill(label: 'Pré-jogo'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final String label;

  const _HeroPill({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: AppColors.white.withOpacity(0.14),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
        ),
      ),
    );
  }
}

class _PreviewQuickGrid extends StatelessWidget {
  final String formation;
  final int startersCount;
  final int reservesCount;
  final String styleName;

  const _PreviewQuickGrid({
    required this.formation,
    required this.startersCount,
    required this.reservesCount,
    required this.styleName,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: Row(
        children: [
          _QuickTile(
            icon: Icons.account_tree_outlined,
            label: 'Formação',
            value: formation.toUpperCase(),
          ),
          const SizedBox(width: 7),
          _QuickTile(
            icon: Icons.groups_rounded,
            label: 'Titulares',
            value: '$startersCount',
          ),
          const SizedBox(width: 7),
          _QuickTile(
            icon: Icons.event_seat_rounded,
            label: 'Reservas',
            value: '$reservesCount',
          ),
          const SizedBox(width: 7),
          _QuickTile(
            icon: Icons.auto_awesome_rounded,
            label: 'Estilo',
            value: styleName,
          ),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 66,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.13),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.045),
              blurRadius: 9,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
            const SizedBox(height: 3),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                        height: 1,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 7.8,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    height: 1,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewMiniTabs extends StatelessWidget {
  final _PreviewTab selected;
  final ValueChanged<_PreviewTab> onChanged;

  const _PreviewMiniTabs({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _TabChip(
            label: 'Plano',
            selected: selected == _PreviewTab.plan,
            onTap: () => onChanged(_PreviewTab.plan),
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: 'Titulares',
            selected: selected == _PreviewTab.starters,
            onTap: () => onChanged(_PreviewTab.starters),
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: 'Reservas',
            selected: selected == _PreviewTab.reserves,
            onTap: () => onChanged(_PreviewTab.reserves),
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: 'Análise',
            selected: selected == _PreviewTab.analysis,
            onTap: () => onChanged(_PreviewTab.analysis),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.13),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: selected ? AppColors.white : AppColors.primaryDark,
                  fontWeight: FontWeight.w900,
                ),
          ),
        ),
      ),
    );
  }
}

class _PreviewContentPanel extends StatelessWidget {
  final _PreviewTab selectedTab;
  final String formationAsset;
  final List<MatchPreviewPlayer> starters;
  final List<MatchPreviewPlayer> reserves;
  final String philosophyDescription;
  final String momentText;
  final String opponentReport;

  const _PreviewContentPanel({
    required this.selectedTab,
    required this.formationAsset,
    required this.starters,
    required this.reserves,
    required this.philosophyDescription,
    required this.momentText,
    required this.opponentReport,
  });

  @override
  Widget build(BuildContext context) {
    return _PremiumSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelHeader(
            title: _title,
            subtitle: _subtitle,
            icon: _icon,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _buildContent(context),
          ),
        ],
      ),
    );
  }

  String get _title {
    switch (selectedTab) {
      case _PreviewTab.plan:
        return 'Plano de Jogo';
      case _PreviewTab.starters:
        return 'Titulares';
      case _PreviewTab.reserves:
        return 'Banco de Reservas';
      case _PreviewTab.analysis:
        return 'Análise da Partida';
    }
  }

  String get _subtitle {
    switch (selectedTab) {
      case _PreviewTab.plan:
        return 'Formação principal e ideia de jogo.';
      case _PreviewTab.starters:
        return 'Onze jogadores escolhidos para iniciar.';
      case _PreviewTab.reserves:
        return 'Opções disponíveis no banco.';
      case _PreviewTab.analysis:
        return 'Momento, adversário e leitura tática.';
    }
  }

  IconData get _icon {
    switch (selectedTab) {
      case _PreviewTab.plan:
        return Icons.account_tree_outlined;
      case _PreviewTab.starters:
        return Icons.groups_rounded;
      case _PreviewTab.reserves:
        return Icons.event_seat_rounded;
      case _PreviewTab.analysis:
        return Icons.manage_search_rounded;
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (selectedTab) {
      case _PreviewTab.plan:
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _FormationImage(asset: formationAsset),
            const SizedBox(height: 10),
            _TextBlock(
              icon: Icons.psychology_alt_outlined,
              title: 'Filosofia',
              text: philosophyDescription,
            ),
          ],
        );

      case _PreviewTab.starters:
        return _PlayerList(
          players: starters.take(11).toList(),
          emptyText: 'Nenhum titular definido.',
        );

      case _PreviewTab.reserves:
        return _PlayerList(
          players: reserves,
          emptyText: 'Nenhum reserva definido.',
        );

      case _PreviewTab.analysis:
        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.zero,
          children: [
            _TextBlock(
              icon: Icons.trending_up_rounded,
              title: 'Momento do Clube',
              text: momentText,
            ),
            const SizedBox(height: 8),
            _TextBlock(
              icon: Icons.manage_search_rounded,
              title: 'Relatório do Adversário',
              text: opponentReport,
            ),
            const SizedBox(height: 8),
            _TextBlock(
              icon: Icons.auto_awesome_rounded,
              title: 'Filosofia da Comissão',
              text: philosophyDescription,
            ),
          ],
        );
    }
  }
}

class _PanelHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PanelHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: AppColors.primaryDark,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryDark,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormationImage extends StatelessWidget {
  final String asset;

  const _FormationImage({
    required this.asset,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 210,
        width: double.infinity,
        color: AppColors.surfaceSoft,
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              'Imagem da formação não encontrada',
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerList extends StatelessWidget {
  final List<MatchPreviewPlayer> players;
  final String emptyText;

  const _PlayerList({
    required this.players,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
        ),
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: players.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return MatchPreviewPlayerTile(player: players[index]);
      },
    );
  }
}

class _TextBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _TextBlock({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.labelMedium?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: t.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _PremiumSurface extends StatelessWidget {
  final Widget child;

  const _PremiumSurface({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.13),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.065),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}
