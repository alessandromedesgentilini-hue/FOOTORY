import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:footory26/core/app_colors.dart';
import 'package:footory26/core/providers.dart';
import 'package:footory26/pages/messages/messages_category_page.dart';
import 'package:footory26/pages/messages/models/game_message.dart';
import 'package:footory26/pages/messages/models/message_news_models.dart';
import 'package:footory26/pages/messages/services/message_news_classifier.dart';
import 'package:footory26/pages/messages/widgets/inbox_header.dart';
import 'package:footory26/pages/messages/widgets/messages_summary_card.dart';
import 'package:footory26/services/world/game_state.dart';

enum _MessageCategoryKind {
  match,
  market,
  world,
  finance,
  training,
  season,
}

class MessagesPage extends ConsumerWidget {
  const MessagesPage({super.key});

  static const MessageNewsClassifier _classifier = MessageNewsClassifier();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState gs = ref.watch(gameStateProvider);

    final categorized = _splitNewsByStoredCategory(gs);

    final matchSummaries = categorized.matchSummaries;
    final market = categorized.market;
    final world = categorized.world;
    final finance = categorized.finance;
    final training = categorized.training;
    final season = categorized.season;
    final deptMessages = gs.departmentMessages;

    final unreadMatch = _unreadOf(
      total: matchSummaries.length,
      read: gs.readMatchNewsCount,
    );

    final unreadMarket = _unreadOf(
      total: market.length,
      read: gs.readMarketNewsCount,
    );

    final unreadWorld = _unreadOf(
      total: world.length,
      read: gs.readWorldNewsCount,
    );

    final unreadFinance = _unreadOf(
      total: finance.length,
      read: gs.readFinanceNewsCount,
    );

    final unreadTraining = _unreadOf(
      total: training.length,
      read: gs.readTrainingNewsCount,
    );

    final unreadSeason = _unreadOf(
      total: season.length,
      read: gs.readSeasonNewsCount,
    );

    final unreadDept = gs.unreadDepartmentMessagesCount;

    final unreadCategorized = MessageNewsBuckets(
      matchSummaries: matchSummaries.take(unreadMatch).toList(),
      market: market.take(unreadMarket).toList(),
      world: world.take(unreadWorld).toList(),
      finance: finance.take(unreadFinance).toList(),
      training: training.take(unreadTraining).toList(),
      season: season.take(unreadSeason).toList(),
    );

    final importantTotal = _countImportantMessages(
      unreadCategorized: unreadCategorized,
      unreadDeptMessages: deptMessages.take(unreadDept).toList(),
    );

    final totalAnalysis = market.length +
        world.length +
        finance.length +
        training.length +
        season.length;

    final unreadNewsTotal = unreadMatch +
        unreadMarket +
        unreadWorld +
        unreadFinance +
        unreadTraining +
        unreadSeason;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagens'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          InboxHeader(
            subtitle: _buildHeaderSubtitle(
              totalMatch: matchSummaries.length,
              totalAnalysis: totalAnalysis,
              totalDept: deptMessages.length,
              unreadNews: unreadNewsTotal,
              unreadDept: unreadDept,
              importantTotal: importantTotal,
            ),
            totalMatch: matchSummaries.length,
            totalAnalysis: totalAnalysis,
            totalDept: deptMessages.length,
          ),
          const SizedBox(height: 14),
          MessagesSummaryCard(
            unreadTotal: unreadNewsTotal + unreadDept,
            unreadMatch: unreadMatch,
            unreadMarket: unreadMarket + unreadWorld,
            unreadFinance: unreadFinance,
            unreadSeason: unreadSeason + unreadTraining,
            unreadDepartments: unreadDept,
            importantTotal: importantTotal,
          ),
          const SizedBox(height: 16),
          _MessageCategoryButton(
            title: 'Resumo da Partida',
            subtitle: 'Resumos, gols e acontecimentos.',
            icon: Icons.sports_soccer_rounded,
            count: matchSummaries.length,
            unreadCount: unreadMatch,
            isAlert: _hasCritical(unreadCategorized.matchSummaries),
            onTap: () {
              _openNewsCategory(
                context: context,
                ref: ref,
                kind: _MessageCategoryKind.match,
                title: 'Resumo da Partida',
                emptyText: 'Sem resumos de partida registrados.',
                entries: matchSummaries,
              );
            },
          ),
          const SizedBox(height: 12),
          _MessageCategoryButton(
            title: 'Mercado do Clube',
            subtitle: 'Propostas, transferências, scout e negociações.',
            icon: Icons.swap_horiz_rounded,
            count: market.length,
            unreadCount: unreadMarket,
            isAlert: _hasCritical(unreadCategorized.market),
            hasImportant: _hasImportant(unreadCategorized.market),
            onTap: () {
              _openNewsCategory(
                context: context,
                ref: ref,
                kind: _MessageCategoryKind.market,
                title: 'Mercado do Clube',
                emptyText: 'Sem movimentações do seu clube.',
                entries: market,
              );
            },
          ),
          const SizedBox(height: 12),
          _MessageCategoryButton(
            title: 'Notícias do Mundo',
            subtitle: 'Transferências e acontecimentos externos.',
            icon: Icons.public_rounded,
            count: world.length,
            unreadCount: unreadWorld,
            isAlert: _hasCritical(unreadCategorized.world),
            hasImportant: _hasImportant(unreadCategorized.world),
            onTap: () {
              _openNewsCategory(
                context: context,
                ref: ref,
                kind: _MessageCategoryKind.world,
                title: 'Notícias do Mundo',
                emptyText: 'Sem movimentações externas registradas.',
                entries: world,
              );
            },
          ),
          const SizedBox(height: 12),
          _MessageCategoryButton(
            title: 'Financeiro',
            subtitle: 'Receitas, custos e saúde do clube.',
            icon: Icons.account_balance_wallet_rounded,
            count: finance.length,
            unreadCount: unreadFinance,
            isAlert: _hasCritical(unreadCategorized.finance),
            hasImportant: _hasImportant(unreadCategorized.finance),
            onTap: () {
              _openNewsCategory(
                context: context,
                ref: ref,
                kind: _MessageCategoryKind.finance,
                title: 'Financeiro',
                emptyText: 'Sem alertas financeiros registrados.',
                entries: finance,
              );
            },
          ),
          const SizedBox(height: 12),
          _MessageCategoryButton(
            title: 'CT / Evolução',
            subtitle: 'Treinamentos e evolução.',
            icon: Icons.fitness_center_rounded,
            count: training.length,
            unreadCount: unreadTraining,
            isAlert: _hasCritical(unreadCategorized.training),
            hasImportant: _hasImportant(unreadCategorized.training),
            onTap: () {
              _openNewsCategory(
                context: context,
                ref: ref,
                kind: _MessageCategoryKind.training,
                title: 'CT / Evolução',
                emptyText: 'Sem relatórios do CT registrados.',
                entries: training,
              );
            },
          ),
          const SizedBox(height: 12),
          _MessageCategoryButton(
            title: 'Temporada, Competições e Diretoria',
            subtitle: 'Campanha, copas, legado e comunicados.',
            icon: Icons.insights_rounded,
            count: season.length,
            unreadCount: unreadSeason,
            isAlert: _hasCritical(unreadCategorized.season),
            hasImportant: _hasImportant(unreadCategorized.season),
            onTap: () {
              _openNewsCategory(
                context: context,
                ref: ref,
                kind: _MessageCategoryKind.season,
                title: 'Temporada, Competições e Diretoria',
                emptyText: 'Sem comunicados registrados.',
                entries: season,
              );
            },
          ),
          const SizedBox(height: 12),
          _MessageCategoryButton(
            title: 'Departamentos',
            subtitle: 'Atualizações internas.',
            icon: Icons.badge_outlined,
            count: deptMessages.length,
            unreadCount: unreadDept,
            isAlert: deptMessages.take(unreadDept).any((m) => m.isNegative),
            hasImportant:
                deptMessages.take(unreadDept).any((m) => m.isPriority),
            onTap: () {
              ref.read(gameStateProvider).markDepartmentMessagesAsRead();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MessagesCategoryPage(
                    title: 'Departamentos',
                    emptyText: 'Sem mensagens internas.',
                    departmentMessages: deptMessages,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  static MessageNewsBuckets _splitNewsByStoredCategory(GameState gs) {
    final matchSummaries = <MessageNewsEntry>[];
    final market = <MessageNewsEntry>[];
    final world = <MessageNewsEntry>[];
    final finance = <MessageNewsEntry>[];
    final training = <MessageNewsEntry>[];
    final season = <MessageNewsEntry>[];

    for (final raw in gs.newsFeed) {
      final text = raw.trim();
      if (text.isEmpty) continue;

      final category = gs.newsCategoryOf(text);
      final entry = _buildEntryForCategory(
        text: text,
        category: category,
      );

      switch (_bucketKindForCategory(category)) {
        case _MessageCategoryKind.match:
          matchSummaries.add(entry);
          break;
        case _MessageCategoryKind.market:
          market.add(entry);
          break;
        case _MessageCategoryKind.world:
          world.add(entry);
          break;
        case _MessageCategoryKind.finance:
          finance.add(entry);
          break;
        case _MessageCategoryKind.training:
          training.add(entry);
          break;
        case _MessageCategoryKind.season:
          season.add(entry);
          break;
      }
    }

    return MessageNewsBuckets(
      matchSummaries: matchSummaries,
      market: market,
      world: world,
      finance: finance,
      training: training,
      season: season,
    );
  }

  static _MessageCategoryKind _bucketKindForCategory(
    GameMessageCategory category,
  ) {
    switch (category) {
      case GameMessageCategory.match:
        return _MessageCategoryKind.match;

      case GameMessageCategory.market:
      case GameMessageCategory.transfer:
      case GameMessageCategory.scout:
        return _MessageCategoryKind.market;

      case GameMessageCategory.world:
        return _MessageCategoryKind.world;

      case GameMessageCategory.finance:
        return _MessageCategoryKind.finance;

      case GameMessageCategory.training:
        return _MessageCategoryKind.training;

      case GameMessageCategory.season:
      case GameMessageCategory.competition:
      case GameMessageCategory.legacy:
      case GameMessageCategory.board:
      case GameMessageCategory.club:
      case GameMessageCategory.system:
      case GameMessageCategory.department:
        return _MessageCategoryKind.season;
    }
  }

  static MessageNewsEntry _buildEntryForCategory({
    required String text,
    required GameMessageCategory category,
  }) {
    final fallback = _classifier.buildEntry(text);
    final priority = _classifier.classifyPriority(text);

    switch (category) {
      case GameMessageCategory.match:
        return MessageNewsEntry(
          title: 'Resumo da Partida',
          tagLabel: 'Partida',
          text: text,
          tone: MessageNewsTone.match,
          priority: priority,
        );

      case GameMessageCategory.market:
        return MessageNewsEntry(
          title: 'Mercado do Clube',
          tagLabel: 'Mercado',
          text: text,
          tone: MessageNewsTone.market,
          priority: priority,
        );

      case GameMessageCategory.transfer:
        return MessageNewsEntry(
          title: 'Transferências',
          tagLabel: 'Transferência',
          text: text,
          tone: MessageNewsTone.market,
          priority: priority,
        );

      case GameMessageCategory.scout:
        return MessageNewsEntry(
          title: 'Scout',
          tagLabel: 'Scout',
          text: text,
          tone: MessageNewsTone.market,
          priority: priority,
        );

      case GameMessageCategory.world:
        return MessageNewsEntry(
          title: 'Notícias do Mundo',
          tagLabel: 'Mundo',
          text: text,
          tone: MessageNewsTone.world,
          priority: priority,
        );

      case GameMessageCategory.finance:
        final isWarning = _classifier.isWarningFinanceMessage(text);

        return MessageNewsEntry(
          title: isWarning ? 'Alerta Financeiro' : 'Financeiro',
          tagLabel: 'Financeiro',
          text: text,
          tone: isWarning ? MessageNewsTone.warning : MessageNewsTone.finance,
          priority: isWarning ? MessageNewsPriority.critical : priority,
        );

      case GameMessageCategory.training:
        return MessageNewsEntry(
          title: 'CT / Evolução',
          tagLabel: 'CT',
          text: text,
          tone: MessageNewsTone.training,
          priority: priority,
        );

      case GameMessageCategory.competition:
        return MessageNewsEntry(
          title: 'Competições',
          tagLabel: 'Competição',
          text: text,
          tone: MessageNewsTone.season,
          priority: priority,
        );

      case GameMessageCategory.legacy:
        return MessageNewsEntry(
          title: 'Legado',
          tagLabel: 'Legado',
          text: text,
          tone: MessageNewsTone.analysis,
          priority: priority,
        );

      case GameMessageCategory.board:
        return MessageNewsEntry(
          title: 'Diretoria',
          tagLabel: 'Diretoria',
          text: text,
          tone: MessageNewsTone.season,
          priority: priority,
        );

      case GameMessageCategory.club:
        return MessageNewsEntry(
          title: 'Clube',
          tagLabel: 'Clube',
          text: text,
          tone: MessageNewsTone.analysis,
          priority: priority,
        );

      case GameMessageCategory.system:
        return MessageNewsEntry(
          title: 'Sistema',
          tagLabel: 'Sistema',
          text: text,
          tone: MessageNewsTone.warning,
          priority: MessageNewsPriority.critical,
        );

      case GameMessageCategory.season:
      case GameMessageCategory.department:
        return MessageNewsEntry(
          title: fallback.title,
          tagLabel: fallback.tagLabel,
          text: text,
          tone: fallback.tone,
          priority: priority,
        );
    }
  }

  static int _unreadOf({
    required int total,
    required int read,
  }) {
    final value = total - read;
    if (value <= 0) return 0;
    return value;
  }

  static void _openNewsCategory({
    required BuildContext context,
    required WidgetRef ref,
    required _MessageCategoryKind kind,
    required String title,
    required String emptyText,
    required List<MessageNewsEntry> entries,
  }) {
    final gs = ref.read(gameStateProvider);

    switch (kind) {
      case _MessageCategoryKind.match:
        gs.markMatchNewsAsRead(entries.length);
        break;
      case _MessageCategoryKind.market:
        gs.markMarketNewsAsRead(entries.length);
        break;
      case _MessageCategoryKind.world:
        gs.markWorldNewsAsRead(entries.length);
        break;
      case _MessageCategoryKind.finance:
        gs.markFinanceNewsAsRead(entries.length);
        break;
      case _MessageCategoryKind.training:
        gs.markTrainingNewsAsRead(entries.length);
        break;
      case _MessageCategoryKind.season:
        gs.markSeasonNewsAsRead(entries.length);
        break;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MessagesCategoryPage(
          title: title,
          emptyText: emptyText,
          newsEntries: entries,
        ),
      ),
    );
  }

  static bool _hasImportant(List<MessageNewsEntry> entries) {
    return entries.any((entry) => entry.isImportant);
  }

  static bool _hasCritical(List<MessageNewsEntry> entries) {
    return entries.any((entry) => entry.isCritical);
  }

  static int _countImportantMessages({
    required MessageNewsBuckets unreadCategorized,
    required List<dynamic> unreadDeptMessages,
  }) {
    var total = 0;

    for (final entry in [
      ...unreadCategorized.matchSummaries,
      ...unreadCategorized.market,
      ...unreadCategorized.world,
      ...unreadCategorized.finance,
      ...unreadCategorized.training,
      ...unreadCategorized.season,
    ]) {
      if (entry.isImportant) {
        total++;
      }
    }

    for (final message in unreadDeptMessages) {
      try {
        if (message.isPriority == true) {
          total++;
        }
      } catch (_) {}
    }

    return total;
  }

  static String _buildHeaderSubtitle({
    required int totalMatch,
    required int totalAnalysis,
    required int totalDept,
    required int unreadNews,
    required int unreadDept,
    required int importantTotal,
  }) {
    final unreadTotal = unreadNews + unreadDept;
    final total = totalMatch + totalAnalysis + totalDept;

    if (total <= 0) return 'Sem registros no momento.';
    if (unreadTotal <= 0) return '$total registro(s) no histórico.';

    if (importantTotal > 0) {
      return '$unreadTotal nova(s) mensagem(ns), $importantTotal pedem atenção.';
    }

    return '$unreadTotal nova(s) mensagem(ns) esperando leitura.';
  }
}

class _MessageCategoryButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final int count;
  final int unreadCount;
  final bool isAlert;
  final bool hasImportant;
  final VoidCallback onTap;

  const _MessageCategoryButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.count,
    required this.onTap,
    required this.unreadCount,
    this.isAlert = false,
    this.hasImportant = false,
  });

  bool get hasUnread => unreadCount > 0;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final accent = isAlert
        ? AppColors.danger
        : hasImportant
            ? AppColors.accentDark
            : AppColors.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasUnread ? AppColors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: hasUnread ? accent.withOpacity(0.38) : AppColors.border,
            width: hasUnread ? 1.4 : 1,
          ),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: hasUnread
                        ? accent.withOpacity(0.12)
                        : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: hasUnread ? accent : AppColors.primary,
                    size: 24,
                  ),
                ),
                if (hasUnread)
                  Positioned(
                    right: -3,
                    top: -3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: AppColors.white,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: t.labelSmall?.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: t.titleMedium?.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Text(
                          isAlert
                              ? 'CRÍTICO'
                              : hasImportant
                                  ? 'IMPORTANTE'
                                  : unreadCount == 1
                                      ? 'NOVA'
                                      : 'NOVAS',
                          style: t.labelSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: t.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '$count',
                style: t.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
