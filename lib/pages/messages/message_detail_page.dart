import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';

class MessageDetailPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String body;
  final IconData icon;
  final String? tag;

  const MessageDetailPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.icon,
    this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cleanTitle = title.trim().isEmpty ? 'Mensagem' : title.trim();
    final cleanSubtitle =
        subtitle.trim().isEmpty ? 'Caixa de Entrada' : subtitle.trim();
    final cleanBody =
        body.trim().isEmpty ? 'Mensagem sem conteúdo.' : body.trim();
    final cleanTag = tag?.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mensagem'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cleanTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.text,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cleanSubtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      if (cleanTag != null && cleanTag.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _MessageTagChip(label: cleanTag),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border),
              boxShadow: AppColors.cardShadow,
            ),
            child: Text(
              cleanBody,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.text,
                fontWeight: FontWeight.w500,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageTagChip extends StatelessWidget {
  final String label;

  const _MessageTagChip({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}
