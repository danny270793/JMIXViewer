import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/jmix/jmix_rest_connector.dart';
import '../api/jmix/models/jmix_entity_list_result.dart';
import '../auth/foodie_session.dart';
import '../business/jmix/drawer_entities.dart';
import '../business/jmix/entity_list_pagination.dart';

/// Jmix REST client used for home (same instance as [FoodieSession]).
final jmixRestConnectorProvider = Provider<JmixRestConnector>((ref) {
  return FoodieSession.instance.rest;
});

/// Drawer: metadata + global entity messages.
final drawerEntitiesProvider = FutureProvider<DrawerEntitiesResult>((ref) {
  return loadDrawerEntities(ref.read(jmixRestConnectorProvider));
});

@immutable
class HomeSelection {
  const HomeSelection({this.selectedEntityName, this.pageIndex = 0});

  final String? selectedEntityName;
  final int pageIndex;
}

final homeSelectionProvider =
    NotifierProvider<HomeSelectionNotifier, HomeSelection>(
  HomeSelectionNotifier.new,
);

class HomeSelectionNotifier extends Notifier<HomeSelection> {
  @override
  HomeSelection build() => const HomeSelection();

  void selectEntity(String name) {
    state = HomeSelection(selectedEntityName: name, pageIndex: 0);
  }

  void clear() => state = const HomeSelection();

  void setPage(int page) {
    state = HomeSelection(
      selectedEntityName: state.selectedEntityName,
      pageIndex: page,
    );
  }
}

/// Per-entity field messages; only refetches when [HomeSelection.selectedEntityName] changes.
final fieldMessagesForSelectionProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final name = ref.watch(
    homeSelectionProvider.select((s) => s.selectedEntityName),
  );
  if (name == null) return {};
  return loadFieldMessagesForEntity(
    ref.read(jmixRestConnectorProvider),
    name,
  );
});

/// Paginated entity rows for the current [HomeSelection].
final entityListProvider =
    AsyncNotifierProvider<EntityListNotifier, JmixEntityListResult?>(
  EntityListNotifier.new,
);

class EntityListNotifier extends AsyncNotifier<JmixEntityListResult?> {
  @override
  Future<JmixEntityListResult?> build() async {
    final sel = ref.watch(homeSelectionProvider);
    if (sel.selectedEntityName == null) return null;
    final rest = ref.read(jmixRestConnectorProvider);
    return rest.loadEntities(
      sel.selectedEntityName!,
      limit: '$kDefaultEntityPageSize',
      offset: '${sel.pageIndex * kDefaultEntityPageSize}',
      returnCount: true,
    );
  }
}
