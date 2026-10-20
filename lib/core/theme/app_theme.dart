import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/app_config.dart';
import 'app_colors.dart';

/// App theme configuration for Light and Dark modes.
class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        surface: AppColors.lightSurface,
        primary: AppColors.accent,
        onSurface: AppColors.lightTextPrimary,
      ),
      textTheme: GoogleFonts.getTextTheme(
        AppConfig.fontFamily,
        const TextTheme(
          displayLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: AppColors.lightTextPrimary, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(color: AppColors.lightTextPrimary),
          bodyMedium: TextStyle(color: AppColors.lightTextSecondary),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.darkSurface,
        primary: AppColors.accent,
        onSurface: AppColors.darkTextPrimary,
      ),
      textTheme: GoogleFonts.getTextTheme(
        AppConfig.fontFamily,
        const TextTheme(
          displayLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
          titleLarge: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(color: AppColors.darkTextPrimary),
          bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
        ),
      ),
    );
  }
}
