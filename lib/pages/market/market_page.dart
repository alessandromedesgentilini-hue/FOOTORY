import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/money_formatter.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/scout/scout_target.dart';
import 'package:footory26/pages/market/market_negotiation_dialog.dart';
import 'package:footory26/services/negotiation/negotiation_service.dart';
import 'package:footory26/services/world/game_state.dart';

enum _MarketTab {
  transfers,
  loans,
  frees,
  opportunities,
  observed,
  arrivals,
}

class MarketPage extends ConsumerStatefulWidget {
  const MarketPage({super.key});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage> {
  _MarketTab _selectedTab = _MarketTab.transfers;

  @override
  Widget build(BuildContext context) {
    final GameState gs = ref.watch(gameStateProvider);

    if (!gs.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final transferTargets = gs.scoutTransfers;
    final loanTargets = gs.scoutLoans;
    final freeTargets = gs.scoutFrees;
    final observedPlayers = gs.observedPlayers;
    final futureArrivals = gs.futureArrivals;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mercado'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
          child: Column(
            children: [
              _MarketHeroCard(
                windowLabel: gs.transferWindowLabel,
                dateStr: gs.dateStr,
                nextWindowLabel: gs.nextTransferWindowLabel,
              ),
              const SizedBox(height: 8),
              _MarketQuickGrid(
                transferCount: transferTargets.length,
                loanCount: loanTargets.length,
                freeCount: freeTargets.length,
                observedCount: observedPlayers.length,
                futureCount: futureArrivals.length,
              ),
              const SizedBox(height: 8),
              _MarketMiniTabs(
                selected: _selectedTab,
                transferCount: transferTargets.length,
                loanCount: loanTargets.length,
                freeCount: freeTargets.length,
                opportunityCount: 0,
                observedCount: observedPlayers.length,
                futureCount: futureArrivals.length,
                onChanged: (tab) {
                  setState(() {
                    _selectedTab = tab;
                  });
                },
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _MarketContentPanel(
                  selectedTab: _selectedTab,
                  transferTargets: transferTargets,
                  loanTargets: loanTargets,
                  freeTargets: freeTargets,
                  observedPlayers: observedPlayers,
                  futureArrivals: futureArrivals,
                  onSign: (target) => _sign(context, ref, target),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _sign(
    BuildContext context,
    WidgetRef ref,
    ScoutTarget target,
  ) async {
    final gs = ref.read(gameStateProvider);

    final shouldSendProposal = await showDialog<bool>(
      context: context,
      builder: (context) {
        return _MarketNegotiationConfirmDialog(
          target: target,
          windowLabel: gs.transferWindowLabel,
          nextWindowLabel: gs.nextTransferWindowLabel,
        );
      },
    );

    if (!context.mounted) return;
    if (shouldSendProposal != true) return;

    final preview = gs.previewNegotiationFromScout(target);

    if (preview == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível montar a proposta neste momento.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final decision = await showDialog<MarketNegotiationDecision>(
      context: context,
      builder: (context) {
        return MarketNegotiationDialog(
          preview: preview,
          target: target,
        );
      },
    );

    if (!context.mounted) return;
    if (decision != MarketNegotiationDecision.confirm) return;

    final msg = gs.trySignFromScout(target);

    if (!context.mounted) return;

    final lower = msg.toLowerCase();
    final success = lower.contains('sucesso') ||
        lower.contains('chegada confirmada') ||
        lower.contains('acertad');

    final outcome = NegotiationOutcome(
      type: success
          ? NegotiationOutcomeType.success
          : NegotiationOutcomeType.failed,
      success: success,
      title: success ? 'Negociação concluída' : 'Negociação frustrada',
      message: msg,
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return MarketNegotiationResultDialog(
          outcome: outcome,
          preview: preview,
        );
      },
    );
  }
}

class _MarketHeroCard extends StatelessWidget {
  final String windowLabel;
  final String dateStr;
  final String nextWindowLabel;

  const _MarketHeroCard({
    required this.windowLabel,
    required this.dateStr,
    required this.nextWindowLabel,
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
              Icons.swap_horiz_rounded,
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
                  windowLabel,
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
                  'Negociações disponíveis em $dateStr',
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
                    _HeroPill(label: dateStr),
                    const SizedBox(width: 6),
                    _HeroPill(label: 'Próxima: $nextWindowLabel'),
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

class _MarketQuickGrid extends StatelessWidget {
  final int transferCount;
  final int loanCount;
  final int freeCount;
  final int observedCount;
  final int futureCount;

  const _MarketQuickGrid({
    required this.transferCount,
    required this.loanCount,
    required this.freeCount,
    required this.observedCount,
    required this.futureCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _QuickTile(
              icon: Icons.handshake_outlined,
              label: 'Transfer.',
              value: '$transferCount',
            ),
            const SizedBox(width: 7),
            _QuickTile(
              icon: Icons.compare_arrows_rounded,
              label: 'Emprést.',
              value: '$loanCount',
            ),
            const SizedBox(width: 7),
            _QuickTile(
              icon: Icons.person_add_alt_1_rounded,
              label: 'Livres',
              value: '$freeCount',
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            const _QuickTile(
              icon: Icons.local_fire_department_rounded,
              label: 'Oportun.',
              value: '0',
            ),
            const SizedBox(width: 7),
            _QuickTile(
              icon: Icons.visibility_outlined,
              label: 'Observ.',
              value: '$observedCount',
            ),
            const SizedBox(width: 7),
            _QuickTile(
              icon: Icons.event_available_rounded,
              label: 'Chegadas',
              value: '$futureCount',
            ),
          ],
        ),
      ],
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
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
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
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: AppColors.primary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
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

class _MarketMiniTabs extends StatelessWidget {
  final _MarketTab selected;
  final int transferCount;
  final int loanCount;
  final int freeCount;
  final int opportunityCount;
  final int observedCount;
  final int futureCount;
  final ValueChanged<_MarketTab> onChanged;

  const _MarketMiniTabs({
    required this.selected,
    required this.transferCount,
    required this.loanCount,
    required this.freeCount,
    required this.opportunityCount,
    required this.observedCount,
    required this.futureCount,
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
            label: 'Transfer.',
            count: transferCount,
            selected: selected == _MarketTab.transfers,
            onTap: () => onChanged(_MarketTab.transfers),
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: 'Emprést.',
            count: loanCount,
            selected: selected == _MarketTab.loans,
            onTap: () => onChanged(_MarketTab.loans),
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: 'Livres',
            count: freeCount,
            selected: selected == _MarketTab.frees,
            onTap: () => onChanged(_MarketTab.frees),
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: 'Oportun.',
            count: opportunityCount,
            selected: selected == _MarketTab.opportunities,
            onTap: () => onChanged(_MarketTab.opportunities),
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: 'Observ.',
            count: observedCount,
            selected: selected == _MarketTab.observed,
            onTap: () => onChanged(_MarketTab.observed),
          ),
          const SizedBox(width: 6),
          _TabChip(
            label: 'Chegadas',
            count: futureCount,
            selected: selected == _MarketTab.arrivals,
            onTap: () => onChanged(_MarketTab.arrivals),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.count,
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
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.primary.withOpacity(0.13),
            ),
          ),
          child: Row(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: selected ? AppColors.white : AppColors.primaryDark,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.white.withOpacity(0.18)
                      : AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 8,
                        color:
                            selected ? AppColors.white : AppColors.primaryDark,
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MarketContentPanel extends StatelessWidget {
  final _MarketTab selectedTab;
  final List<ScoutTarget> transferTargets;
  final List<ScoutTarget> loanTargets;
  final List<ScoutTarget> freeTargets;
  final List<ObservedPlayer> observedPlayers;
  final List<FutureArrival> futureArrivals;
  final void Function(ScoutTarget) onSign;

  const _MarketContentPanel({
    required this.selectedTab,
    required this.transferTargets,
    required this.loanTargets,
    required this.freeTargets,
    required this.observedPlayers,
    required this.futureArrivals,
    required this.onSign,
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
      case _MarketTab.transfers:
        return 'Alvos de Transferência';
      case _MarketTab.loans:
        return 'Alvos de Empréstimo';
      case _MarketTab.frees:
        return 'Jogadores Livres';
      case _MarketTab.opportunities:
        return 'Oportunidades de Mercado';
      case _MarketTab.observed:
        return 'Lista de Observação';
      case _MarketTab.arrivals:
        return 'Chegadas Confirmadas';
    }
  }

  String get _subtitle {
    switch (selectedTab) {
      case _MarketTab.transfers:
        return 'Negocie reforços. Fora da janela, a chegada fica agendada.';
      case _MarketTab.loans:
        return 'Reforços temporários para equilibrar o elenco.';
      case _MarketTab.frees:
        return 'Atletas sem clube disponíveis para chegada imediata.';
      case _MarketTab.opportunities:
        return 'Jogadores fora da curva aparecerão aqui quando forem detectados.';
      case _MarketTab.observed:
        return 'Jogadores acompanhados pelo clube.';
      case _MarketTab.arrivals:
        return 'Contratações já fechadas para próximas janelas.';
    }
  }

  IconData get _icon {
    switch (selectedTab) {
      case _MarketTab.transfers:
        return Icons.handshake_outlined;
      case _MarketTab.loans:
        return Icons.compare_arrows_rounded;
      case _MarketTab.frees:
        return Icons.person_add_alt_1_rounded;
      case _MarketTab.opportunities:
        return Icons.local_fire_department_rounded;
      case _MarketTab.observed:
        return Icons.visibility_outlined;
      case _MarketTab.arrivals:
        return Icons.event_available_rounded;
    }
  }

  Widget _buildContent(BuildContext context) {
    switch (selectedTab) {
      case _MarketTab.transfers:
        return _ScoutTargetList(
          targets: transferTargets,
          emptyText: 'Nenhum alvo de transferência disponível no momento.',
          onSign: onSign,
        );
      case _MarketTab.loans:
        return _ScoutTargetList(
          targets: loanTargets,
          emptyText: 'Nenhum alvo de empréstimo disponível no momento.',
          onSign: onSign,
        );
      case _MarketTab.frees:
        return _ScoutTargetList(
          targets: freeTargets,
          emptyText: 'Nenhum jogador livre disponível no momento.',
          onSign: onSign,
        );
      case _MarketTab.opportunities:
        return const _EmptyState(
          icon: Icons.local_fire_department_rounded,
          title: 'Nenhuma oportunidade ativa',
          text:
              'Quando o mercado encontrar um jogador fora da curva, ele aparecerá aqui.',
        );
      case _MarketTab.observed:
        return _ObservedPlayerList(players: observedPlayers);
      case _MarketTab.arrivals:
        return _FutureArrivalList(arrivals: futureArrivals);
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

class _ScoutTargetList extends StatelessWidget {
  final List<ScoutTarget> targets;
  final String emptyText;
  final void Function(ScoutTarget) onSign;

  const _ScoutTargetList({
    required this.targets,
    required this.emptyText,
    required this.onSign,
  });

  @override
  Widget build(BuildContext context) {
    if (targets.isEmpty) {
      return _EmptyState(
        icon: Icons.search_off_rounded,
        title: 'Lista vazia',
        text: emptyText,
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: targets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _ScoutRow(
          target: targets[index],
          onSign: onSign,
        );
      },
    );
  }
}

class _ObservedPlayerList extends StatelessWidget {
  final List<ObservedPlayer> players;

  const _ObservedPlayerList({
    required this.players,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return const _EmptyState(
        icon: Icons.visibility_off_rounded,
        title: 'Nenhum jogador observado',
        text: 'Jogadores acompanhados aparecerão aqui.',
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: players.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _ObservedPlayerRow(player: players[index]);
      },
    );
  }
}

class _FutureArrivalList extends StatelessWidget {
  final List<FutureArrival> arrivals;

  const _FutureArrivalList({
    required this.arrivals,
  });

  @override
  Widget build(BuildContext context) {
    if (arrivals.isEmpty) {
      return const _EmptyState(
        icon: Icons.event_busy_rounded,
        title: 'Nenhuma chegada confirmada',
        text: 'Contratações futuras aparecerão aqui após negociações fechadas.',
      );
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: arrivals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _FutureArrivalRow(arrival: arrivals[index]);
      },
    );
  }
}

class _ScoutRow extends StatelessWidget {
  final ScoutTarget target;
  final void Function(ScoutTarget) onSign;

  const _ScoutRow({
    required this.target,
    required this.onSign,
  });

  Color _qualityColor(String quality) {
    switch (quality.toUpperCase()) {
      case 'A':
        return AppColors.success;
      case 'B':
        return AppColors.primary;
      case 'C':
        return AppColors.accent;
      case 'D':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _listActionLabel(MarketListType type) {
    switch (type) {
      case MarketListType.transfer:
        return 'Negociar';
      case MarketListType.loan:
        return 'Empréstimo';
      case MarketListType.free:
        return 'Assinar';
    }
  }

  String _listTagLabel(MarketListType type) {
    switch (type) {
      case MarketListType.transfer:
        return 'Transferência';
      case MarketListType.loan:
        return 'Empréstimo';
      case MarketListType.free:
        return 'Livre';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qualityColor = _qualityColor(target.qualityLabel);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _PlayerFace(asset: target.faceAsset, size: 46),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${target.playerName} — ${target.posLabel}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: 6,
                      runSpacing: 5,
                      children: [
                        _TagChip(text: _listTagLabel(target.listType)),
                        _TagChip(
                          text: 'Qualidade ${target.qualityLabel}',
                          textColor: qualityColor,
                        ),
                      ],
                    ),
                    if (target.motivo.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        target.motivo,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: qualityColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  target.qualityLabel,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: qualityColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          SizedBox(
            height: 38,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => onSign(target),
              icon: Icon(
                target.listType == MarketListType.free
                    ? Icons.check_circle_outline_rounded
                    : Icons.swap_horiz_rounded,
                size: 18,
              ),
              label: Text(_listActionLabel(target.listType)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FutureArrivalRow extends StatelessWidget {
  final FutureArrival arrival;

  const _FutureArrivalRow({
    required this.arrival,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final player = arrival.player;
    final cost = MoneyFormatter.formatCurrency(arrival.agreedCost);
    final salary = MoneyFormatter.formatCurrency(arrival.agreedSalary);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          _PlayerFace(asset: player.faceAsset, size: 46),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${player.nome} — ${player.posLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${arrival.typeLabel} • OVR ${player.ovrCheio} • Chega em ${arrival.arrivalLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Custo: $cost • Salário: $salary/mês',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
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

class _ObservedPlayerRow extends StatelessWidget {
  final ObservedPlayer player;

  const _ObservedPlayerRow({
    required this.player,
  });

  String _safePosName(Object posDet) {
    return posDet.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pos = _safePosName(player.posDet).toUpperCase();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          _PlayerFace(asset: player.faceAsset, size: 42),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${player.nome} — $pos',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${player.idade} anos • OVR ${player.ovr} • ${player.anosObservado} ano(s) observado',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.045),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.10),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 34,
              color: AppColors.primary,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketNegotiationConfirmDialog extends StatelessWidget {
  final ScoutTarget target;
  final String windowLabel;
  final String nextWindowLabel;

  const _MarketNegotiationConfirmDialog({
    required this.target,
    required this.windowLabel,
    required this.nextWindowLabel,
  });

  String get _title {
    switch (target.listType) {
      case MarketListType.transfer:
        return 'Negociar transferência';
      case MarketListType.loan:
        return 'Negociar empréstimo';
      case MarketListType.free:
        return 'Assinar jogador livre';
    }
  }

  String get _body {
    switch (target.listType) {
      case MarketListType.transfer:
        return 'O Departamento Financeiro vai entrar em contato para tentar fechar a contratação de ${target.playerName}. Se estiver fora da janela, a chegada será confirmada para a próxima janela.';
      case MarketListType.loan:
        return 'O Departamento Financeiro vai negociar as condições de empréstimo de ${target.playerName}. Se estiver fora da janela, a chegada será confirmada para a próxima janela.';
      case MarketListType.free:
        return 'O Departamento Financeiro vai negociar luvas e salário para assinar com ${target.playerName}. Jogadores livres chegam imediatamente.';
    }
  }

  String get _confirmLabel {
    switch (target.listType) {
      case MarketListType.transfer:
        return 'Enviar proposta';
      case MarketListType.loan:
        return 'Negociar empréstimo';
      case MarketListType.free:
        return 'Enviar proposta';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFree = target.listType == MarketListType.free;

    return AlertDialog(
      title: Text(_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PlayerFace(asset: target.faceAsset, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${target.playerName} — ${target.posLabel}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Qualidade estimada: ${target.qualityLabel}'),
          const SizedBox(height: 12),
          Text(_body),
          const SizedBox(height: 12),
          Text(
            'Janela atual: $windowLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (!isFree) ...[
            const SizedBox(height: 6),
            Text(
              'Próxima chegada possível: $nextWindowLabel',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(_confirmLabel),
        ),
      ],
    );
  }
}

class _PlayerFace extends StatelessWidget {
  final String asset;
  final double size;

  const _PlayerFace({
    required this.asset,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Image.asset(
        asset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Icon(
            Icons.person_rounded,
            color: AppColors.primary,
            size: size * 0.55,
          );
        },
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String text;
  final Color? textColor;

  const _TagChip({
    required this.text,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 8.5,
              color: textColor ?? AppColors.textSecondary,
              fontWeight: FontWeight.w800,
            ),
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
