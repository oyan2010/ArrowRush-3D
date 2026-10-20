import 'package:flutter/material.dart';
import '../config/app_config.dart';

/// Palette manager pulling colors from AppConfig.
class AppColors {
  AppColors._();

  // Mode Theme Colors
  static const Color darkBackground = Color(AppConfig.darkBackground);
  static const Color darkSurface = Color(AppConfig.darkSurface);
  static const Color darkTextPrimary = Color(AppConfig.darkTextPrimary);
  static const Color darkTextSecondary = Color(AppConfig.darkTextSecondary);

  static const Color lightBackground = Color(AppConfig.lightBackground);
  static const Color lightSurface = Color(AppConfig.lightSurface);
  static const Color lightTextPrimary = Color(AppConfig.lightTextPrimary);
  static const Color lightTextSecondary = Color(AppConfig.lightTextSecondary);

  // Game UI Colors
  static const Color heart = Color(AppConfig.heartColor);
  static const Color hintGlow = Color(AppConfig.hintGlowColor);
  static const Color collision = Color(AppConfig.collisionColor);
  static const Color success = Color(AppConfig.successColor);
  static const Color accent = Color(AppConfig.accentColor);

  /// Palette of arrow colors configured in AppConfig
  static List<Color> get arrowPalette =>
      AppConfig.arrowColors.map((hex) => Color(hex)).toList();

  static Color getArrowColor(int index) {
    final palette = arrowPalette;
    return palette[index % palette.length];
  }
}
