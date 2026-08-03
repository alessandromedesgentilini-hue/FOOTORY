import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/services/world/catalog/south_america/brazil_club_catalog.dart';

class HubClubContextCard extends StatelessWidget {
  final String clubId;
  final String clubName;
  final String dateStr;

  const HubClubContextCard({
    super.key,
    required this.clubId,
    required this.clubName,
    required this.dateStr,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final club = BrazilClubCatalog.byId(clubId);
    final badgePath = club?.badgeAsset ?? 'assets/faces/_placeholder.png';
    final safeClubName =
        clubName.trim().isEmpty ? 'Meu Clube' : clubName.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
          _ClubBadge(
            assetPath: badgePath,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  safeClubName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        dateStr.trim().isEmpty
                            ? 'Data indisponível'
                            : dateStr.trim(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.12),
              ),
            ),
            child: Text(
              'Clube atual',
              maxLines: 1,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClubBadge extends StatelessWidget {
  final String assetPath;

  const _ClubBadge({
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return const Center(
              child: Icon(
                Icons.shield_rounded,
                color: AppColors.textMuted,
                size: 28,
              ),
            );
          },
        ),
      ),
    );
  }
}
