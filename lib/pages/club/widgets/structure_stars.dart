import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';

class StructureStars extends StatelessWidget {
  final int filled;
  final double size;
  final Color activeColor;
  final Color inactiveColor;

  const StructureStars({
    super.key,
    required this.filled,
    this.size = 18,
    this.activeColor = AppColors.star,
    this.inactiveColor = AppColors.textMuted,
  });

  @override
  Widget build(BuildContext context) {
    final f = filled.clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) {
          final on = i < f;

          return Padding(
            padding: const EdgeInsets.only(right: 1),
            child: Icon(
              on ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: on ? activeColor : inactiveColor,
            ),
          );
        },
      ),
    );
  }
}
