import '../../../api/jmix/jmix_rest_connector.dart';
import '../../../api/jmix/models/jmix_entity_list_result.dart';
import '../../../business/jmix/entity_list_pagination.dart';
import '../../../business/jmix/entity_list_search.dart';
import '../../../business/jmix/entity_list_search_filter.dart';
import '../../../business/jmix/entity_list_search_operators.dart';
import '../../business_use_case.dart';

/// Loads one page of rows for a Jmix generic entity list.
final class LoadEntityListPageUseCase extends BusinessUseCase {
  LoadEntityListPageUseCase(this._rest) : super();

  final JmixRestConnector _rest;

  /// Returns `null` when no entity is selected (no request).
  Future<JmixEntityListResult?> call({
    required String? entityName,
    required int pageIndex,
    String? sort,
    EntityListSearch? search,
  }) {
    return run('home.entityList', () async {
      if (entityName == null) return null;
      if (search != null && entityListSearchIsActive(search)) {
        return _rest.searchEntitiesPost(
          entityName,
          entityListSearchRestFilter(
            property: search.fieldKey,
            op: search.op,
            query: search.query,
          ),
          limit: '$kDefaultEntityPageSize',
          offset: '${pageIndex * kDefaultEntityPageSize}',
          sort: sort,
          returnCount: true,
        );
      }
      return _rest.loadEntities(
        entityName,
        limit: '$kDefaultEntityPageSize',
        offset: '${pageIndex * kDefaultEntityPageSize}',
        sort: sort,
        returnCount: true,
      );
    });
  }
}
