import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';

class HubMessagesPreview extends StatelessWidget {
  final int unreadNewsCount;
  final int unreadDepartmentMessagesCount;
  final int totalNewsCount;
  final int totalDepartmentMessagesCount;
  final VoidCallback onOpenMessages;

  const HubMessagesPreview({
    super.key,
    required this.unreadNewsCount,
    required this.unreadDepartmentMessagesCount,
    required this.totalNewsCount,
    required this.totalDepartmentMessagesCount,
    required this.onOpenMessages,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final unreadTotal = unreadNewsCount + unreadDepartmentMessagesCount;
    final totalStored = totalNewsCount + totalDepartmentMessagesCount;

    final latest = _buildPreviewMessages(
      unreadNewsCount: unreadNewsCount,
      unreadDepartmentMessagesCount: unreadDepartmentMessagesCount,
      totalNewsCount: totalNewsCount,
      totalDepartmentMessagesCount: totalDepartmentMessagesCount,
    );

    final headerTitle = _buildHeaderTitle(
      unreadTotal: unreadTotal,
      totalStored: totalStored,
    );

    final headerSubtitle = _buildHeaderSubtitle(
      unreadNewsCount: unreadNewsCount,
      unreadDepartmentMessagesCount: unreadDepartmentMessagesCount,
      totalStored: totalStored,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),

                  // 🔴 BADGE REAL (NOVO)
                  if (unreadTotal > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Text(
                          unreadTotal > 99 ? '99+' : '$unreadTotal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
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
                    Text(
                      headerTitle,
                      style: t.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      headerSubtitle,
                      style: t.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),

              // 🟡 BADGE LATERAL (AGORA MAIS SEMÂNTICO)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: unreadTotal > 0
                      ? Colors.red.withOpacity(0.1)
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: unreadTotal > 0
                        ? Colors.red.withOpacity(0.4)
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  unreadTotal > 0 ? '$unreadTotal' : '0',
                  style: t.labelLarge?.copyWith(
                    color:
                        unreadTotal > 0 ? Colors.red : AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (latest.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.border,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      totalStored <= 0
                          ? 'Ainda não há mensagens na caixa de entrada. Quando a temporada começar a esquentar, as atualizações vão aparecer aqui.'
                          : 'Caixa limpa. Você já leu todas as mensagens recentes e o histórico segue salvo na caixa de entrada.',
                      style: t.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Column(
              children: List.generate(latest.length, (index) {
                final msg = latest[index];
                final isFirst = index == 0;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == latest.length - 1 ? 0 : 8,
                  ),
                  child: _MessagePreviewTile(
                    message: msg,
                    highlight: isFirst,
                  ),
                );
              }),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onOpenMessages,
              icon: const Icon(Icons.mark_email_read_outlined),
              label: Text(
                unreadTotal > 0
                    ? 'Abrir Caixa de Entrada'
                    : 'Ver Histórico de Mensagens',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _buildHeaderTitle({
    required int unreadTotal,
    required int totalStored,
  }) {
    if (unreadTotal <= 0) {
      if (totalStored <= 0) {
        return 'Caixa de entrada vazia';
      }
      return 'Caixa limpa';
    }

    if (unreadTotal == 1) {
      return '1 nova mensagem';
    }

    return '$unreadTotal novas mensagens';
  }

  String _buildHeaderSubtitle({
    required int unreadNewsCount,
    required int unreadDepartmentMessagesCount,
    required int totalStored,
  }) {
    final unreadTotal = unreadNewsCount + unreadDepartmentMessagesCount;

    if (unreadTotal <= 0) {
      if (totalStored <= 0) {
        return 'Sem novidades da diretoria, da temporada ou dos departamentos.';
      }
      return 'Nenhuma mensagem nova no momento.';
    }

    if (unreadNewsCount > 0 && unreadDepartmentMessagesCount > 0) {
      return '$unreadNewsCount notícia(s) nova(s) e $unreadDepartmentMessagesCount aviso(s) interno(s).';
    }

    if (unreadNewsCount > 0) {
      return '$unreadNewsCount notícia(s) nova(s) sobre a temporada e o clube.';
    }

    return '$unreadDepartmentMessagesCount aviso(s) novo(s) enviados pelos departamentos.';
  }

  List<String> _buildPreviewMessages({
    required int unreadNewsCount,
    required int unreadDepartmentMessagesCount,
    required int totalNewsCount,
    required int totalDepartmentMessagesCount,
  }) {
    final items = <String>[];

    if (unreadNewsCount > 0) {
      items.add(
        unreadNewsCount == 1
            ? '1 notícia nova da temporada chegou à caixa de entrada.'
            : '$unreadNewsCount notícias novas da temporada aguardam leitura.',
      );
    }

    if (unreadDepartmentMessagesCount > 0) {
      items.add(
        unreadDepartmentMessagesCount == 1
            ? '1 atualização interna dos departamentos foi registrada.'
            : '$unreadDepartmentMessagesCount atualizações internas aguardam leitura.',
      );
    }

    if (items.length < 3 && totalNewsCount > 0) {
      items.add('Histórico salvo: $totalNewsCount notícia(s) da temporada.');
    }

    if (items.length < 3 && totalDepartmentMessagesCount > 0) {
      items.add(
          'Histórico salvo: $totalDepartmentMessagesCount aviso(s) dos departamentos.');
    }

    return items.take(3).toList();
  }
}

class _MessagePreviewTile extends StatelessWidget {
  final String message;
  final bool highlight;

  const _MessagePreviewTile({
    required this.message,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight ? AppColors.accent : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(
              color: highlight ? AppColors.accent : AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: highlight ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: t.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
