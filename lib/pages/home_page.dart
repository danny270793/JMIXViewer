import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/jmix/models/jmix_entity_list_result.dart';
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
  static const int _pageSize = 20;

  late final Future<List<Map<String, dynamic>>> _entitiesFuture;

  String? _selectedEntityName;
  int _pageIndex = 0;
  Future<JmixEntityListResult>? _listFuture;

  @override
  void initState() {
    super.initState();
    _entitiesFuture = FoodieSession.instance.rest.metadataListEntities();
  }

  void _closeDrawer(BuildContext context) {
    Scaffold.maybeOf(context)?.closeDrawer();
  }

  void _selectEntity(String entityName) {
    setState(() {
      _selectedEntityName = entityName;
      _pageIndex = 0;
      _listFuture = _loadCurrentPage();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedEntityName = null;
      _pageIndex = 0;
      _listFuture = null;
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
      limit: '$_pageSize',
      offset: '${_pageIndex * _pageSize}',
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
                          onTap: () {
                            _selectEntity(_entityDisplayName(meta));
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
              _PaginationBar(
                pageIndex: _pageIndex,
                pageSize: _pageSize,
                itemCount: 0,
                totalCount: result.totalCount,
                onPrevious:
                    _pageIndex > 0 ? () => _setPage(_pageIndex - 1) : null,
                onNext: _hasNextPage(result)
                    ? () => _setPage(_pageIndex + 1)
                    : null,
              ),
            ],
          );
        }

        final keys = _columnKeys(items);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  return _EntityRecordTile(
                    row: items[index],
                    keys: keys,
                    theme: theme,
                    colorScheme: colorScheme,
                    displayValue: _cellText,
                    fullValue: _fullValueText,
                  );
                },
              ),
            ),
            _PaginationBar(
              pageIndex: _pageIndex,
              pageSize: _pageSize,
              itemCount: items.length,
              totalCount: result.totalCount,
              onPrevious:
                  _pageIndex > 0 ? () => _setPage(_pageIndex - 1) : null,
              onNext: _hasNextPage(result)
                  ? () => _setPage(_pageIndex + 1)
                  : null,
            ),
          ],
        );
      },
    );
  }

  bool _hasNextPage(JmixEntityListResult result) {
    final total = result.totalCount;
    final end = _pageIndex * _pageSize + result.items.length;
    if (total != null) {
      return end < total;
    }
    return result.items.length == _pageSize;
  }

  /// Union of JSON keys for the current page, sorted.
  List<String> _columnKeys(List<Map<String, dynamic>> items) {
    final keys = <String>{};
    for (final row in items) {
      keys.addAll(row.keys);
    }
    return keys.toList()..sort();
  }

  /// Shortened for list rows (long JSON still truncated).
  String _cellText(dynamic value) {
    if (value == null) return '—';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    try {
      final s = jsonEncode(value);
      if (s.length > 200) return '${s.substring(0, 197)}…';
      return s;
    } catch (_) {
      return value.toString();
    }
  }

  /// Full text for tooltips (no 200-char cap).
  String _fullValueText(dynamic value) {
    if (value == null) return '—';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

  /// Jmix `metadata/entities` items use `entityName` (see OpenAPI `entityMetadata`).
  String _entityDisplayName(Map<String, dynamic> meta) {
    final name = meta['entityName'];
    if (name is String && name.isNotEmpty) return name;
    return '?';
  }
}

/// Jmix entity JSON often includes `_instanceName` for display in lists.
const String _kInstanceNameField = '_instanceName';

class _EntityRecordTile extends StatelessWidget {
  const _EntityRecordTile({
    required this.row,
    required this.keys,
    required this.theme,
    required this.colorScheme,
    required this.displayValue,
    required this.fullValue,
  });

  final Map<String, dynamic> row;
  final List<String> keys;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final String Function(dynamic value) displayValue;
  final String Function(dynamic value) fullValue;

  String _collapsedTitleText() {
    final v = row[_kInstanceNameField];
    if (v != null) {
      final s = displayValue(v);
      if (s != '—' && s.trim().isNotEmpty) return s;
    }
    if (row['id'] != null) return displayValue(row['id']);
    if (keys.isNotEmpty) return displayValue(row[keys.first]);
    return '—';
  }

  String _collapsedTitleTooltip() {
    final v = row[_kInstanceNameField];
    if (v != null) return fullValue(v);
    if (row['id'] != null) return fullValue(row['id']);
    if (keys.isNotEmpty) return fullValue(row[keys.first]);
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final restKeys =
        keys.where((k) => k != _kInstanceNameField).toList(growable: false);

    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        maintainState: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        title: Tooltip(
          message: _collapsedTitleTooltip(),
          child: Text(
            _collapsedTitleText(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        children: [
          if (restKeys.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'No other fields',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < restKeys.length; i++) ...[
                    if (i > 0) const SizedBox(height: 14),
                    Text(
                      restKeys[i],
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Tooltip(
                      message: fullValue(row[restKeys[i]]),
                      child: Text(
                        displayValue(row[restKeys[i]]),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.35,
                        ),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.pageIndex,
    required this.pageSize,
    required this.itemCount,
    required this.totalCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int pageIndex;
  final int pageSize;
  final int itemCount;
  final int? totalCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final start = pageIndex * pageSize + (itemCount > 0 ? 1 : 0);
    final end = pageIndex * pageSize + itemCount;
    final label = totalCount != null
        ? (itemCount > 0 ? 'Rows $start–$end of $totalCount' : 'Page ${pageIndex + 1}')
        : (itemCount > 0 ? 'Rows $start–$end' : 'No rows');

    return Material(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Previous page',
              icon: const Icon(Icons.chevron_left),
              onPressed: onPrevious,
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            IconButton(
              tooltip: 'Next page',
              icon: const Icon(Icons.chevron_right),
              onPressed: onNext,
            ),
          ],
        ),
      ),
    );
  }
}
