import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_locale_preference.dart';

const _kThemeModeKey = 'theme_mode';
const _kLocalePreferenceKey = 'app_locale_preference';

/// Persists and exposes [ThemeMode] (system / light / dark).
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kThemeModeKey);
    state = _decode(raw) ?? ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, _encode(mode));
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

/// Persists and exposes [AppLocalePreference].
final localePreferenceProvider =
    NotifierProvider<LocalePreferenceNotifier, AppLocalePreference>(
  LocalePreferenceNotifier.new,
);

class LocalePreferenceNotifier extends Notifier<AppLocalePreference> {
  @override
  AppLocalePreference build() => AppLocalePreference.system;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocalePreferenceKey);
    state = _decode(raw) ?? AppLocalePreference.system;
  }

  Future<void> setPreference(AppLocalePreference value) async {
    if (state == value) return;
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLocalePreferenceKey, _encode(value));
  }

  static String _encode(AppLocalePreference p) {
    return switch (p) {
      AppLocalePreference.system => 'system',
      AppLocalePreference.english => 'en',
      AppLocalePreference.spanish => 'es',
    };
  }

  static AppLocalePreference? _decode(String? raw) {
    return switch (raw) {
      'en' => AppLocalePreference.english,
      'es' => AppLocalePreference.spanish,
      'system' => AppLocalePreference.system,
      _ => null,
    };
  }
}

/// `null` means follow device locale.
final appLocaleProvider = Provider<Locale?>((ref) {
  final p = ref.watch(localePreferenceProvider);
  return switch (p) {
    AppLocalePreference.system => null,
    AppLocalePreference.english => const Locale('en'),
    AppLocalePreference.spanish => const Locale('es'),
  };
});
