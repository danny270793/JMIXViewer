import 'package:flutter/foundation.dart';

/// Active generic entity list search (`GET entities/{name}/search` with filter).
@immutable
class EntityListSearch {
  const EntityListSearch({
    required this.fieldKey,
    required this.op,
    required this.query,
  });

  final String fieldKey;
  /// Jmix REST filter operator (e.g. `=`, `contains`, `isNull`, `in`).
  final String op;
  final String query;
}
