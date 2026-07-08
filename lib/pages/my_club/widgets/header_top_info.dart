import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';

import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class HeaderTopInfo extends StatelessWidget {
  final String dateStr;
  final String clubName;
  final String clubId;

  const HeaderTopInfo({
    super.key,
    required this.dateStr,
    required this.clubName,
    required this.clubId,
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
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Image.asset(
                  badgePath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.shield_rounded,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName.isEmpty ? 'Meu Clube' : clubName,
                  style: t.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Visão geral do clube',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.88),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
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
}
