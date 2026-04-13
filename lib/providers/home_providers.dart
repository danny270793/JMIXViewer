import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/jmix/jmix_rest_connector.dart';
import '../application/use_cases/jmix/load_drawer_entities_use_case.dart';
import '../application/use_cases/jmix/load_entity_list_page_use_case.dart';
import '../auth/foodie_session.dart';
import '../business/jmix/entity_list_pagination.dart';
import '../business/jmix/entity_list_search.dart';
import '../business/jmix/entity_messages_labels.dart';
import '../domain/jmix/drawer_entities_result.dart';
import '../logging/app_logger.dart';

/// Jmix REST client used for home (same instance as [FoodieSession]).
final jmixRestConnectorProvider = Provider<JmixRestConnector>((ref) {
  return FoodieSession.instance.rest;
});

final loadDrawerEntitiesUseCaseProvider =
    Provider<LoadDrawerEntitiesUseCase>((ref) {
  return LoadDrawerEntitiesUseCase(ref.watch(jmixRestConnectorProvider));
});

final loadEntityListPageUseCaseProvider =
    Provider<LoadEntityListPageUseCase>((ref) {
  return LoadEntityListPageUseCase(ref.watch(jmixRestConnectorProvider));
});

/// Drawer: metadata + global entity messages.
final drawerEntitiesProvider = FutureProvider<DrawerEntitiesResult>((ref) {
  return ref.read(loadDrawerEntitiesUseCaseProvider)();
});

@immutable
class HomeSelection {
  const HomeSelection({this.selectedEntityName});

  final String? selectedEntityName;
}

final homeSelectionProvider =
    NotifierProvider<HomeSelectionNotifier, HomeSelection>(
  HomeSelectionNotifier.new,
);

class HomeSelectionNotifier extends Notifier<HomeSelection> {
  @override
  HomeSelection build() => const HomeSelection();

  void selectEntity(String name) {
    AppLogger.logUserAction('home.selectEntity', name);
    state = HomeSelection(selectedEntityName: name);
  }

  void clear() {
    AppLogger.logUserAction('home.clearSelection');
    state = const HomeSelection();
  }
}

/// User-chosen sort for the generic entity list (`GET entities/{name}` `sort` query).
@immutable
class EntityListSort {
  const EntityListSort({
    required this.fieldKey,
    required this.ascending,
  });

  final String fieldKey;
  final bool ascending;

  /// Jmix REST: ascending uses the attribute name; descending prefixes `-`.
  String get jmixSortParameter => ascending ? fieldKey : '-$fieldKey';
}

final entityListSortProvider =
    NotifierProvider<EntityListSortNotifier, EntityListSort?>(
  EntityListSortNotifier.new,
);

class EntityListSortNotifier extends Notifier<EntityListSort?> {
  @override
  EntityListSort? build() {
    ref.listen<HomeSelection>(
      homeSelectionProvider,
      (previous, next) {
        if (previous?.selectedEntityName != next.selectedEntityName) {
          state = null;
        }
      },
    );
    return null;
  }

  void apply(EntityListSort value) {
    AppLogger.logUserAction(
      'home.entityList.sort',
      '${value.fieldKey} ${value.ascending ? 'asc' : 'desc'}',
    );
    state = value;
    ref.read(entityListProvider.notifier).refresh();
  }

  void clear() {
    AppLogger.logUserAction('home.entityList.sort', 'default');
    state = null;
    ref.read(entityListProvider.notifier).refresh();
  }
}

final entityListSearchProvider =
    NotifierProvider<EntityListSearchNotifier, EntityListSearch?>(
  EntityListSearchNotifier.new,
);

class EntityListSearchNotifier extends Notifier<EntityListSearch?> {
  @override
  EntityListSearch? build() {
    ref.listen<HomeSelection>(
      homeSelectionProvider,
      (previous, next) {
        if (previous?.selectedEntityName != next.selectedEntityName) {
          state = null;
        }
      },
    );
    return null;
  }

  void apply(EntityListSearch value) {
    final q = value.query.trim();
    AppLogger.logUserAction(
      'home.entityList.search',
      q.isEmpty ? 'clear' : '${value.fieldKey}: $q',
    );
    state = q.isEmpty
        ? null
        : EntityListSearch(fieldKey: value.fieldKey, query: q);
    ref.read(entityListProvider.notifier).refresh();
  }

  void clear() {
    AppLogger.logUserAction('home.entityList.search', 'clear');
    state = null;
    ref.read(entityListProvider.notifier).refresh();
  }
}

/// First page + appended pages for infinite scroll when an entity is selected.
@immutable
class AccumulatedEntityList {
  const AccumulatedEntityList({
    required this.items,
    this.totalCount,
    required this.nextPageIndex,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final List<Map<String, dynamic>> items;
  final int? totalCount;
  /// Next Jmix page index to request (0-based).
  final int nextPageIndex;
  final bool hasMore;
  final bool isLoadingMore;

  AccumulatedEntityList copyWith({
    List<Map<String, dynamic>>? items,
    int? totalCount,
    int? nextPageIndex,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return AccumulatedEntityList(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      nextPageIndex: nextPageIndex ?? this.nextPageIndex,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final entityListProvider =
    AsyncNotifierProvider<EntityListNotifier, AccumulatedEntityList?>(
  EntityListNotifier.new,
);

/// Avoids calling metadata on every page; keyed by entity name.
final Map<String, bool> _entityHasCreatedDateForSortCache = {};

Future<String?> _effectiveEntityListSortQuery(Ref ref, String entityName) async {
  final explicit = ref.read(entityListSortProvider);
  if (explicit != null) return explicit.jmixSortParameter;

  if (_entityHasCreatedDateForSortCache.containsKey(entityName)) {
    final has = _entityHasCreatedDateForSortCache[entityName]!;
    return has
        ? const EntityListSort(fieldKey: 'createdDate', ascending: false)
            .jmixSortParameter
        : null;
  }

  try {
    final meta =
        await ref.read(jmixRestConnectorProvider).metadataGetEntity(entityName);
    final has = entityMetadataHasProperty(meta, 'createdDate');
    _entityHasCreatedDateForSortCache[entityName] = has;
    return has
        ? const EntityListSort(fieldKey: 'createdDate', ascending: false)
            .jmixSortParameter
        : null;
  } catch (_) {
    _entityHasCreatedDateForSortCache[entityName] = false;
    return null;
  }
}

Future<AccumulatedEntityList?> _loadEntityListFirstPage(
  Ref ref,
  String entityName,
) async {
  final sort = await _effectiveEntityListSortQuery(ref, entityName);
  final result = await ref.read(loadEntityListPageUseCaseProvider)(
    entityName: entityName,
    pageIndex: 0,
    sort: sort,
    search: ref.read(entityListSearchProvider),
  );
  if (result == null) return null;

  final items = List<Map<String, dynamic>>.from(result.items);
  final hasMore = result.items.isNotEmpty &&
      entityListHasNextPage(
        pageIndex: 0,
        pageSize: kDefaultEntityPageSize,
        result: result,
      );

  return AccumulatedEntityList(
    items: items,
    totalCount: result.totalCount,
    nextPageIndex: 1,
    hasMore: hasMore,
    isLoadingMore: false,
  );
}

class EntityListNotifier extends AsyncNotifier<AccumulatedEntityList?> {
  @override
  Future<AccumulatedEntityList?> build() async {
    final sel = ref.watch(homeSelectionProvider);
    if (sel.selectedEntityName == null) return null;
    return _loadEntityListFirstPage(ref, sel.selectedEntityName!);
  }

  /// Reloads page 0 (pull-to-refresh). Does not set [state] to loading so the
  /// list is not replaced by a full-screen spinner while refreshing.
  Future<void> refresh() async {
    final sel = ref.read(homeSelectionProvider);
    final name = sel.selectedEntityName;
    if (name == null) return;
    AppLogger.logUserAction('home.entityList.refresh', name);
    try {
      final next = await _loadEntityListFirstPage(ref, name);
      state = AsyncValue.data(next);
    } catch (e, st) {
      final previous = state.valueOrNull;
      state = previous != null
          ? AsyncValue.data(previous)
          : AsyncValue.error(e, st);
    }
  }

  /// Loads the next page when the user scrolls near the bottom.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncValue.data(current.copyWith(isLoadingMore: true));

    try {
      final sel = ref.read(homeSelectionProvider);
      final name = sel.selectedEntityName;
      if (name == null) {
        state = AsyncValue.data(current.copyWith(isLoadingMore: false));
        return;
      }

      final pageIndex = current.nextPageIndex;
      final sort = await _effectiveEntityListSortQuery(ref, name);
      final result = await ref.read(loadEntityListPageUseCaseProvider)(
        entityName: name,
        pageIndex: pageIndex,
        sort: sort,
        search: ref.read(entityListSearchProvider),
      );
      if (result == null) {
        state = AsyncValue.data(
          current.copyWith(isLoadingMore: false, hasMore: false),
        );
        return;
      }

      final merged = [...current.items, ...result.items];
      final hasMore = result.items.isNotEmpty &&
          entityListHasNextPage(
            pageIndex: pageIndex,
            pageSize: kDefaultEntityPageSize,
            result: result,
          );

      state = AsyncValue.data(
        AccumulatedEntityList(
          items: merged,
          totalCount: result.totalCount ?? current.totalCount,
          nextPageIndex: pageIndex + 1,
          hasMore: hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      final v = state.valueOrNull;
      if (v != null) {
        state = AsyncValue.data(v.copyWith(isLoadingMore: false));
      }
    }
  }
}
