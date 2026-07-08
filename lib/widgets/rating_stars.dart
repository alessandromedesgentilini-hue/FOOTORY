import 'package:flutter/material.dart';

/// RatingStars
///
/// Mostra:
/// ⭐⭐⭐☆☆   6 / 10
///
/// Regras:
/// - stars5 = 0..5 (visual)
/// - label = "X / 10"
/// - sem meia estrela
class RatingStars extends StatelessWidget {
  final int stars5;
  final String label;
  final double iconSize;

  const RatingStars({
    super.key,
    required this.stars5,
    required this.label,
    this.iconSize = 18,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Row(
      children: [
        Row(
          children: List.generate(5, (i) {
            final filled = i < stars5;

            return Icon(
              filled ? Icons.star : Icons.star_border,
              size: iconSize,
              color: filled ? cs.primary : cs.outlineVariant,
            );
          }),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: t.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
