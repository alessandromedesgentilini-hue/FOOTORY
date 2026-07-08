import 'package:flutter/material.dart';
import 'package:footory26/models/staff_department.dart';

class DepartmentMessageCard extends StatelessWidget {
  final DepartmentMessage message;

  const DepartmentMessageCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final fallbackLetter = _buildFallbackLetter(message.authorName);
    final authorName = message.authorName.trim().isEmpty
        ? 'Departamento'
        : message.authorName.trim();
    final authorRole = message.authorRole.trim().isEmpty
        ? 'Equipe interna'
        : message.authorRole.trim();

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${message.departmentType.emoji} ${message.departmentType.label.toUpperCase()}',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message.title.trim().isEmpty
                  ? 'Atualização do departamento'
                  : message.title.trim(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StaffAvatar(
                  assetPath: message.faceAsset,
                  fallbackLetter: fallbackLetter,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authorName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        authorRole,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color
                              ?.withOpacity(0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              message.text.trim().isEmpty
                  ? 'Nenhuma mensagem disponível.'
                  : message.text.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  String _buildFallbackLetter(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed.characters.first.toUpperCase();
  }
}

class _StaffAvatar extends StatelessWidget {
  final String assetPath;
  final String fallbackLetter;

  const _StaffAvatar({
    required this.assetPath,
    required this.fallbackLetter,
  });

  @override
  Widget build(BuildContext context) {
    final hasAsset = assetPath.trim().isNotEmpty;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasAsset
          ? Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _FallbackAvatarLetter(
                fallbackLetter: fallbackLetter,
              ),
            )
          : _FallbackAvatarLetter(
              fallbackLetter: fallbackLetter,
            ),
    );
  }
}

class _FallbackAvatarLetter extends StatelessWidget {
  final String fallbackLetter;

  const _FallbackAvatarLetter({
    required this.fallbackLetter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        fallbackLetter,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
