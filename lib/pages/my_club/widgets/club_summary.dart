import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/pages/my_club/widgets/player_shared_widgets.dart';

class ClubSummary extends StatelessWidget {
  final String divisionId;
  final int seasonYear;
  final String powerLabel10;
  final int stars5;
  final bool showCatalogDebug;
  final String catalogLabel10;
  final int catalogStars5;

  const ClubSummary({
    super.key,
    required this.divisionId,
    required this.seasonYear,
    required this.powerLabel10,
    required this.stars5,
    required this.showCatalogDebug,
    required this.catalogLabel10,
    required this.catalogStars5,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget line(String label, String value, {IconData? icon, Widget? tail}) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
            ],
            SizedBox(
              width: 150,
              child: Text(
                label,
                style: t.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: t.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  if (tail != null) ...[
                    const SizedBox(width: 8),
                    tail,
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line('Divisão', divisionId, icon: Icons.flag_outlined),
        line('Temporada', '$seasonYear', icon: Icons.calendar_month_outlined),
        const SizedBox(height: 4),
        line(
          'Força do Clube',
          powerLabel10,
          icon: Icons.bolt_outlined,
          tail: Stars5(filled: stars5, size: 18),
        ),
        if (showCatalogDebug) ...[
          const SizedBox(height: 4),
          line(
            'Catálogo (debug)',
            catalogLabel10,
            icon: Icons.lock_outline,
            tail: Stars5(filled: catalogStars5, size: 18),
          ),
        ],
      ],
    );
  }
}
