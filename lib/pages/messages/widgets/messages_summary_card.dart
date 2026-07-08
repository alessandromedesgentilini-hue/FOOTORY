import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';

class MessagesSummaryCard extends StatelessWidget {
  final int unreadTotal;
  final int unreadMatch;
  final int unreadMarket;
  final int unreadFinance;
  final int unreadSeason;
  final int unreadDepartments;
  final int importantTotal;

  const MessagesSummaryCard({
    super.key,
    required this.unreadTotal,
    required this.unreadMatch,
    required this.unreadMarket,
    required this.unreadFinance,
    required this.unreadSeason,
    required this.unreadDepartments,
    required this.importantTotal,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final items = <_SummaryItem>[
      if (unreadMatch > 0)
        _SummaryItem(
          icon: Icons.sports_soccer_rounded,
          label: '$unreadMatch resumo(s) de partida',
          color: AppColors.primary,
        ),
      if (unreadMarket > 0)
        _SummaryItem(
          icon: Icons.swap_horiz_rounded,
          label: '$unreadMarket atualização(ões) de mercado',
          color: AppColors.accentDark,
        ),
      if (unreadFinance > 0)
        _SummaryItem(
          icon: Icons.account_balance_wallet_rounded,
          label: '$unreadFinance atualização(ões) financeira(s)',
          color: AppColors.warning,
        ),
      if (unreadSeason > 0)
        _SummaryItem(
          icon: Icons.insights_rounded,
          label: '$unreadSeason comunicado(s) da temporada',
          color: AppColors.primaryDark,
        ),
      if (unreadDepartments > 0)
        _SummaryItem(
          icon: Icons.badge_outlined,
          label: '$unreadDepartments relatório(s) interno(s)',
          color: AppColors.brown,
        ),
      if (importantTotal > 0)
        _SummaryItem(
          icon: Icons.priority_high_rounded,
          label: '$importantTotal mensagem(ns) pedem atenção',
          color: AppColors.danger,
        ),
    ];

    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Desde sua última visita',
                  style: t.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (unreadTotal > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: AppColors.danger.withOpacity(0.28),
                    ),
                  ),
                  child: Text(
                    '$unreadTotal nova(s)',
                    style: t.labelMedium?.copyWith(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            Text(
              'Nenhuma mensagem nova. Tudo em dia por enquanto.',
              style: t.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _SummaryRow(item: items[i]),
                  if (i != items.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _SummaryItem {
  final IconData icon;
  final String label;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.color,
  });
}

class _SummaryRow extends StatelessWidget {
  final _SummaryItem item;

  const _SummaryRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: item.color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            item.icon,
            color: item.color,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.label,
            style: t.bodyMedium?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
