import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';

import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class HubHeaderTopInfo extends StatelessWidget {
  final String dateStr;
  final String clubName;
  final String clubId;

  const HubHeaderTopInfo({
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.actionGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                badgePath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.shield_rounded,
                  color: AppColors.white,
                  size: 52,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clubName.isEmpty ? 'Meu Clube' : clubName,
                  style: t.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Temporada em andamento',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.90),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              dateStr,
              style: t.labelLarge?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
