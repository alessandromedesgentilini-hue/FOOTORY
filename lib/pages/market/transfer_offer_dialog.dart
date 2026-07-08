import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/money_formatter.dart';
import 'package:footory26/services/world/game_state.dart';

enum TransferOfferDecision {
  accept,
  acceptAndObserve,
  reject,
}

class TransferOfferDialog extends StatelessWidget {
  final TransferOffer offer;
  final String fromClubName;
  final String toClubName;

  const TransferOfferDialog({
    super.key,
    required this.offer,
    required this.fromClubName,
    required this.toClubName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget infoTile({
      required IconData icon,
      required String label,
      required String value,
    }) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final compactOffer = MoneyFormatter.formatCurrency(offer.offeredValue);
    final fullOffer = MoneyFormatter.formatCurrencyFull(offer.offeredValue);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.actionGradient,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Proposta de Transferência',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$toClubName enviou uma proposta oficial por ${offer.playerName}.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                infoTile(
                  icon: Icons.person_rounded,
                  label: 'Jogador',
                  value: offer.playerName,
                ),
                const SizedBox(height: 10),
                infoTile(
                  icon: Icons.sports_soccer_rounded,
                  label: 'Overall',
                  value: '${offer.playerOvr}',
                ),
                const SizedBox(height: 10),
                infoTile(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Sai de',
                  value: fromClubName,
                ),
                const SizedBox(height: 10),
                infoTile(
                  icon: Icons.flag_rounded,
                  label: 'Vai para',
                  value: toClubName,
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.attach_money_rounded,
                          color: AppColors.accentDark,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Oferta oficial',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              compactOffer,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: AppColors.text,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              fullOffer,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.brownSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.brown,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Se aceitar, o jogador ainda pode recusar a transferência.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.brown,
                            fontWeight: FontWeight.w700,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(
                        TransferOfferDecision.reject,
                      );
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Recusar Proposta'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(
                        TransferOfferDecision.accept,
                      );
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Aceitar Proposta'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop(
                        TransferOfferDecision.acceptAndObserve,
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accentDark,
                      foregroundColor: AppColors.white,
                    ),
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Aceitar + Observar Jogador'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
