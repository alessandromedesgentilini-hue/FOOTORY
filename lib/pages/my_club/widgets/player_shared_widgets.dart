import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/pages/my_club/player_ui_helpers.dart';

class CardSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const CardSection({
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
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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

class PlayerInfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const PlayerInfoCard({
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
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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

class InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const InfoLine({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: t.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: t.bodyMedium?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlagInfoLine extends StatelessWidget {
  final String label;
  final String countryCode;
  final String value;

  const FlagInfoLine({
    super.key,
    required this.label,
    required this.countryCode,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: t.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FlagAssetIcon(
                  countryCode: countryCode,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: t.bodyMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w700,
                    ),
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

class AttributeLine extends StatelessWidget {
  final String label;
  final int value;

  const AttributeLine({
    super.key,
    required this.label,
    required this.value,
  });

  Color _valueColor(int v) {
    if (v <= 4) return AppColors.danger;
    if (v <= 6) return AppColors.text;
    if (v <= 8) return AppColors.success;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final color = _valueColor(value);

    return Row(
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
          value.toString(),
          style: t.titleSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class Stars5 extends StatelessWidget {
  final int filled;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const Stars5({
    super.key,
    required this.filled,
    this.size = 18,
    this.activeColor,
    this.inactiveColor,
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
          size: size,
          color: on
              ? (activeColor ?? AppColors.star)
              : (inactiveColor ?? AppColors.textMuted),
        );
      }),
    );
  }
}

class MiniStatChip extends StatelessWidget {
  final String label;
  final int value;

  const MiniStatChip({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        '$label $value',
        style: t.labelSmall?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class FlagNameLine extends StatelessWidget {
  final String countryCode;
  final String name;
  final bool centered;
  final double flagSize;
  final TextStyle? textStyle;

  const FlagNameLine({
    super.key,
    required this.countryCode,
    required this.name,
    required this.centered,
    required this.flagSize,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          centered ? MainAxisAlignment.center : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FlagAssetIcon(
          countryCode: countryCode,
          size: flagSize,
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

class FlagAssetIcon extends StatelessWidget {
  final String countryCode;
  final double size;

  const FlagAssetIcon({
    super.key,
    required this.countryCode,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final path = flagAssetFromCode(countryCode);

    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          countryCode.trim().toUpperCase(),
          style: TextStyle(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w900,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class PlayerFaceAvatar extends StatelessWidget {
  final String assetPath;
  final double size;
  final double radius;

  const PlayerFaceAvatar({
    super.key,
    required this.assetPath,
    this.size = 68,
    this.radius = 20,
  });

  bool get _isValidPlayerFacePath {
    final path = assetPath.trim();

    if (path.isEmpty) return false;
    if (!path.startsWith('assets/faces/players/')) return false;
    if (!path.endsWith('.png')) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final path = assetPath.trim();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 1),
        child: _isValidPlayerFacePath
            ? Image.asset(
                path,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) => _FallbackIcon(size: size),
              )
            : _FallbackIcon(size: size),
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final double size;

  const _FallbackIcon({
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.person_rounded,
      size: size * 0.55,
      color: AppColors.textMuted,
    );
  }
}
