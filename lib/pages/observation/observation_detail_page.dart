import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/player.dart';
import 'package:footory26/services/world/catalog/institutional_staff_catalog.dart';
import 'package:footory26/services/world/game_state.dart';

class ObservationDetailPage extends ConsumerWidget {
  final ObservedPlayer player;
  final String clubName;
  final bool isTransferWindowOpen;

  const ObservationDetailPage({
    super.key,
    required this.player,
    required this.clubName,
    required this.isTransferWindowOpen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gs = ref.watch(gameStateProvider);
    final textTheme = Theme.of(context).textTheme;
    const chiefScout = InstitutionalStaffCatalog.chiefScout;

    final lockedThisWindow = gs.isObservedPlayerLockedThisWindow(player);
    final canNegotiate = gs.canNegotiateObservedPlayer(player);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(player.nome),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.actionGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person_search_rounded,
                      color: AppColors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.nome,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_posLabel(player.posDet)} • '
                          '${player.idade} anos • '
                          'OVR ${player.ovr}',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Relatório de Observação',
              children: [
                _ScoutReportAuthor(
                  name: chiefScout.name,
                  role: chiefScout.roleLabel,
                  portraitAsset: chiefScout.portraitAsset,
                ),
                const SizedBox(height: 14),
                Text(
                  'As informações abaixo representam a avaliação atual '
                  'reunida pelo departamento de recrutamento durante o '
                  'acompanhamento deste atleta.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(
                  height: 1,
                  color: AppColors.border,
                ),
                const SizedBox(height: 16),
                _InfoLine(
                  label: 'Clube atual',
                  value: clubName,
                ),
                _InfoLine(
                  label: 'Posição',
                  value: _posLabel(player.posDet),
                ),
                _InfoLine(
                  label: 'Idade',
                  value: '${player.idade} anos',
                ),
                _InfoLine(
                  label: 'Overall',
                  value: '${player.ovr}',
                ),
                _InfoLine(
                  label: 'Tempo observado',
                  value: '${player.anosObservado} ano(s)',
                  addBottomPadding: false,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Situação de mercado',
              children: [
                Text(
                  _marketSituationText(
                    isTransferWindowOpen: gs.isTransferWindowOpen,
                    lockedThisWindow: lockedThisWindow,
                    transferWindowLabel: gs.transferWindowLabel,
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: canNegotiate
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Fluxo de negociação do observado ainda '
                                  'será conectado.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        : null,
                    icon: const Icon(Icons.handshake_rounded),
                    label: Text(
                      _buttonLabel(
                        isTransferWindowOpen: gs.isTransferWindowOpen,
                        lockedThisWindow: lockedThisWindow,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _marketSituationText({
    required bool isTransferWindowOpen,
    required bool lockedThisWindow,
    required String transferWindowLabel,
  }) {
    if (lockedThisWindow) {
      return 'Este jogador acabou de trocar de clube nesta janela. '
          'Por regra de mercado, ele não pode ser negociado novamente agora.';
    }

    if (!isTransferWindowOpen) {
      return 'A janela está fechada. O jogador permanece salvo na observação '
          'para futuras oportunidades.';
    }

    return '$transferWindowLabel aberta. Este jogador pode ser avaliado para '
        'uma tentativa de negociação.';
  }

  static String _buttonLabel({
    required bool isTransferWindowOpen,
    required bool lockedThisWindow,
  }) {
    if (lockedThisWindow) return 'Recém-transferido';
    if (!isTransferWindowOpen) return 'Janela fechada';

    return 'Tentar negociação';
  }

  static String _posLabel(PosDet pos) {
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

class _ScoutReportAuthor extends StatelessWidget {
  final String name;
  final String role;
  final String portraitAsset;

  const _ScoutReportAuthor({
    required this.name,
    required this.role,
    required this.portraitAsset,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                portraitAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Container(
                    color: AppColors.primarySoft,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person_search_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Responsável pelo relatório',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_rounded,
            size: 20,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;
  final bool addBottomPadding;

  const _InfoLine({
    required this.label,
    required this.value,
    this.addBottomPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textPrimary = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.only(
        bottom: addBottomPadding ? 10 : 0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                color: textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
