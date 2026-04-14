import '../../api/jmix/models/jmix_entity_list_result.dart';

const int kDefaultEntityPageSize = 20;

bool entityListHasNextPage({
  required int pageIndex,
  required int pageSize,
  required JmixEntityListResult result,
}) {
  final total = result.totalCount;
  final end = pageIndex * pageSize + result.items.length;
  if (total != null) {
    return end < total;
  }
  return result.items.length == pageSize;
}

/// Label for the bottom pagination bar (English; swap for l10n at call site if needed).
String entityListPaginationBarLabel({
  required int pageIndex,
  required int pageSize,
  required int itemCount,
  required int? totalCount,
}) {
  final start = pageIndex * pageSize + (itemCount > 0 ? 1 : 0);
  final end = pageIndex * pageSize + itemCount;
  if (totalCount != null) {
    return itemCount > 0
        ? 'Rows $start–$end of $totalCount'
        : 'Page ${pageIndex + 1}';
  }
  return itemCount > 0 ? 'Rows $start–$end' : 'No rows';
}
