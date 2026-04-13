import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/jmix/models/jmix_entity_list_result.dart';
import '../auth/foodie_session.dart';
import '../business/jmix/drawer_entities.dart';
import '../business/jmix/entity_list_pagination.dart';
import '../business/jmix/entity_messages_labels.dart';
import '../l10n/app_localizations.dart';
import '../router/app_router.dart';
import '../widgets/entity_record_expansion_tile.dart';
import '../widgets/pagination_bar.dart';

/// Shown after a successful Foodie / Jmix sign-in.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final Future<DrawerEntitiesResult> _entitiesFuture;

  /// From `GET messages/entities` (same bundle as sidebar).
  Map<String, dynamic> _allEntityMessages = {};

  /// From `GET messages/entities/{entityName}` for attribute labels on the list.
  Map<String, dynamic>? _fieldMessagesForEntity;

  String? _selectedEntityName;
  int _pageIndex = 0;
  Future<JmixEntityListResult>? _listFuture;

  @override
  void initState() {
    super.initState();
    _entitiesFuture = loadDrawerEntities(FoodieSession.instance.rest).then((data) {
      if (mounted) {
        setState(() {
          _allEntityMessages = Map<String, dynamic>.from(data.messages);
        });
      }
      return data;
    });
  }

  void _closeDrawer(BuildContext context) {
    Scaffold.maybeOf(context)?.closeDrawer();
  }

  void _selectEntity(String entityName) {
    setState(() {
      _selectedEntityName = entityName;
      _pageIndex = 0;
      _listFuture = _loadCurrentPage();
      _fieldMessagesForEntity = null;
    });
    _loadFieldMessagesFor(entityName);
  }

  Future<void> _loadFieldMessagesFor(String entityName) async {
    final m = await loadFieldMessagesForEntity(
      FoodieSession.instance.rest,
      entityName,
    );
    if (!mounted || _selectedEntityName != entityName) return;
    setState(() => _fieldMessagesForEntity = m);
  }

  void _clearSelection() {
    setState(() {
      _selectedEntityName = null;
      _pageIndex = 0;
      _listFuture = null;
      _fieldMessagesForEntity = null;
    });
  }

  void _setPage(int page) {
    setState(() {
      _pageIndex = page;
      _listFuture = _loadCurrentPage();
    });
  }

  Future<JmixEntityListResult> _loadCurrentPage() {
    return FoodieSession.instance.rest.loadEntities(
      _selectedEntityName!,
      limit: '$kDefaultEntityPageSize',
      offset: '${_pageIndex * kDefaultEntityPageSize}',
      returnCount: true,
    );
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
              FutureBuilder<DrawerEntitiesResult>(
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
                  final data = snapshot.data!;
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
                            _selectEntity(entityDisplayName(meta));
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
        leading: _selectedEntityName != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _clearSelection,
              )
            : null,
        title: Text(
          _selectedEntityName ?? l10n.homeTitle,
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
      body: _selectedEntityName == null
          ? _buildWelcomeBody(context, colorScheme, l10n)
          : _buildEntityList(theme, colorScheme),
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

  Widget _buildEntityList(ThemeData theme, ColorScheme colorScheme) {
    return FutureBuilder<JmixEntityListResult>(
      future: _listFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _listFuture = _loadCurrentPage();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        final result = snapshot.data!;
        final items = result.items;
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
                  pageIndex: _pageIndex,
                  pageSize: kDefaultEntityPageSize,
                  itemCount: 0,
                  totalCount: result.totalCount,
                ),
                onPrevious:
                    _pageIndex > 0 ? () => _setPage(_pageIndex - 1) : null,
                onNext: entityListHasNextPage(
                  pageIndex: _pageIndex,
                  pageSize: kDefaultEntityPageSize,
                  result: result,
                )
                    ? () => _setPage(_pageIndex + 1)
                    : null,
              ),
            ],
          );
        }

        final entityName = _selectedEntityName!;
        final keys = entityRowColumnKeysSortedByDisplay(
          items,
          entityName,
          _allEntityMessages,
          _fieldMessagesForEntity,
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
                    allEntityMessages: _allEntityMessages,
                    fieldMessagesForEntity: _fieldMessagesForEntity,
                  );
                },
              ),
            ),
            PaginationBar(
              label: entityListPaginationBarLabel(
                pageIndex: _pageIndex,
                pageSize: kDefaultEntityPageSize,
                itemCount: items.length,
                totalCount: result.totalCount,
              ),
              onPrevious:
                  _pageIndex > 0 ? () => _setPage(_pageIndex - 1) : null,
              onNext: entityListHasNextPage(
                pageIndex: _pageIndex,
                pageSize: kDefaultEntityPageSize,
                result: result,
              )
                  ? () => _setPage(_pageIndex + 1)
                  : null,
            ),
          ],
        );
      },
    );
  }
}
