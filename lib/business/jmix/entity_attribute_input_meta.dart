/// How to edit a single attribute in the generic entity detail form, derived from
/// `GET metadata/entities/{entityName}` (`properties[].attributeType`, `type`, …).
enum AttributeInputKind {
  readOnlyDisplay,
  plainString,
  multilineString,
  integer,
  decimal,
  boolean,
  date,
  dateTime,
  time,
  uuid,
  enumDropdown,
  referenceManyToOne,
  collectionJson,
  jsonBlob,
}

/// Indexed metadata for one attribute from `properties[]`.
final class ParsedAttributeMeta {
  const ParsedAttributeMeta({
    required this.name,
    required this.kind,
    this.enumClassName,
    this.referenceEntityType,
    this.mandatory = false,
  });

  final String name;
  final AttributeInputKind kind;
  final String? enumClassName;
  final String? referenceEntityType;

  /// From metadata `properties[].mandatory` (Bean Validation / required attributes).
  final bool mandatory;

  /// Builds [propertyByName] from raw entity metadata JSON (`properties` list).
  static Map<String, Map<String, dynamic>> propertyMapFromEntityMeta(
    Map<String, dynamic> entityMetadata,
  ) {
    final props = entityMetadata['properties'];
    final out = <String, Map<String, dynamic>>{};
    if (props is! List) return out;
    for (final p in props) {
      if (p is Map<String, dynamic>) {
        final n = p['name'];
        if (n is String && n.isNotEmpty) {
          out[n] = p;
        }
      }
    }
    return out;
  }

  /// Puts attributes with `mandatory: true` first; preserves relative order within each group.
  static List<String> sortFieldKeysMandatoryFirst(
    List<String> keys,
    Map<String, Map<String, dynamic>>? propertyByName,
  ) {
    if (propertyByName == null || propertyByName.isEmpty) {
      return List<String>.from(keys);
    }
    final mandatory = <String>[];
    final optional = <String>[];
    for (final k in keys) {
      if (propertyByName[k]?['mandatory'] == true) {
        mandatory.add(k);
      } else {
        optional.add(k);
      }
    }
    return [...mandatory, ...optional];
  }

  /// When [entityMetadataAvailable] is true, the catalog from
  /// `GET metadata/entities/{entityName}` was loaded: only attributes listed
  /// in `properties` are editable; any other key on the row is read-only.
  ///
  /// When metadata failed to load ([entityMetadataAvailable] false), [property]
  /// is always null and [fallbackFromValue] is used so the form stays usable.
  static ParsedAttributeMeta forField({
    required String fieldName,
    Map<String, dynamic>? property,
    required dynamic currentValue,
    bool entityMetadataAvailable = false,
  }) {
    if (fieldName == 'id' || fieldName == 'version') {
      return ParsedAttributeMeta(
        name: fieldName,
        kind: AttributeInputKind.readOnlyDisplay,
        mandatory: property?['mandatory'] == true,
      );
    }
    if (entityMetadataAvailable) {
      if (property == null) {
        return ParsedAttributeMeta(
          name: fieldName,
          kind: AttributeInputKind.readOnlyDisplay,
        );
      }
      return fromProperty(property);
    }
    if (property != null) {
      return fromProperty(property);
    }
    return fallbackFromValue(fieldName, currentValue);
  }

  static ParsedAttributeMeta fromProperty(Map<String, dynamic> p) {
    final name = p['name'] as String? ?? '';
    final mandatory = p['mandatory'] == true;
    if (name == 'version') {
      return ParsedAttributeMeta(
        name: name,
        kind: AttributeInputKind.readOnlyDisplay,
        mandatory: mandatory,
      );
    }
    if (p['readOnly'] == true) {
      return ParsedAttributeMeta(
        name: name,
        kind: AttributeInputKind.readOnlyDisplay,
        mandatory: mandatory,
      );
    }

    final attrType = p['attributeType'] as String?;
    final type = (p['type'] as String?) ?? '';
    final card = p['cardinality'] as String? ?? 'NONE';

    switch (attrType) {
      case 'ENUM':
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.enumDropdown,
          enumClassName: type,
          mandatory: mandatory,
        );
      case 'ASSOCIATION':
      case 'COMPOSITION':
        if (card == 'ONE_TO_MANY' || card == 'MANY_TO_MANY') {
          return ParsedAttributeMeta(
            name: name,
            kind: AttributeInputKind.collectionJson,
            referenceEntityType: type,
            mandatory: mandatory,
          );
        }
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.referenceManyToOne,
          referenceEntityType: type,
          mandatory: mandatory,
        );
      case 'DATATYPE':
        return _fromDatatype(name, type, mandatory: mandatory);
      default:
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.jsonBlob,
          mandatory: mandatory,
        );
    }
  }

  static ParsedAttributeMeta _fromDatatype(
    String name,
    String type, {
    required bool mandatory,
  }) {
    final t = type.toLowerCase();
    switch (t) {
      case 'boolean':
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.boolean,
          mandatory: mandatory,
        );
      case 'int':
      case 'integer':
      case 'long':
      case 'short':
      case 'byte':
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.integer,
          mandatory: mandatory,
        );
      case 'double':
      case 'float':
      case 'decimal':
      case 'bigdecimal':
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.decimal,
          mandatory: mandatory,
        );
      case 'localdate':
      case 'date':
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.date,
          mandatory: mandatory,
        );
      case 'localdatetime':
      case 'offsetdatetime':
      case 'datetime':
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.dateTime,
          mandatory: mandatory,
        );
      case 'localtime':
      case 'offsettime':
      case 'time':
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.time,
          mandatory: mandatory,
        );
      case 'uuid':
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.uuid,
          mandatory: mandatory,
        );
      case 'string':
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.plainString,
          mandatory: mandatory,
        );
      case 'text':
      case 'clob':
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.multilineString,
          mandatory: mandatory,
        );
      default:
        return ParsedAttributeMeta(
          name: name,
          kind: AttributeInputKind.jsonBlob,
          mandatory: mandatory,
        );
    }
  }

  static ParsedAttributeMeta fallbackFromValue(String fieldName, dynamic value) {
    if (fieldName == 'version') {
      return const ParsedAttributeMeta(
        name: 'version',
        kind: AttributeInputKind.readOnlyDisplay,
      );
    }
    if (value is bool) {
      return ParsedAttributeMeta(name: fieldName, kind: AttributeInputKind.boolean);
    }
    if (value is int) {
      return ParsedAttributeMeta(name: fieldName, kind: AttributeInputKind.integer);
    }
    if (value is double) {
      return ParsedAttributeMeta(name: fieldName, kind: AttributeInputKind.decimal);
    }
    if (value is num) {
      return ParsedAttributeMeta(name: fieldName, kind: AttributeInputKind.decimal);
    }
    if (value is String) {
      return ParsedAttributeMeta(name: fieldName, kind: AttributeInputKind.plainString);
    }
    return ParsedAttributeMeta(name: fieldName, kind: AttributeInputKind.jsonBlob);
  }
}
