import 'package:flutter/material.dart';

import 'package:footory26/core/app_colors.dart';

class StaffAvatar extends StatelessWidget {
  final String assetPath;
  final String fallbackLetter;
  final double radius;

  const StaffAvatar({
    super.key,
    required this.assetPath,
    required this.fallbackLetter,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
        border: Border.all(
          color: AppColors.border,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) {
          return Center(
            child: Text(
              fallbackLetter,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: radius * 0.9,
                color: AppColors.textSecondary,
              ),
            ),
          );
        },
      ),
    );
  }
}
