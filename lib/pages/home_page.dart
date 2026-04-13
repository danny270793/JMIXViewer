import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../business/jmix/entity_list_pagination.dart';
import '../business/jmix/entity_messages_labels.dart';
import '../l10n/app_localizations.dart';
import '../providers/home_providers.dart';
import '../router/app_router.dart';
import '../widgets/entity_record_expansion_tile.dart';
import '../widgets/pagination_bar.dart';

/// Shown after a successful Foodie / Jmix sign-in.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _closeDrawer(BuildContext context) {
    Scaffold.maybeOf(context)?.closeDrawer();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final selection = ref.watch(homeSelectionProvider);

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
              ref.watch(drawerEntitiesProvider).when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                    error: (e, _) => ListTile(
                      dense: true,
                      title: Text(
                        'Could not load entities',
                        style: TextStyle(color: colorScheme.error),
                      ),
                      subtitle: Text(
                        '$e',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    data: (data) {
                      final list = data.metadata;
                      final messages = data.messages;
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
                            (a, b) => sidebarSortKey(
                                  entityDisplayName(a),
                                  messages,
                                ).compareTo(
                                  sidebarSortKey(
                                    entityDisplayName(b),
                                    messages,
                                  ),
                                ),
                          );
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (final meta in sorted)
                            ListTile(
                              dense: true,
                              title: Text(
                                sidebarLabel(
                                  entityDisplayName(meta),
                                  messages,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () {
                                ref
                                    .read(homeSelectionProvider.notifier)
                                    .selectEntity(entityDisplayName(meta));
                                _closeDrawer(context);
                              },
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
        leading: selection.selectedEntityName != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () =>
                    ref.read(homeSelectionProvider.notifier).clear(),
              )
            : null,
        title: Text(
          selection.selectedEntityName ?? l10n.homeTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settingsTooltip,
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: selection.selectedEntityName == null
          ? _buildWelcomeBody(context, colorScheme, l10n)
          : _buildEntityList(
              context,
              ref,
              theme,
              colorScheme,
              selection,
            ),
    );
  }

  Widget _buildWelcomeBody(
    BuildContext context,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    return Center(
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
    );
  }

  Widget _buildEntityList(
    BuildContext context,
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
    HomeSelection selection,
  ) {
    final listAsync = ref.watch(entityListProvider);
    final drawerMessages = ref.watch(drawerEntitiesProvider).maybeWhen(
          data: (d) => d.messages,
          orElse: () => <String, dynamic>{},
        );
    final fieldMessages = ref.watch(fieldMessagesForSelectionProvider).maybeWhen(
          data: (m) => m,
          orElse: () => null,
        );

    return listAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$e',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => ref.invalidate(entityListProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (result) {
        if (result == null) {
          return const SizedBox.shrink();
        }
        final items = result.items;
        final entityName = selection.selectedEntityName!;
        final pageIndex = selection.pageIndex;

        if (items.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'No rows on this page',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
              PaginationBar(
                label: entityListPaginationBarLabel(
                  pageIndex: pageIndex,
                  pageSize: kDefaultEntityPageSize,
                  itemCount: 0,
                  totalCount: result.totalCount,
                ),
                onPrevious: pageIndex > 0
                    ? () => ref.read(homeSelectionProvider.notifier).setPage(
                          pageIndex - 1,
                        )
                    : null,
                onNext: entityListHasNextPage(
                  pageIndex: pageIndex,
                  pageSize: kDefaultEntityPageSize,
                  result: result,
                )
                    ? () => ref.read(homeSelectionProvider.notifier).setPage(
                          pageIndex + 1,
                        )
                    : null,
              ),
            ],
          );
        }

        final keys = entityRowColumnKeysSortedByDisplay(
          items,
          entityName,
          drawerMessages,
          fieldMessages,
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return EntityRecordExpansionTile(
                    row: items[index],
                    orderedColumnKeys: keys,
                    theme: theme,
                    colorScheme: colorScheme,
                    entityName: entityName,
                    allEntityMessages: drawerMessages,
                    fieldMessagesForEntity: fieldMessages,
                  );
                },
              ),
            ),
            PaginationBar(
              label: entityListPaginationBarLabel(
                pageIndex: pageIndex,
                pageSize: kDefaultEntityPageSize,
                itemCount: items.length,
                totalCount: result.totalCount,
              ),
              onPrevious: pageIndex > 0
                  ? () => ref.read(homeSelectionProvider.notifier).setPage(
                        pageIndex - 1,
                      )
                  : null,
              onNext: entityListHasNextPage(
                pageIndex: pageIndex,
                pageSize: kDefaultEntityPageSize,
                result: result,
              )
                  ? () => ref.read(homeSelectionProvider.notifier).setPage(
                        pageIndex + 1,
                      )
                  : null,
            ),
          ],
        );
      },
    );
  }
}
