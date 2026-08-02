import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/institutional_staff_member.dart';
import 'package:footory26/models/player.dart';
import 'package:footory26/pages/observation/observation_detail_page.dart';
import 'package:footory26/services/world/catalog/institutional_staff_catalog.dart';
import 'package:footory26/services/world/game_state.dart';

class ObservationPage extends ConsumerWidget {
  const ObservationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gs = ref.watch(gameStateProvider);
    final observed = gs.observedPlayers;
    const chiefScout = InstitutionalStaffCatalog.chiefScout;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Observação'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _ChiefScoutHeader(
              member: chiefScout,
              totalObserved: observed.length,
              onOpenProfile: () {
                _showChiefScoutProfile(
                  context,
                  chiefScout,
                );
              },
            ),
            const SizedBox(height: 16),
            _ObservationSectionHeader(
              total: observed.length,
            ),
            const SizedBox(height: 12),
            if (observed.isEmpty)
              const _EmptyState()
            else
              Column(
                children: [
                  for (int i = 0; i < observed.length; i++) ...[
                    _ObservationTile(
                      player: observed[i],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ObservationDetailPage(
                              player: observed[i],
                              clubName: gs.clubName(
                                observed[i].clubIdAtual,
                              ),
                              isTransferWindowOpen: gs.isTransferWindowOpen,
                            ),
                          ),
                        );
                      },
                    ),
                    if (i != observed.length - 1) const SizedBox(height: 10),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showChiefScoutProfile(
    BuildContext context,
    InstitutionalStaffMember member,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _ChiefScoutProfileSheet(
          member: member,
        );
      },
    );
  }
}

class _ChiefScoutHeader extends StatelessWidget {
  final InstitutionalStaffMember member;
  final int totalObserved;
  final VoidCallback onOpenProfile;

  const _ChiefScoutHeader({
    required this.member,
    required this.totalObserved,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.actionGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _InstitutionalPortrait(
                assetPath: member.portraitAsset,
                size: 92,
                borderRadius: 21,
                useLightBorder: true,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      member.roleLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.white.withOpacity(0.88),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Responsável por liderar a observação e identificar '
                      'oportunidades para fortalecer o elenco.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.14),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.visibility_rounded,
                        size: 19,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          totalObserved == 0
                              ? 'Nenhum jogador observado'
                              : '$totalObserved jogador(es) observado(s)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: onOpenProfile,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    side: BorderSide(
                      color: AppColors.white.withOpacity(0.32),
                    ),
                    backgroundColor: AppColors.white.withOpacity(0.08),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                  ),
                  icon: const Icon(
                    Icons.badge_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Ver perfil',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ObservationSectionHeader extends StatelessWidget {
  final int total;

  const _ObservationSectionHeader({
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.manage_search_rounded,
            size: 21,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lista de Observação',
                style: textTheme.titleMedium?.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                total == 0
                    ? 'Nenhum atleta em acompanhamento'
                    : '$total atleta(s) em acompanhamento',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChiefScoutProfileSheet extends StatelessWidget {
  final InstitutionalStaffMember member;

  const _ChiefScoutProfileSheet({
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + bottomPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 20),
            _InstitutionalPortrait(
              assetPath: member.portraitAsset,
              size: 150,
              borderRadius: 26,
              useLightBorder: false,
            ),
            const SizedBox(height: 16),
            Text(
              member.name,
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              member.roleLabel,
              textAlign: TextAlign.center,
              style: textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),
            _ProfileSection(
              icon: Icons.person_rounded,
              title: 'Biografia',
              text: member.biography,
            ),
            const SizedBox(height: 12),
            _ProfileSection(
              icon: Icons.manage_search_rounded,
              title: 'Função no Clube',
              text: member.jobDescription,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Fechar',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _ProfileSection({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.border,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.visibility_off_outlined,
            size: 36,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 10),
          Text(
            'Você ainda não adicionou jogadores à lista de observação.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObservationTile extends StatelessWidget {
  final ObservedPlayer player;
  final VoidCallback onTap;

  const _ObservationTile({
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.border,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_posLabel(player.posDet)} • ${player.idade} anos',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${player.ovr}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'OVR',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _posLabel(PosDet pos) {
    switch (pos) {
      case PosDet.gol:
        return 'GOL';
      case PosDet.ld:
        return 'LD';
      case PosDet.le:
        return 'LE';
      case PosDet.zag:
        return 'ZAG';
      case PosDet.vol:
        return 'VOL';
      case PosDet.mc:
        return 'MC';
      case PosDet.mei:
        return 'MEI';
      case PosDet.pd:
        return 'PD';
      case PosDet.pe:
        return 'PE';
      case PosDet.ca:
        return 'CA';
    }
  }
}

class _InstitutionalPortrait extends StatelessWidget {
  final String assetPath;
  final double size;
  final double borderRadius;
  final bool useLightBorder;

  const _InstitutionalPortrait({
    required this.assetPath,
    required this.size,
    required this.borderRadius,
    required this.useLightBorder,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = useLightBorder
        ? AppColors.white.withOpacity(0.28)
        : AppColors.primary.withOpacity(0.22);

    final backgroundColor = useLightBorder
        ? AppColors.white.withOpacity(0.14)
        : AppColors.primarySoft;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: useLightBorder ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(
              useLightBorder ? 0.12 : 0.1,
            ),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          borderRadius - 3,
        ),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: backgroundColor,
              alignment: Alignment.center,
              child: Icon(
                Icons.person_search_rounded,
                size: size * 0.34,
                color: useLightBorder ? AppColors.white : AppColors.primary,
              ),
            );
          },
        ),
      ),
    );
  }
}

String _posLabel(PosDet pos) {
  switch (pos) {
    case PosDet.gol:
      return 'GOL';
    case PosDet.ld:
      return 'LD';
    case PosDet.le:
      return 'LE';
    case PosDet.zag:
      return 'ZAG';
    case PosDet.vol:
      return 'VOL';
    case PosDet.mc:
      return 'MC';
    case PosDet.mei:
      return 'MEI';
    case PosDet.pd:
      return 'PD';
    case PosDet.pe:
      return 'PE';
    case PosDet.ca:
      return 'CA';
  }
}
