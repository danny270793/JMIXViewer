import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../business_use_case.dart';

const _kThemeModeKey = 'theme_mode';

/// Loads and persists [ThemeMode] for the app (SharedPreferences).
final class ThemeModeUseCase extends BusinessUseCase {
  ThemeModeUseCase() : super();

  Future<ThemeMode> load() {
    return run('settings.theme.load', () async {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kThemeModeKey);
      return _decode(raw) ?? ThemeMode.system;
    });
  }

  Future<void> save(ThemeMode mode) {
    return run('settings.theme.save', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kThemeModeKey, _encode(mode));
    });
  }

  static String _encode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    };
  }

  static ThemeMode? _decode(String? raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }
}
