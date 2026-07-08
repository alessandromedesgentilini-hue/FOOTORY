import 'package:flutter/material.dart';
import 'package:footory26/core/app_colors.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Widget child;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.count,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(child: Text(title)),
                Text('$count'),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
