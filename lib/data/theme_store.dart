import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeStore {
  ThemeStore._();

  static const String _themeKey = 'freegi_theme_mode';

  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    switch (savedTheme) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;

      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;

      default:
        themeMode.value = ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(
    ThemeMode mode,
  ) async {
    themeMode.value = mode;

    final prefs = await SharedPreferences.getInstance();

    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(
          _themeKey,
          'light',
        );
        break;

      case ThemeMode.dark:
        await prefs.setString(
          _themeKey,
          'dark',
        );
        break;

      case ThemeMode.system:
        await prefs.setString(
          _themeKey,
          'system',
        );
        break;
    }
  }

  static String get title {
    switch (themeMode.value) {
      case ThemeMode.light:
        return 'Light';

      case ThemeMode.dark:
        return 'Dark';

      case ThemeMode.system:
        return 'System Default';
    }
  }
}