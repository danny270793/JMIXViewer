import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/foodie_session.dart';
import '../l10n/app_localizations.dart';
import '../router/app_router.dart';

/// Shown after a successful Foodie / Jmix sign-in.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<List<Map<String, dynamic>>> _entitiesFuture;

  @override
  void initState() {
    super.initState();
    _entitiesFuture = FoodieSession.instance.rest.metadataListEntities();
  }

  void _closeDrawer(BuildContext context) {
    Scaffold.maybeOf(context)?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      Icons.view_in_ar_rounded,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.homeTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _entitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return ListTile(
                      dense: true,
                      title: Text(
                        'Could not load entities',
                        style: TextStyle(color: colorScheme.error),
                      ),
                      subtitle: Text(
                        '${snapshot.error}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }
                  final list = snapshot.data ?? const [];
                  if (list.isEmpty) {
                    return ListTile(
                      dense: true,
                      title: Text(
                        'No entities',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  final sorted = [...list]..sort(
                        (a, b) => _entityDisplayName(a).compareTo(
                              _entityDisplayName(b),
                            ),
                      );
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final meta in sorted)
                        ListTile(
                          dense: true,
                          title: Text(
                            _entityDisplayName(meta),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => _closeDrawer(context),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTooltip,
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.connectedToFoodie,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.signedInBody,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Jmix `metadata/entities` items use `entityName` (see OpenAPI `entityMetadata`).
  String _entityDisplayName(Map<String, dynamic> meta) {
    final name = meta['entityName'];
    if (name is String && name.isNotEmpty) return name;
    return '?';
  }
}
