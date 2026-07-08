import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/models/staff_department.dart';

class DepartmentMessageTile extends StatelessWidget {
  final DepartmentMessage message;
  final VoidCallback onTap;

  const DepartmentMessageTile({
    super.key,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final style = _departmentMessageStyle(message);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: style.border,
            width: message.isPriority ? 1.35 : 1,
          ),
          boxShadow: message.isPriority ? AppColors.cardShadow : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DepartmentAvatar(
              message: message,
              style: style,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isPriority) ...[
                    _DepartmentStatusBadge(style: style),
                    const SizedBox(height: 7),
                  ],
                  Text(
                    '${message.departmentType.emoji} ${message.displayTitle}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.titleSmall?.copyWith(
                      color: style.titleColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    message.displayMetaLine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MiniTag(
                        label: message.displayTag,
                        color: style.accent,
                        background: style.softAccent,
                        border: style.border,
                      ),
                      _MiniTag(
                        label: message.departmentType.label,
                        color: AppColors.textSecondary,
                        background: AppColors.white.withOpacity(0.55),
                        border: AppColors.border,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    message.preview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodyMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: message.isPriority
                          ? FontWeight.w700
                          : FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color:
                  message.isPriority ? style.accent : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentVisualStyle {
  final String label;
  final Color background;
  final Color border;
  final Color accent;
  final Color softAccent;
  final Color titleColor;
  final IconData icon;

  const _DepartmentVisualStyle({
    required this.label,
    required this.background,
    required this.border,
    required this.accent,
    required this.softAccent,
    required this.titleColor,
    required this.icon,
  });
}

_DepartmentVisualStyle _departmentMessageStyle(DepartmentMessage message) {
  if (message.isNegative) {
    return const _DepartmentVisualStyle(
      label: 'ATENÇÃO',
      background: Color(0xFFFFF1F1),
      border: Color(0xFFF1CACA),
      accent: AppColors.danger,
      softAccent: Color(0xFFFFDDDD),
      titleColor: AppColors.danger,
      icon: Icons.warning_amber_rounded,
    );
  }

  if (message.isPositive) {
    return const _DepartmentVisualStyle(
      label: 'DESTAQUE',
      background: Color(0xFFF1F8F4),
      border: Color(0xFFCBE7D6),
      accent: AppColors.success,
      softAccent: Color(0xFFDDF4E7),
      titleColor: Color(0xFF237A4B),
      icon: Icons.star_rounded,
    );
  }

  if (message.isPriority) {
    return const _DepartmentVisualStyle(
      label: 'IMPORTANTE',
      background: Color(0xFFFFF6EE),
      border: Color(0xFFF4D7BB),
      accent: AppColors.accentDark,
      softAccent: AppColors.accentSoft,
      titleColor: AppColors.accentDark,
      icon: Icons.priority_high_rounded,
    );
  }

  return const _DepartmentVisualStyle(
    label: 'RELATÓRIO',
    background: AppColors.surfaceSoft,
    border: AppColors.border,
    accent: AppColors.primary,
    softAccent: AppColors.primarySoft,
    titleColor: AppColors.text,
    icon: Icons.badge_outlined,
  );
}

class _DepartmentStatusBadge extends StatelessWidget {
  final _DepartmentVisualStyle style;

  const _DepartmentStatusBadge({
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: style.softAccent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: style.accent.withOpacity(0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style.icon,
            color: style.accent,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            style.label,
            style: t.labelSmall?.copyWith(
              color: style.accent,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.45,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  final Color border;

  const _MiniTag({
    required this.label,
    required this.color,
    required this.background,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    final clean = label.trim();
    if (clean.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Text(
        clean,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
      ),
    );
  }
}

class _DepartmentAvatar extends StatelessWidget {
  final DepartmentMessage message;
  final _DepartmentVisualStyle style;

  const _DepartmentAvatar({
    required this.message,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final hasAsset = message.faceAsset.trim().isNotEmpty;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: message.isPriority ? style.accent : AppColors.border,
              width: message.isPriority ? 1.3 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: hasAsset
                ? Image.asset(
                    message.faceAsset,
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.center,
                    errorBuilder: (_, __, ___) => Center(
                      child: Text(
                        message.departmentType.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      message.departmentType.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
          ),
        ),
        if (message.isPriority)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: style.accent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                style.icon,
                color: AppColors.white,
                size: 10,
              ),
            ),
          ),
      ],
    );
  }
}
