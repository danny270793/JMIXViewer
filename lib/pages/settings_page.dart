import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/foodie_session.dart';
import '../router/app_router.dart';
import '../theme/theme_controller.dart';

/// App settings.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                ListenableBuilder(
                  listenable: themeController,
                  builder: (context, _) {
                    final mode = themeController.themeMode;
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.system,
                            label: Text('System'),
                            tooltip: 'Match device setting',
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.light,
                            label: Text('Light'),
                          ),
                          ButtonSegment<ThemeMode>(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {mode},
                        emptySelectionAllowed: false,
                        multiSelectionEnabled: false,
                        onSelectionChanged: (selected) {
                          themeController.setThemeMode(selected.first);
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Other preferences will appear here.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
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
                child: const Text('Sign out'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
