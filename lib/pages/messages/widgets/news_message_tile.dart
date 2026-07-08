import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/pages/messages/models/message_news_models.dart';

class NewsMessageTile extends StatelessWidget {
  final MessageNewsEntry entry;
  final VoidCallback onTap;

  const NewsMessageTile({
    super.key,
    required this.entry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final tone = toneStyle(entry.tone);
    final priority = priorityStyle(entry.priority);

    final hasPriorityBadge = entry.priority == MessageNewsPriority.high ||
        entry.priority == MessageNewsPriority.critical;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: entry.isCritical ? const Color(0xFFFFF1F1) : tone.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: hasPriorityBadge ? priority.color : tone.border,
            width: hasPriorityBadge ? 1.35 : 1,
          ),
          boxShadow: hasPriorityBadge ? AppColors.cardShadow : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: hasPriorityBadge
                        ? priority.softColor
                        : tone.iconBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasPriorityBadge ? priority.icon : tone.icon,
                    size: 20,
                    color: hasPriorityBadge ? priority.color : tone.iconColor,
                  ),
                ),
                if (hasPriorityBadge)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: Container(
                      width: 13,
                      height: 13,
                      decoration: BoxDecoration(
                        color: priority.color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasPriorityBadge) ...[
                    _PriorityBadge(style: priority),
                    const SizedBox(height: 7),
                  ],
                  Text(
                    entry.title,
                    style: t.labelLarge?.copyWith(
                      color:
                          hasPriorityBadge ? priority.color : tone.titleColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _TagChip(
                        label: entry.tagLabel,
                        textColor: tone.tagColor,
                        background: AppColors.white.withOpacity(0.56),
                        border: tone.border,
                      ),
                      if (!hasPriorityBadge &&
                          entry.priority == MessageNewsPriority.low)
                        _TagChip(
                          label: entry.priorityLabel,
                          textColor: AppColors.textSecondary,
                          background: AppColors.surfaceSoft,
                          border: AppColors.border,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.text,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodyMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight:
                          hasPriorityBadge ? FontWeight.w700 : FontWeight.w600,
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
                  hasPriorityBadge ? priority.color : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityVisualStyle {
  final String label;
  final Color color;
  final Color softColor;
  final IconData icon;

  const _PriorityVisualStyle({
    required this.label,
    required this.color,
    required this.softColor,
    required this.icon,
  });
}

_PriorityVisualStyle priorityStyle(MessageNewsPriority priority) {
  switch (priority) {
    case MessageNewsPriority.critical:
      return const _PriorityVisualStyle(
        label: 'CRÍTICO',
        color: AppColors.danger,
        softColor: Color(0xFFFFDDDD),
        icon: Icons.warning_amber_rounded,
      );

    case MessageNewsPriority.high:
      return const _PriorityVisualStyle(
        label: 'IMPORTANTE',
        color: AppColors.accentDark,
        softColor: AppColors.accentSoft,
        icon: Icons.priority_high_rounded,
      );

    case MessageNewsPriority.normal:
      return const _PriorityVisualStyle(
        label: 'ATUALIZAÇÃO',
        color: AppColors.primary,
        softColor: AppColors.primarySoft,
        icon: Icons.info_outline_rounded,
      );

    case MessageNewsPriority.low:
      return const _PriorityVisualStyle(
        label: 'INFORMATIVO',
        color: AppColors.textSecondary,
        softColor: AppColors.surfaceSoft,
        icon: Icons.notes_rounded,
      );
  }
}

class _PriorityBadge extends StatelessWidget {
  final _PriorityVisualStyle style;

  const _PriorityBadge({
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: style.softColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: style.color.withOpacity(0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style.icon,
            color: style.color,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            style.label,
            style: t.labelSmall?.copyWith(
              color: style.color,
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

class _TagChip extends StatelessWidget {
  final String label;
  final Color textColor;
  final Color background;
  final Color border;

  const _TagChip({
    required this.label,
    required this.textColor,
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
              color: textColor,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
      ),
    );
  }
}

/// 🎨 ESTILOS POR TIPO DE NOTÍCIA
MessageNewsToneStyle toneStyle(MessageNewsTone tone) {
  switch (tone) {
    case MessageNewsTone.match:
      return const MessageNewsToneStyle(
        background: AppColors.surfaceSoft,
        border: AppColors.border,
        iconBackground: AppColors.accentSoft,
        iconColor: AppColors.accentDark,
        titleColor: AppColors.primary,
        tagColor: AppColors.textSecondary,
        icon: Icons.sports_soccer_rounded,
      );

    case MessageNewsTone.market:
      return const MessageNewsToneStyle(
        background: Color(0xFFFFF6EE),
        border: Color(0xFFF4D7BB),
        iconBackground: Color(0xFFFFE8D2),
        iconColor: Color(0xFFC96A1B),
        titleColor: Color(0xFFC96A1B),
        tagColor: Color(0xFFA05A1F),
        icon: Icons.swap_horiz_rounded,
      );

    case MessageNewsTone.world:
      return const MessageNewsToneStyle(
        background: Color(0xFFF1F8F6),
        border: Color(0xFFCFE7DF),
        iconBackground: Color(0xFFDFF3ED),
        iconColor: Color(0xFF247C66),
        titleColor: Color(0xFF247C66),
        tagColor: Color(0xFF2C6F60),
        icon: Icons.public_rounded,
      );

    case MessageNewsTone.finance:
      return const MessageNewsToneStyle(
        background: Color(0xFFFFFAEE),
        border: Color(0xFFF1DEB7),
        iconBackground: Color(0xFFFFF0C7),
        iconColor: Color(0xFFB87912),
        titleColor: Color(0xFF9C650F),
        tagColor: Color(0xFF9C650F),
        icon: Icons.account_balance_wallet_rounded,
      );

    case MessageNewsTone.warning:
      return const MessageNewsToneStyle(
        background: Color(0xFFFFF1F1),
        border: Color(0xFFF1CACA),
        iconBackground: Color(0xFFFFDDDD),
        iconColor: Color(0xFFC44747),
        titleColor: Color(0xFFC44747),
        tagColor: Color(0xFFA54545),
        icon: Icons.warning_amber_rounded,
      );

    case MessageNewsTone.training:
      return const MessageNewsToneStyle(
        background: Color(0xFFF3F8FF),
        border: Color(0xFFD6E5FF),
        iconBackground: Color(0xFFE4EEFF),
        iconColor: Color(0xFF4B78D1),
        titleColor: Color(0xFF4B78D1),
        tagColor: Color(0xFF5677B8),
        icon: Icons.fitness_center_rounded,
      );

    case MessageNewsTone.season:
      return const MessageNewsToneStyle(
        background: Color(0xFFF6F4FF),
        border: Color(0xFFDCD6F7),
        iconBackground: Color(0xFFEAE5FF),
        iconColor: Color(0xFF6750A4),
        titleColor: Color(0xFF51408A),
        tagColor: Color(0xFF6750A4),
        icon: Icons.flag_rounded,
      );

    case MessageNewsTone.analysis:
      return const MessageNewsToneStyle(
        background: AppColors.surfaceSoft,
        border: AppColors.border,
        iconBackground: AppColors.primarySoft,
        iconColor: AppColors.primary,
        titleColor: AppColors.text,
        tagColor: AppColors.primary,
        icon: Icons.insights_rounded,
      );
  }
}
