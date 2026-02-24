import 'package:flutter/material.dart';
import '../models/alert_model.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF2E7D32); // green[800]
  static const primaryLight = Color(0xFF60AD5E);
  static const primaryDark = Color(0xFF005005);
  static const accent = Color(0xFFFFA000); // amber[700]
  static const background = Color(0xFFF1F8E9);
  static const surface = Colors.white;
  static const error = Color(0xFFD32F2F);
}

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
    );
  }
}

Color alertColor(AlertSeverity severity) {
  switch (severity) {
    case AlertSeverity.alta:
      return const Color(0xFFD32F2F);
    case AlertSeverity.media:
      return const Color(0xFFF57C00);
    case AlertSeverity.baja:
      return const Color(0xFF388E3C);
  }
}

String alertLabel(AlertSeverity severity) {
  switch (severity) {
    case AlertSeverity.alta:
      return 'Alta';
    case AlertSeverity.media:
      return 'Media';
    case AlertSeverity.baja:
      return 'Baja';
  }
}
