import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/jmix/jmix_rest_connector.dart';
import '../api/jmix/models/jmix_entity_list_result.dart';
import '../application/use_cases/jmix/load_drawer_entities_use_case.dart';
import '../application/use_cases/jmix/load_entity_list_page_use_case.dart';
import '../application/use_cases/jmix/load_field_messages_for_entity_use_case.dart';
import '../auth/foodie_session.dart';
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

final loadFieldMessagesForEntityUseCaseProvider =
    Provider<LoadFieldMessagesForEntityUseCase>((ref) {
  return LoadFieldMessagesForEntityUseCase(ref.watch(jmixRestConnectorProvider));
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
    AppLogger.logUserAction('home.selectEntity', name);
    state = HomeSelection(selectedEntityName: name, pageIndex: 0);
  }

  void clear() {
    AppLogger.logUserAction('home.clearSelection');
    state = const HomeSelection();
  }

  void setPage(int page) {
    AppLogger.logUserAction('home.setPage', '$page');
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
  return ref.read(loadFieldMessagesForEntityUseCaseProvider)(name);
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
    return ref.read(loadEntityListPageUseCaseProvider)(
      entityName: sel.selectedEntityName,
      pageIndex: sel.pageIndex,
    );
  }
}
