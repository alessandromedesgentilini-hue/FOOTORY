import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';

class CoachSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const CoachSectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 20, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class CoachIdentityRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const CoachIdentityRow({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

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
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 86,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                label,
                style: t.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                value,
                style: t.bodyMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w800,
                  height: 1.35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CoachInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? tail;

  const CoachInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.tail,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: t.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: t.bodyMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (tail != null) ...[
                  const SizedBox(width: 8),
                  tail!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CoachBulletLine extends StatelessWidget {
  final String text;

  const CoachBulletLine({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: AppColors.accent,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: t.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class CoachStars5 extends StatelessWidget {
  final int filled;

  const CoachStars5({
    super.key,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final f = filled.clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final on = i < f;
        return Icon(
          on ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 18,
          color: on ? AppColors.star : AppColors.textMuted,
        );
      }),
    );
  }
}

class CoachFlagNameLine extends StatelessWidget {
  final String countryCode;
  final String name;
  final bool centered;
  final double flagSize;
  final TextStyle? textStyle;

  const CoachFlagNameLine({
    super.key,
    required this.countryCode,
    required this.name,
    required this.centered,
    required this.flagSize,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final flagPath = _flagAssetFromCode(countryCode);

    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          flagPath,
          width: flagSize,
          height: flagSize,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: flagSize,
            height: flagSize,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            alignment: Alignment.center,
            child: Text(
              countryCode.toUpperCase(),
              style: TextStyle(
                fontSize: flagSize * 0.38,
                fontWeight: FontWeight.w900,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}

String _flagAssetFromCode(String code) {
  final normalized = code.trim().toLowerCase();

  switch (normalized) {
    case 'eng':
      return 'assets/flags/eng.png';
    default:
      return 'assets/flags/$normalized.png';
  }
}
