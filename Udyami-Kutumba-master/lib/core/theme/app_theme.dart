import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: LightThemeColors.primary,
      scaffoldBackgroundColor: LightThemeColors.background,
      colorScheme: const ColorScheme.light(
        primary: LightThemeColors.primary,
        secondary: LightThemeColors.secondary,
        surface: LightThemeColors.surface,
        error: LightThemeColors.error,
        onPrimary: AppColorPalette.white,
        onSecondary: AppColorPalette.white,
        onSurface: LightThemeColors.textPrimary,
        onError: AppColorPalette.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: LightThemeColors.textPrimary),
        displayMedium: TextStyle(color: LightThemeColors.textPrimary),
        bodyLarge: TextStyle(color: LightThemeColors.textPrimary),
        bodyMedium: TextStyle(color: LightThemeColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: LightThemeColors.primary,
        foregroundColor: AppColorPalette.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LightThemeColors.primary,
          foregroundColor: AppColorPalette.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightThemeColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorPalette.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorPalette.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LightThemeColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LightThemeColors.error),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: DarkThemeColors.primary,
      scaffoldBackgroundColor: DarkThemeColors.background,
      colorScheme: const ColorScheme.dark(
        primary: DarkThemeColors.primary,
        secondary: DarkThemeColors.secondary,
        surface: DarkThemeColors.surface,
        error: DarkThemeColors.error,
        onPrimary: AppColorPalette.textBlack,
        onSecondary: AppColorPalette.textBlack,
        onSurface: DarkThemeColors.textPrimary,
        onError: AppColorPalette.white,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: DarkThemeColors.textPrimary),
        displayMedium: TextStyle(color: DarkThemeColors.textPrimary),
        bodyLarge: TextStyle(color: DarkThemeColors.textPrimary),
        bodyMedium: TextStyle(color: DarkThemeColors.textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DarkThemeColors.surface,
        foregroundColor: DarkThemeColors.textPrimary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DarkThemeColors.primary,
          foregroundColor: AppColorPalette.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkThemeColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorPalette.darkGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColorPalette.darkGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DarkThemeColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: DarkThemeColors.error),
        ),
      ),
    );
  }
}
