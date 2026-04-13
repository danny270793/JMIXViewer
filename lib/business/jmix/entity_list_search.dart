import 'package:flutter/foundation.dart';

/// Active generic entity list search (`GET entities/{name}/search` with filter).
@immutable
class EntityListSearch {
  const EntityListSearch({
    required this.fieldKey,
    required this.query,
  });

  final String fieldKey;
  final String query;
}
