// lib/core/app_theme.dart
// Corrige: “ShapeBorder -> OutlinedBorder?” (usa MaterialStatePropertyAll<OutlinedBorder>)

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light() {
    final rounded12 = MaterialStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)));
    final rounded8 = MaterialStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)));

    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF246BFD),
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          shape: rounded12,
          padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          shape: rounded12,
          padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          shape: rounded12,
          padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          shape: rounded8,
          padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
        ),
      ),

      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
