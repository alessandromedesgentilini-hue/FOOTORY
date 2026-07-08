import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Base
  static const Color background = Color(0xFFEFEAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF4F0FA);
  static const Color border = Color(0xFFDCD4EA);

  // Brand
  static const Color primary = Color(0xFF5A36C9);
  static const Color primaryDark = Color(0xFF41259E);
  static const Color primarySoft = Color(0xFFE8DFFF);

  static const Color accent = Color(0xFFF28A2E);
  static const Color accentDark = Color(0xFFD46F16);
  static const Color accentSoft = Color(0xFFFFE7D2);

  // Support
  static const Color brown = Color(0xFF8A5A3C);
  static const Color brownSoft = Color(0xFFF1E4DA);

  static const Color text = Color(0xFF1D1630);
  static const Color textSecondary = Color(0xFF5D566E);
  static const Color textMuted = Color(0xFF8E879C);

  static const Color success = Color(0xFF2E9B62);
  static const Color warning = Color(0xFFE3A72F);
  static const Color danger = Color(0xFFD9534F);

  static const Color star = Color(0xFFF2B84A);

  // Utility
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      Color(0xFF5A36C9),
      Color(0xFF7046EA),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient actionGradient = LinearGradient(
    colors: [
      Color(0xFF5A36C9),
      Color(0xFF7046EA),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient softCardGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF7F3FF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadows
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF41259E).withOpacity(0.10),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get strongCardShadow => [
        BoxShadow(
          color: const Color(0xFF41259E).withOpacity(0.16),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ];
}
