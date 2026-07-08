import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/models/staff_department.dart';
import 'package:footory26/pages/messages/message_detail_page.dart';
import 'package:footory26/pages/messages/models/message_news_models.dart';
import 'package:footory26/pages/messages/widgets/department_message_tile.dart';
import 'package:footory26/pages/messages/widgets/empty_box.dart';
import 'package:footory26/pages/messages/widgets/news_message_tile.dart';

class MessagesCategoryPage extends StatelessWidget {
  final String title;
  final String emptyText;
  final List<MessageNewsEntry> newsEntries;
  final List<DepartmentMessage> departmentMessages;

  const MessagesCategoryPage({
    super.key,
    required this.title,
    required this.emptyText,
    this.newsEntries = const <MessageNewsEntry>[],
    this.departmentMessages = const <DepartmentMessage>[],
  });

  bool get _isDepartmentPage => departmentMessages.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final hasContent = newsEntries.isNotEmpty || departmentMessages.isNotEmpty;

    final sortedNews = _sortNewsEntries(newsEntries);
    final sortedDepartments = _sortDepartmentMessages(departmentMessages);

    final criticalNews = sortedNews.where((e) => e.isCritical).toList();
    final importantNews =
        sortedNews.where((e) => e.isImportant && !e.isCritical).toList();
    final normalNews = sortedNews.where((e) => !e.isImportant).toList();

    final priorityDepartments =
        sortedDepartments.where((m) => m.isPriority).toList();
    final normalDepartments =
        sortedDepartments.where((m) => !m.isPriority).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          if (!hasContent)
            EmptyBox(text: emptyText)
          else if (_isDepartmentPage) ...[
            if (priorityDepartments.isNotEmpty) ...[
              const _SectionHeader(
                title: 'Mensagens em destaque',
                icon: Icons.priority_high_rounded,
                color: AppColors.accentDark,
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < priorityDepartments.length; i++) ...[
                DepartmentMessageTile(
                  message: priorityDepartments[i],
                  onTap: () {
                    _openDepartmentMessageDetail(
                      context: context,
                      message: priorityDepartments[i],
                    );
                  },
                ),
                if (i != priorityDepartments.length - 1)
                  const SizedBox(height: 12),
              ],
              if (normalDepartments.isNotEmpty) const SizedBox(height: 18),
            ],
            if (normalDepartments.isNotEmpty) ...[
              _SectionHeader(
                title: priorityDepartments.isEmpty
                    ? 'Mensagens'
                    : 'Histórico da categoria',
                icon: Icons.inbox_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < normalDepartments.length; i++) ...[
                DepartmentMessageTile(
                  message: normalDepartments[i],
                  onTap: () {
                    _openDepartmentMessageDetail(
                      context: context,
                      message: normalDepartments[i],
                    );
                  },
                ),
                if (i != normalDepartments.length - 1)
                  const SizedBox(height: 12),
              ],
            ],
          ] else ...[
            if (criticalNews.isNotEmpty) ...[
              const _SectionHeader(
                title: 'Crítico',
                icon: Icons.warning_amber_rounded,
                color: AppColors.danger,
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < criticalNews.length; i++) ...[
                NewsMessageTile(
                  entry: criticalNews[i],
                  onTap: () {
                    _openNewsDetail(
                      context: context,
                      entry: criticalNews[i],
                    );
                  },
                ),
                if (i != criticalNews.length - 1) const SizedBox(height: 12),
              ],
              if (importantNews.isNotEmpty || normalNews.isNotEmpty)
                const SizedBox(height: 18),
            ],
            if (importantNews.isNotEmpty) ...[
              const _SectionHeader(
                title: 'Importante',
                icon: Icons.priority_high_rounded,
                color: AppColors.accentDark,
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < importantNews.length; i++) ...[
                NewsMessageTile(
                  entry: importantNews[i],
                  onTap: () {
                    _openNewsDetail(
                      context: context,
                      entry: importantNews[i],
                    );
                  },
                ),
                if (i != importantNews.length - 1) const SizedBox(height: 12),
              ],
              if (normalNews.isNotEmpty) const SizedBox(height: 18),
            ],
            if (normalNews.isNotEmpty) ...[
              _SectionHeader(
                title: criticalNews.isEmpty && importantNews.isEmpty
                    ? 'Mensagens'
                    : 'Histórico da categoria',
                icon: Icons.inbox_rounded,
                color: AppColors.primary,
              ),
              const SizedBox(height: 10),
              for (int i = 0; i < normalNews.length; i++) ...[
                NewsMessageTile(
                  entry: normalNews[i],
                  onTap: () {
                    _openNewsDetail(
                      context: context,
                      entry: normalNews[i],
                    );
                  },
                ),
                if (i != normalNews.length - 1) const SizedBox(height: 12),
              ],
            ],
          ],
        ],
      ),
    );
  }

  List<MessageNewsEntry> _sortNewsEntries(List<MessageNewsEntry> entries) {
    final copy = List<MessageNewsEntry>.from(entries);

    copy.sort((a, b) {
      final pa = _priorityRank(a.priority);
      final pb = _priorityRank(b.priority);

      if (pa != pb) return pb.compareTo(pa);

      return 0;
    });

    return copy;
  }

  List<DepartmentMessage> _sortDepartmentMessages(
    List<DepartmentMessage> messages,
  ) {
    final copy = List<DepartmentMessage>.from(messages);

    copy.sort((a, b) {
      final pa = _departmentRank(a);
      final pb = _departmentRank(b);

      if (pa != pb) return pb.compareTo(pa);

      return 0;
    });

    return copy;
  }

  int _priorityRank(MessageNewsPriority priority) {
    switch (priority) {
      case MessageNewsPriority.critical:
        return 4;
      case MessageNewsPriority.high:
        return 3;
      case MessageNewsPriority.normal:
        return 2;
      case MessageNewsPriority.low:
        return 1;
    }
  }

  int _departmentRank(DepartmentMessage message) {
    if (message.isNegative) return 4;
    if (message.isPriority) return 3;
    if (message.isPositive) return 2;
    return 1;
  }

  void _openNewsDetail({
    required BuildContext context,
    required MessageNewsEntry entry,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessageDetailPage(
          title: entry.title,
          subtitle: entry.priorityLabel,
          body: entry.text,
          icon: entry.isCritical
              ? Icons.warning_amber_rounded
              : entry.isImportant
                  ? Icons.priority_high_rounded
                  : Icons.campaign_outlined,
          tag: entry.tagLabel,
        ),
      ),
    );
  }

  void _openDepartmentMessageDetail({
    required BuildContext context,
    required DepartmentMessage message,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessageDetailPage(
          title: message.displayTitle,
          subtitle: message.displaySubtitle,
          body: message.text,
          icon: message.isNegative
              ? Icons.warning_amber_rounded
              : message.isPriority
                  ? Icons.priority_high_rounded
                  : Icons.badge_outlined,
          tag: message.displayTag,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            title,
            style: t.titleSmall?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
