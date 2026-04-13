import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/use_cases/settings/locale_preference_use_case.dart';
import '../application/use_cases/settings/theme_mode_use_case.dart';
import '../l10n/app_locale_preference.dart';

final themeModeUseCaseProvider = Provider<ThemeModeUseCase>((ref) {
  return ThemeModeUseCase();
});

final localePreferenceUseCaseProvider = Provider<LocalePreferenceUseCase>((ref) {
  return LocalePreferenceUseCase();
});

/// Persists and exposes [ThemeMode] (system / light / dark).
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  Future<void> load() async {
    state = await ref.read(themeModeUseCaseProvider).load();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    state = mode;
    await ref.read(themeModeUseCaseProvider).save(mode);
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
    state = await ref.read(localePreferenceUseCaseProvider).load();
  }

  Future<void> setPreference(AppLocalePreference value) async {
    if (state == value) return;
    state = value;
    await ref.read(localePreferenceUseCaseProvider).save(value);
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
