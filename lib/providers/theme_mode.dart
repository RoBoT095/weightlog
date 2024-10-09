import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeModeProvider extends StateNotifier<ThemeMode> {
  ThemeModeProvider() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('themeMode') ?? 'light';
    state = _parseThemeMode(themeString);
  }

  Future<void> setTheme(String themeString) async {
    state = _parseThemeMode(themeString);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', themeString);
  }

  ThemeMode _parseThemeMode(String themeString) {
    switch (themeString) {
      case 'system':
        return ThemeMode.system;
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeProvider, ThemeMode>(
  (ref) => ThemeModeProvider(),
);
