import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class StructureHeader extends StatelessWidget {
  final String clubName;
  final String clubId;
  final String dateStr;
  final double structuralPower;
  final int maintenance;
  final int balanceMi;

  const StructureHeader({
    super.key,
    required this.clubName,
    required this.clubId,
    required this.dateStr,
    required this.structuralPower,
    required this.maintenance,
    required this.balanceMi,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final club = BrazilClubCatalog.byId(clubId);

    final badgePath = club?.badgeAsset ?? 'assets/faces/_placeholder.png';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  badgePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.apartment_rounded,
                    color: AppColors.white,
                    size: 42,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName.isEmpty ? 'Estruturas do Clube' : clubName,
                  style: t.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Poder estrutural ${structuralPower.toStringAsFixed(1)}',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.88),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manutenção ${_money(maintenance)}/mês • Caixa ${_moneyMi(balanceMi)}',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.88),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              dateStr,
              style: t.labelLarge?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _money(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = s.length - 1; i >= 0; i--) {
      buffer.write(s[i]);
      count++;

      if (count == 3 && i != 0) {
        buffer.write('.');
        count = 0;
      }
    }

    return 'R\$ ${buffer.toString().split('').reversed.join()}';
  }

  static String _moneyMi(int value) {
    return 'R\$ $value mi';
  }
}
