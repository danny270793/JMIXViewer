import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/foodie_session.dart';
import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import '../router/app_router.dart';
import '../theme/theme_controller.dart';

String _themeShortLabel(AppLocalizations l10n, ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => l10n.themeSystem,
    ThemeMode.light => l10n.themeLight,
    ThemeMode.dark => l10n.themeDark,
  };
}

String _themeOptionTitle(AppLocalizations l10n, ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => l10n.themeSystem,
    ThemeMode.light => l10n.themeLight,
    ThemeMode.dark => l10n.themeDark,
  };
}

String _themeOptionDescription(AppLocalizations l10n, ThemeMode mode) {
  return switch (mode) {
    ThemeMode.system => l10n.themeSystemDesc,
    ThemeMode.light => l10n.themeLightDesc,
    ThemeMode.dark => l10n.themeDarkDesc,
  };
}

String _localeShortLabel(AppLocalizations l10n, AppLocalePreference pref) {
  return switch (pref) {
    AppLocalePreference.system => l10n.languageSystem,
    AppLocalePreference.english => l10n.languageEnglish,
    AppLocalePreference.spanish => l10n.languageSpanish,
  };
}

String _localeOptionTitle(AppLocalizations l10n, AppLocalePreference pref) {
  return _localeShortLabel(l10n, pref);
}

String _localeOptionDescription(AppLocalizations l10n, AppLocalePreference pref) {
  return switch (pref) {
    AppLocalePreference.system => l10n.languageSystemDesc,
    AppLocalePreference.english => l10n.languageEnglishDesc,
    AppLocalePreference.spanish => l10n.languageSpanishDesc,
  };
}

/// App settings.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _showLanguageBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ListenableBuilder(
            listenable: localeController,
            builder: (context, _) {
              final selected = localeController.preference;
              final sheetL10n = AppLocalizations.of(sheetContext);
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Text(
                        sheetL10n.languageSheetTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    for (final pref in AppLocalePreference.values)
                      ListTile(
                        title: Text(_localeOptionTitle(sheetL10n, pref)),
                        subtitle: Text(
                          _localeOptionDescription(sheetL10n, pref),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: selected == pref
                            ? Icon(Icons.check, color: colorScheme.primary)
                            : null,
                        onTap: () async {
                          await localeController.setPreference(pref);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: ListenableBuilder(
            listenable: themeController,
            builder: (context, _) {
              final selected = themeController.themeMode;
              final sheetL10n = AppLocalizations.of(sheetContext);
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: Text(
                        sheetL10n.themeSheetTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    for (final mode in ThemeMode.values)
                      ListTile(
                        title: Text(_themeOptionTitle(sheetL10n, mode)),
                        subtitle: Text(
                          _themeOptionDescription(sheetL10n, mode),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: selected == mode
                            ? Icon(Icons.check, color: colorScheme.primary)
                            : null,
                        onTap: () async {
                          await themeController.setThemeMode(mode);
                          if (sheetContext.mounted) {
                            Navigator.of(sheetContext).pop();
                          }
                        },
                      ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.appearanceSection,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ListenableBuilder(
                  listenable: themeController,
                  builder: (context, _) {
                    final mode = themeController.themeMode;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.themeOption),
                      subtitle: Text(
                        l10n.themeSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _themeShortLabel(l10n, mode),
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      onTap: () => _showThemeBottomSheet(context),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.languageSection,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                ListenableBuilder(
                  listenable: localeController,
                  builder: (context, _) {
                    final pref = localeController.preference;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.languageOption),
                      subtitle: Text(
                        l10n.languageSubtitle,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _localeShortLabel(l10n, pref),
                            style: textTheme.titleMedium?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.chevron_right,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                      onTap: () => _showLanguageBottomSheet(context),
                    );
                  },
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  FoodieSession.instance.signOut();
                  context.go(AppRoutes.login);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(l10n.signOut),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
