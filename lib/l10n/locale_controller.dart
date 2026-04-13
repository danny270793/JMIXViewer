import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocalePreferenceKey = 'app_locale_preference';

/// User-chosen UI language, persisted across launches.
enum AppLocalePreference {
  system,
  english,
  spanish,
}

/// Persists and notifies locale override. [appLocale] is `null` when [system]
/// so [MaterialApp] follows the device.
final class LocaleController extends ChangeNotifier {
  LocaleController();

  AppLocalePreference _preference = AppLocalePreference.system;

  AppLocalePreference get preference => _preference;

  /// `null` means resolve from the device; otherwise forces English or Spanish.
  Locale? get appLocale {
    return switch (_preference) {
      AppLocalePreference.system => null,
      AppLocalePreference.english => const Locale('en'),
      AppLocalePreference.spanish => const Locale('es'),
    };
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kLocalePreferenceKey);
    _preference = _decode(raw) ?? AppLocalePreference.system;
    notifyListeners();
  }

  Future<void> setPreference(AppLocalePreference value) async {
    if (_preference == value) return;
    _preference = value;
    notifyListeners();
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

final localeController = LocaleController();
