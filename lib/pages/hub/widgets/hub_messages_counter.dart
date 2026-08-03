import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';

class HubMessagesCounter extends StatelessWidget {
  final int unreadNews;
  final int unreadDepartment;
  final VoidCallback onOpenMessages;

  const HubMessagesCounter({
    super.key,
    required this.unreadNews,
    required this.unreadDepartment,
    required this.onOpenMessages,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final safeUnreadNews = unreadNews < 0 ? 0 : unreadNews;
    final safeUnreadDepartment = unreadDepartment < 0 ? 0 : unreadDepartment;

    final totalUnread = safeUnreadNews + safeUnreadDepartment;
    final hasUnread = totalUnread > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onOpenMessages,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 11, 10),
          decoration: BoxDecoration(
            color: hasUnread
                ? AppColors.primarySoft.withOpacity(0.58)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hasUnread
                  ? AppColors.primary.withOpacity(0.20)
                  : AppColors.border,
            ),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              _MessagesIcon(
                unreadCount: totalUnread,
                hasUnread: hasUnread,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mainLabel(totalUnread),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _detailLabel(
                        unreadNews: safeUnreadNews,
                        unreadDepartment: safeUnreadDepartment,
                        hasUnread: hasUnread,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.72),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border,
                  ),
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _mainLabel(int totalUnread) {
    if (totalUnread <= 0) {
      return 'Central de mensagens';
    }

    if (totalUnread == 1) {
      return '1 mensagem pendente';
    }

    return '$totalUnread mensagens pendentes';
  }

  String _detailLabel({
    required int unreadNews,
    required int unreadDepartment,
    required bool hasUnread,
  }) {
    if (!hasUnread) {
      return 'Nenhuma atualização aguardando leitura';
    }

    final parts = <String>[];

    if (unreadDepartment > 0) {
      parts.add(
        '$unreadDepartment ${unreadDepartment == 1 ? 'departamento' : 'departamentos'}',
      );
    }

    if (unreadNews > 0) {
      parts.add(
        '$unreadNews ${unreadNews == 1 ? 'notícia' : 'notícias'}',
      );
    }

    return parts.join(' • ');
  }
}

class _MessagesIcon extends StatelessWidget {
  final int unreadCount;
  final bool hasUnread;

  const _MessagesIcon({
    required this.unreadCount,
    required this.hasUnread,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: hasUnread ? AppColors.primary : AppColors.primarySoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                hasUnread
                    ? Icons.mark_email_unread_rounded
                    : Icons.mail_outline_rounded,
                color: hasUnread ? AppColors.white : AppColors.primary,
                size: 23,
              ),
            ),
          ),
          if (hasUnread)
            Positioned(
              right: -5,
              top: -5,
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 21,
                  minHeight: 21,
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.white,
                    width: 2,
                  ),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
