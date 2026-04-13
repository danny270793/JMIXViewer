import 'entity_list_search.dart';

/// Operators accepted by Jmix generic REST entity search filters (see REST docs).
const kEntityListSearchOperators = <String>[
  '=',
  '<>',
  '<',
  '<=',
  '>',
  '>=',
  'startsWith',
  'endsWith',
  'contains',
  'notEmpty',
  'isNull',
  'in',
  'notIn',
];

bool entityListSearchOperatorNeedsValue(String op) =>
    op != 'isNull' && op != 'notEmpty';

/// True when [search] should hit the search API (non-empty filter).
bool entityListSearchIsActive(EntityListSearch search) {
  final q = search.query.trim();
  switch (search.op) {
    case 'isNull':
    case 'notEmpty':
      return true;
    case 'in':
    case 'notIn':
      return entityListSearchParseInList(q).isNotEmpty;
    default:
      return q.isNotEmpty;
  }
}

/// Parses `in` / `notIn` user text (comma-separated).
List<dynamic> entityListSearchParseInList(String raw) {
  final parts = raw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
  if (parts.isEmpty) return const [];

  final out = <dynamic>[];
  for (final p in parts) {
    final i = int.tryParse(p);
    if (i != null) {
      out.add(i);
      continue;
    }
    final d = double.tryParse(p);
    if (d != null) {
      out.add(d);
      continue;
    }
    if (p.toLowerCase() == 'true') {
      out.add(true);
      continue;
    }
    if (p.toLowerCase() == 'false') {
      out.add(false);
      continue;
    }
    out.add(p);
  }
  return out;
}
