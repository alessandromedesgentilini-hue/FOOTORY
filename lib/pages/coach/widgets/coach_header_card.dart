import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/models/coach_staff.dart';
import 'package:footory26/pages/coach/widgets/coach_common_widgets.dart';

class CoachHeaderCard extends StatelessWidget {
  final String clubName;
  final int level;
  final String tier;
  final CoachStaffMember coach;
  final String styleLabel;

  const CoachHeaderCard({
    super.key,
    required this.clubName,
    required this.level,
    required this.tier,
    required this.coach,
    required this.styleLabel,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.actionGradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.white.withOpacity(0.18)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                coach.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.white,
                    size: 50,
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
                CoachFlagNameLine(
                  countryCode: coach.nationalityCode,
                  name: coach.name,
                  centered: false,
                  flagSize: 20,
                  textStyle: t.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  coach.role,
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Comissão do $clubName',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.90),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nível $level • $tier',
                  style: t.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.90),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Estilo: $styleLabel',
                  style: t.bodySmall?.copyWith(
                    color: AppColors.white.withOpacity(0.86),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
