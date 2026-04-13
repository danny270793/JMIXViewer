import 'jmix_constants.dart';

/// Jmix `metadata/entities` items use `entityName` (OpenAPI `entityMetadata`).
String entityDisplayName(Map<String, dynamic> meta) {
  final name = meta['entityName'];
  if (name is String && name.isNotEmpty) return name;
  return '?';
}

/// Localized string for a key in a messages map (`GET messages/entities` or per-entity).
String? messageCaption(String key, Map<String, dynamic> messages) {
  final v = messages[key];
  if (v is String && v.trim().isNotEmpty) return v;
  return null;
}

String sidebarLabel(String entityName, Map<String, dynamic> messages) {
  final caption = messageCaption(entityName, messages);
  if (caption == null) return entityName;
  if (caption == entityName) return caption;
  return '$caption ($entityName)';
}

String sidebarSortKey(String entityName, Map<String, dynamic> messages) {
  return messageCaption(entityName, messages) ?? entityName;
}

String? attributeCaption(
  String attributeKey,
  String entityName,
  Map<String, dynamic> allEntityMessages,
  Map<String, dynamic>? fieldMessagesForEntity,
) {
  final per = fieldMessagesForEntity;
  if (per != null && per.isNotEmpty) {
    final c = messageCaption(attributeKey, per);
    if (c != null) return c;
  }
  final dotted = '$entityName.$attributeKey';
  String? c = messageCaption(dotted, allEntityMessages);
  c ??= messageCaption(attributeKey, allEntityMessages);
  return c;
}

String attributeSidebarLabel(
  String attributeKey,
  String entityName,
  Map<String, dynamic> allEntityMessages,
  Map<String, dynamic>? fieldMessagesForEntity,
) {
  final caption = attributeCaption(
    attributeKey,
    entityName,
    allEntityMessages,
    fieldMessagesForEntity,
  );
  if (caption == null) return attributeKey;
  if (caption == attributeKey) return caption;
  return '$caption ($attributeKey)';
}

String attributeSortKey(
  String attributeKey,
  String entityName,
  Map<String, dynamic> allEntityMessages,
  Map<String, dynamic>? fieldMessagesForEntity,
) {
  return attributeCaption(
        attributeKey,
        entityName,
        allEntityMessages,
        fieldMessagesForEntity,
      ) ??
      attributeKey;
}

List<String> entityRowColumnKeys(List<Map<String, dynamic>> items) {
  final keys = <String>{};
  for (final row in items) {
    keys.addAll(row.keys);
  }
  return keys.toList()..sort();
}

List<String> entityRowColumnKeysSortedByDisplay(
  List<Map<String, dynamic>> items,
  String entityName,
  Map<String, dynamic> allEntityMessages,
  Map<String, dynamic>? fieldMessagesForEntity,
) {
  final keys = entityRowColumnKeys(items);
  return [...keys]..sort(
        (a, b) => attributeSortKey(
              a,
              entityName,
              allEntityMessages,
              fieldMessagesForEntity,
            ).compareTo(
              attributeSortKey(
                b,
                entityName,
                allEntityMessages,
                fieldMessagesForEntity,
              ),
            ),
      );
}

/// Keys for expanded body (excludes instance-name field used as collapsed title).
List<String> entityRecordRestKeys(
  List<String> orderedColumnKeys,
) {
  return orderedColumnKeys
      .where((k) => k != kJmixInstanceNameField)
      .toList(growable: false);
}

/// Property `name` values from entity metadata, sorted by [attributeSortKey].
List<String> entityMetadataPropertyNamesSorted(
  Map<String, dynamic> entityMetadata,
  String entityName,
  Map<String, dynamic> allEntityMessages,
  Map<String, dynamic>? fieldMessagesForEntity,
) {
  final props = entityMetadata['properties'];
  final names = <String>[];
  if (props is List) {
    for (final p in props) {
      if (p is Map<String, dynamic>) {
        final n = p['name'];
        if (n is String && n.isNotEmpty) names.add(n);
      }
    }
  }
  names.sort(
    (a, b) => attributeSortKey(
          a,
          entityName,
          allEntityMessages,
          fieldMessagesForEntity,
        ).compareTo(
          attributeSortKey(
            b,
            entityName,
            allEntityMessages,
            fieldMessagesForEntity,
          ),
        ),
  );
  return names;
}

/// True if [entityMetadata] `properties` contains [propertyName].
bool entityMetadataHasProperty(
  Map<String, dynamic> entityMetadata,
  String propertyName,
) {
  final props = entityMetadata['properties'];
  if (props is! List) return false;
  for (final p in props) {
    if (p is Map<String, dynamic> && p['name'] == propertyName) {
      return true;
    }
  }
  return false;
}
