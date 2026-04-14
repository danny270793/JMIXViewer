import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_providers.dart';

/// Full JSON from `GET metadata/entities/{entityName}` (includes `properties`).
final entityMetadataProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, entityName) {
    return ref.read(jmixRestConnectorProvider).metadataGetEntity(entityName);
  },
);

/// JSON from `GET metadata/enums/{enumClassName}` (includes `values`).
final enumMetadataProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, enumClassName) {
    return ref.read(jmixRestConnectorProvider).metadataGetEnum(enumClassName);
  },
);
