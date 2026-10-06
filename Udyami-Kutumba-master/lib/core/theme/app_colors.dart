//app logo colors
// logo color
// #02A092
// #028BD9
// #FF6B01
// logo text colors
// #020202
// #028BD9
import 'package:flutter/material.dart';
  
class AppColorPalette {
  // Logo colors
  static const Color primaryGreen = Color(0xFF02A092);
  static const Color primaryBlue = Color(0xFF028BD9);
  static const Color primaryOrange = Color(0xFFFF6B01);
  
  // Logo text colors
  static const Color textBlack = Color(0xFF020202);
  static const Color textBlue = Color(0xFF028BD9);

  // Common colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color darkGrey = Color(0xFF424242);
}

class StatusColors {
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
}

class BackgroundColors {
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color darkBackground = Color(0xFF121212);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1E1E1E);
}

class LightThemeColors {
  static const Color primary = AppColorPalette.primaryGreen;
  static const Color secondary = AppColorPalette.primaryBlue;
  static const Color accent = AppColorPalette.primaryOrange;
  static const Color background = BackgroundColors.lightBackground;
  static const Color surface = BackgroundColors.lightSurface;
  static const Color textPrimary = AppColorPalette.textBlack;
  static const Color textSecondary = AppColorPalette.darkGrey;
  static const Color error = StatusColors.error;
}

class DarkThemeColors {
  static const Color primary = AppColorPalette.primaryGreen;
  static const Color secondary = AppColorPalette.primaryBlue;
  static const Color accent = AppColorPalette.primaryOrange;
  static const Color background = BackgroundColors.darkBackground;
  static const Color surface = BackgroundColors.darkSurface;
  static const Color textPrimary = AppColorPalette.white;
  static const Color textSecondary = AppColorPalette.lightGrey;
  static const Color error = StatusColors.error;
}
