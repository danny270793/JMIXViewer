import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/app_locale_preference.dart';
import '../../business_use_case.dart';

const _kLocalePreferenceKey = 'app_locale_preference';

/// Loads and persists [AppLocalePreference] (SharedPreferences).
final class LocalePreferenceUseCase extends BusinessUseCase {
  LocalePreferenceUseCase() : super();

  Future<AppLocalePreference> load() {
    return run('settings.locale.load', () async {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kLocalePreferenceKey);
      return _decode(raw) ?? AppLocalePreference.system;
    });
  }

  Future<void> save(AppLocalePreference value) {
    return run('settings.locale.save', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLocalePreferenceKey, _encode(value));
    });
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
