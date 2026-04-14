import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../business/jmix/entity_list_pagination.dart';
import '../business/jmix/entity_messages_labels.dart';
import '../business/jmix/entity_record_collapse_titles.dart';
import '../l10n/app_localizations.dart';
import '../logging/app_logger.dart';
import '../providers/home_providers.dart';
import '../router/app_router.dart';
import 'entity_record_detail_page.dart';

/// Shown after a successful Foodie / Jmix sign-in.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final selection = ref.watch(homeSelectionProvider);

    return Scaffold(
      drawer: Drawer(
        child: Builder(
          builder: (drawerContext) {
            return SafeArea(
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
                                Scaffold.maybeOf(drawerContext)
                                    ?.closeDrawer();
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      appBar: AppBar(
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

    return listAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => LayoutBuilder(
        builder: (context, constraints) {
          Future<void> onRefresh() async {
            await ref.read(entityListProvider.notifier).refresh();
          }

          return RefreshIndicator(
            onRefresh: onRefresh,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
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
                          onPressed: () {
                            AppLogger.logUserAction('home.retryEntityList');
                            onRefresh();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      data: (accum) {
        if (accum == null) {
          return const SizedBox.shrink();
        }
        final items = accum.items;
        final entityName = selection.selectedEntityName!;

        if (items.isEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(entityListProvider.notifier).refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Center(
                      child: Text(
                        'No rows',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return _InfiniteEntityListView(
          key: ValueKey(entityName),
          accum: accum,
          entityName: entityName,
          theme: theme,
          colorScheme: colorScheme,
          drawerMessages: drawerMessages,
        );
      },
    );
  }
}

class _InfiniteEntityListView extends ConsumerStatefulWidget {
  const _InfiniteEntityListView({
    super.key,
    required this.accum,
    required this.entityName,
    required this.theme,
    required this.colorScheme,
    required this.drawerMessages,
  });

  final AccumulatedEntityList accum;
  final String entityName;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Map<String, dynamic> drawerMessages;

  @override
  ConsumerState<_InfiniteEntityListView> createState() =>
      _InfiniteEntityListViewState();
}

class _InfiniteEntityListViewState extends ConsumerState<_InfiniteEntityListView> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fillViewportIfNeeded());
  }

  /// If everything fits on screen, keep loading pages until the list scrolls or ends.
  Future<void> _fillViewportIfNeeded() async {
    for (var i = 0; i < 64; i++) {
      if (!mounted) return;
      final accum = ref.read(entityListProvider).valueOrNull;
      if (accum == null || !accum.hasMore || accum.isLoadingMore) return;
      if (!_scrollController.hasClients) return;
      final p = _scrollController.position;
      if (p.maxScrollExtent > 0) return;
      await ref.read(entityListProvider.notifier).loadMore();
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final p = _scrollController.position;
    final nearEnd = p.maxScrollExtent <= 0 ||
        p.pixels >= p.maxScrollExtent - 400;
    if (nearEnd) {
      ref.read(entityListProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accum = ref.watch(entityListProvider).valueOrNull ?? widget.accum;
    final items = accum.items;
    final keys = entityRowColumnKeysSortedByDisplay(
      items,
      widget.entityName,
      widget.drawerMessages,
      null,
    );

    final summary = entityListInfiniteSummary(
      loadedCount: items.length,
      totalCount: accum.totalCount,
      hasMore: accum.hasMore,
    );

    final extra = (accum.hasMore && accum.isLoadingMore) ? 1 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(entityListProvider.notifier).refresh();
              if (mounted) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _fillViewportIfNeeded());
              }
            },
            child: ListView.separated(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: items.length + extra,
              separatorBuilder: (context, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
              if (index >= items.length) {
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
              final row = items[index];
              return ListTile(
                title: Tooltip(
                  message: EntityRecordCollapseTitles.titleTooltip(row, keys),
                  child: Text(
                    EntityRecordCollapseTitles.titleText(row, keys),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right,
                  color: widget.colorScheme.onSurfaceVariant,
                ),
                onTap: () async {
                  final recordWasSaved = await context.push<bool>(
                    AppRoutes.entityRecord,
                    extra: EntityRecordDetailArgs(
                      entityName: widget.entityName,
                      row: Map<String, dynamic>.from(row),
                    ),
                  );
                  if (!context.mounted) return;
                  if (recordWasSaved == true) {
                    await ref.read(entityListProvider.notifier).refresh();
                  }
                },
              );
            },
            ),
          ),
        ),
        Material(
          elevation: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              summary,
              textAlign: TextAlign.center,
              style: widget.theme.textTheme.bodySmall?.copyWith(
                color: widget.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
