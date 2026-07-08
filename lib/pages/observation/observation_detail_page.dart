import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/models/player.dart';
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
    final t = Theme.of(context).textTheme;

    final lockedThisWindow = gs.isObservedPlayerLockedThisWindow(player);
    final canNegotiate = gs.canNegotiateObservedPlayer(player);

    return Scaffold(
      appBar: AppBar(
        title: Text(player.nome),
      ),
      body: ListView(
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
                        style: t.titleLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_posLabel(player.posDet)} • ${player.idade} anos • OVR ${player.ovr}',
                        style: t.bodyMedium?.copyWith(
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
            title: 'Relatório do observado',
            children: [
              _InfoLine(label: 'Clube atual', value: clubName),
              _InfoLine(label: 'Posição', value: _posLabel(player.posDet)),
              _InfoLine(label: 'Idade', value: '${player.idade} anos'),
              _InfoLine(label: 'Overall', value: '${player.ovr}'),
              _InfoLine(
                label: 'Tempo observado',
                value: '${player.anosObservado} ano(s)',
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
                style: t.bodyMedium?.copyWith(
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
                                'Fluxo de negociação do observado ainda será conectado.',
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
    );
  }

  static String _marketSituationText({
    required bool isTransferWindowOpen,
    required bool lockedThisWindow,
    required String transferWindowLabel,
  }) {
    if (lockedThisWindow) {
      return 'Este jogador acabou de trocar de clube nesta janela. Por regra de mercado, ele não pode ser negociado novamente agora.';
    }

    if (!isTransferWindowOpen) {
      return 'A janela está fechada. O jogador permanece salvo na observação para futuras oportunidades.';
    }

    return '$transferWindowLabel aberta. Este jogador pode ser avaliado para uma tentativa de negociação.';
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

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: t.titleMedium?.copyWith(
              color: AppColors.text,
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

  const _InfoLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: t.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: t.bodyMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
