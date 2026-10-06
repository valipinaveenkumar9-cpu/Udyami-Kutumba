import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// A ValueNotifier to track ThemeMode (always System)
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

// Initializes the theme
Future<void> initTheme() async {
  try {
    themeNotifier.value = ThemeMode.system;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('themeMode'); // Clear any previously saved theme mode
    print('DEV DEBUG - initTheme - theme_providers.dart - Theme initialized to: system');
  } catch (e) {
    print('DEV DEBUG - initTheme - theme_providers.dart - Error: $e');
  }
}

// Function to update the theme (disabled to enforce system theme)
Future<void> changeTheme(ThemeMode themeMode) async {
  print('DEV DEBUG - changeTheme - theme_providers.dart - Theme change ignored, enforcing system theme');
}
