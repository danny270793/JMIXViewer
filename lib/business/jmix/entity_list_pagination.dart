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

/// Short status line for infinite scroll (English; swap for l10n at call site if needed).
String entityListInfiniteSummary({
  required int loadedCount,
  required int? totalCount,
  required bool hasMore,
}) {
  if (totalCount != null) {
    if (!hasMore) return 'All $loadedCount of $totalCount rows';
    return '$loadedCount of $totalCount rows · scroll for more';
  }
  if (!hasMore) return '$loadedCount rows';
  return '$loadedCount rows · scroll for more';
}
