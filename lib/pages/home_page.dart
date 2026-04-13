import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../business/jmix/entity_list_pagination.dart';
import '../business/jmix/entity_list_search.dart';
import '../business/jmix/entity_list_search_operators.dart';
import '../business/jmix/entity_messages_labels.dart';
import '../business/jmix/entity_record_collapse_titles.dart';
import '../l10n/app_localizations.dart';
import '../logging/app_logger.dart';
import '../providers/entity_metadata_providers.dart';
import '../providers/home_providers.dart';
import '../router/app_router.dart';
import 'entity_record_detail_page.dart';

enum _HomeOverflowAction { search, sort, settings }

/// Shown after a successful Foodie / Jmix sign-in.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final selection = ref.watch(homeSelectionProvider);
    final activeSearch = ref.watch(entityListSearchProvider);

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
          if (selection.selectedEntityName != null)
            PopupMenuButton<_HomeOverflowAction>(
              tooltip: l10n.homeAppBarMenuTooltip,
              icon: const Icon(Icons.more_vert),
              onSelected: (_HomeOverflowAction value) {
                final name = selection.selectedEntityName!;
                switch (value) {
                  case _HomeOverflowAction.search:
                    _showEntityListSearchSheet(context, ref, name);
                  case _HomeOverflowAction.sort:
                    _showEntityListSortSheet(context, name);
                  case _HomeOverflowAction.settings:
                    context.push(AppRoutes.settings);
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  value: _HomeOverflowAction.search,
                  child: Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: activeSearch != null
                            ? colorScheme.primary
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(l10n.homeEntityListSearchTooltip),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _HomeOverflowAction.sort,
                  child: Row(
                    children: [
                      const Icon(Icons.swap_vert),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(l10n.homeEntityListSortTooltip),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: _HomeOverflowAction.settings,
                  child: Row(
                    children: [
                      const Icon(Icons.settings_outlined),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l10n.settingsTooltip)),
                    ],
                  ),
                ),
              ],
            )
          else
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
        final activeSearch = ref.watch(entityListSearchProvider);
        final listKey =
            '${entityName}_${activeSearch?.fieldKey ?? ''}_${activeSearch?.op ?? ''}_${activeSearch?.query ?? ''}';

        if (items.isEmpty) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return RefreshIndicator(
                key: ValueKey('empty_$listKey'),
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
          key: ValueKey(listKey),
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

void _showEntityListSearchSheet(
  BuildContext context,
  WidgetRef ref,
  String entityName,
) {
  final initial = ref.read(entityListSearchProvider);
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _EntityListSearchSheet(
          entityName: entityName,
          initialSearch: initial,
        ),
      );
    },
  );
}

void _showEntityListSortSheet(
  BuildContext context,
  String entityName,
) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: _EntityListSortSheet(entityName: entityName),
      );
    },
  );
}

class _EntityListSearchSheet extends ConsumerStatefulWidget {
  const _EntityListSearchSheet({
    required this.entityName,
    this.initialSearch,
  });

  final String entityName;
  final EntityListSearch? initialSearch;

  @override
  ConsumerState<_EntityListSearchSheet> createState() =>
      _EntityListSearchSheetState();
}

class _EntityListSearchSheetState extends ConsumerState<_EntityListSearchSheet> {
  late final TextEditingController _queryController;
  String? _fieldChoice;
  String? _opChoice;

  @override
  void initState() {
    super.initState();
    final i = widget.initialSearch;
    _queryController = TextEditingController(text: i?.query ?? '');
    _fieldChoice = i?.fieldKey;
    final o = i?.op;
    _opChoice =
        o != null && kEntityListSearchOperators.contains(o) ? o : null;
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  String _resolvedField(List<String> keys, EntityListSearch? current) {
    final prefer = _fieldChoice ?? current?.fieldKey;
    if (prefer != null && keys.contains(prefer)) return prefer;
    return keys.first;
  }

  String _resolvedOp(EntityListSearch? current) {
    final prefer = _opChoice ?? current?.op;
    if (prefer != null && kEntityListSearchOperators.contains(prefer)) {
      return prefer;
    }
    return 'contains';
  }

  List<String> _fieldKeys() {
    final msgs = ref.watch(drawerEntitiesProvider).maybeWhen(
          data: (d) => d.messages,
          orElse: () => <String, dynamic>{},
        );
    final meta = ref.watch(entityMetadataProvider(widget.entityName));
    final accum = ref.watch(entityListProvider).valueOrNull;
    final fromMeta = meta.maybeWhen(
      data: (m) => entityMetadataPropertyNamesSorted(
        m,
        widget.entityName,
        msgs,
        null,
      ),
      orElse: () => <String>[],
    );
    if (fromMeta.isNotEmpty) return fromMeta;
    final items = accum?.items ?? const <Map<String, dynamic>>[];
    if (items.isEmpty) return [];
    return entityRowColumnKeysSortedByDisplay(
      items,
      widget.entityName,
      msgs,
      null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final keys = _fieldKeys();
    final current = ref.watch(entityListSearchProvider);
    final metaAsync = ref.watch(entityMetadataProvider(widget.entityName));
    final msgs = ref.watch(drawerEntitiesProvider).maybeWhen(
          data: (d) => d.messages,
          orElse: () => <String, dynamic>{},
        );

    final loadingFields = keys.isEmpty && metaAsync.isLoading;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.homeEntityListSearchTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (loadingFields)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        l10n.homeEntityListSearchLoadingFields,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else if (keys.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.homeEntityListSortNoFields,
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              else ...[
                Text(
                  l10n.homeEntityListSearchField,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _resolvedField(keys, current),
                      items: [
                        for (final k in keys)
                          DropdownMenuItem<String>(
                            value: k,
                            child: Text(
                              attributeSidebarLabel(
                                k,
                                widget.entityName,
                                msgs,
                                null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _fieldChoice = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.homeEntityListSearchOperator,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _resolvedOp(current),
                      items: [
                        for (final op in kEntityListSearchOperators)
                          DropdownMenuItem<String>(
                            value: op,
                            child: Text(op),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _opChoice = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (entityListSearchOperatorNeedsValue(_resolvedOp(current))) ...[
                  TextField(
                    controller: _queryController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: _resolvedOp(current) == 'in' ||
                              _resolvedOp(current) == 'notIn'
                          ? l10n.homeEntityListSearchValueHintIn
                          : l10n.homeEntityListSearchQueryHint,
                      isDense: true,
                    ),
                    textInputAction: TextInputAction.search,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        ref.read(entityListSearchProvider.notifier).clear();
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.homeEntityListSearchClear),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        final op = _resolvedOp(current);
                        final field = _resolvedField(keys, current);
                        final draft = EntityListSearch(
                          fieldKey: field,
                          op: op,
                          query: _queryController.text,
                        );
                        if (entityListSearchOperatorNeedsValue(op) &&
                            !entityListSearchIsActive(draft)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.homeEntityListSearchValueRequired,
                              ),
                            ),
                          );
                          return;
                        }
                        ref.read(entityListSearchProvider.notifier).apply(
                              draft,
                            );
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.homeEntityListSearchApply),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _EntityListSortSheet extends ConsumerStatefulWidget {
  const _EntityListSortSheet({required this.entityName});

  final String entityName;

  @override
  ConsumerState<_EntityListSortSheet> createState() =>
      _EntityListSortSheetState();
}

class _EntityListSortSheetState extends ConsumerState<_EntityListSortSheet> {
  String? _fieldChoice;
  bool? _ascChoice;

  String _resolvedField(List<String> keys, EntityListSort? current) {
    final prefer = _fieldChoice ?? current?.fieldKey;
    if (prefer != null && keys.contains(prefer)) return prefer;
    if (current == null && keys.contains('createdDate')) {
      return 'createdDate';
    }
    return keys.first;
  }

  bool _resolvedAsc(EntityListSort? current, List<String> keys) {
    if (_ascChoice != null) return _ascChoice!;
    if (current != null) return current.ascending;
    if (keys.contains('createdDate')) return false;
    return true;
  }

  List<String> _sortableKeys() {
    final msgs = ref.watch(drawerEntitiesProvider).maybeWhen(
          data: (d) => d.messages,
          orElse: () => <String, dynamic>{},
        );
    final meta = ref.watch(entityMetadataProvider(widget.entityName));
    final accum = ref.watch(entityListProvider).valueOrNull;
    final fromMeta = meta.maybeWhen(
      data: (m) => entityMetadataPropertyNamesSorted(
        m,
        widget.entityName,
        msgs,
        null,
      ),
      orElse: () => <String>[],
    );
    if (fromMeta.isNotEmpty) return fromMeta;
    final items = accum?.items ?? const <Map<String, dynamic>>[];
    if (items.isEmpty) return [];
    return entityRowColumnKeysSortedByDisplay(
      items,
      widget.entityName,
      msgs,
      null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final keys = _sortableKeys();
    final current = ref.watch(entityListSortProvider);
    final metaAsync = ref.watch(entityMetadataProvider(widget.entityName));
    final msgs = ref.watch(drawerEntitiesProvider).maybeWhen(
          data: (d) => d.messages,
          orElse: () => <String, dynamic>{},
        );

    final loadingFields = keys.isEmpty && metaAsync.isLoading;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.homeEntityListSortTitle,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (loadingFields)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        l10n.homeEntityListSortLoadingFields,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else if (keys.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.homeEntityListSortNoFields,
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              else ...[
                Text(
                  l10n.homeEntityListSortField,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _resolvedField(keys, current),
                      items: [
                        for (final k in keys)
                          DropdownMenuItem<String>(
                            value: k,
                            child: Text(
                              attributeSidebarLabel(
                                k,
                                widget.entityName,
                                msgs,
                                null,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _fieldChoice = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.homeEntityListSortOrder,
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 8),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: true,
                      label: Text(l10n.homeEntityListSortAscending),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      label: Text(l10n.homeEntityListSortDescending),
                    ),
                  ],
                  emptySelectionAllowed: false,
                  selected: {_resolvedAsc(current, keys)},
                  onSelectionChanged: (s) {
                    setState(() => _ascChoice = s.single);
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        ref.read(entityListSortProvider.notifier).clear();
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.homeEntityListSortDefaultOrder),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: () {
                        final field = _resolvedField(keys, current);
                        ref.read(entityListSortProvider.notifier).apply(
                              EntityListSort(
                                fieldKey: field,
                                ascending: _resolvedAsc(current, keys),
                              ),
                            );
                        Navigator.of(context).pop();
                      },
                      child: Text(l10n.homeEntityListSortApply),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
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
              padding: EdgeInsets.zero,
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
