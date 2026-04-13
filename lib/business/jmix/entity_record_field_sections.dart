/// Groups entity JSON attribute keys into UI sections on the record detail screen.
abstract final class EntityRecordFieldSections {
  EntityRecordFieldSections._();

  /// Jmix / framework-style fields (fixed order when present).
  static const frameworkFieldOrder = <String>[
    '_entityName',
    '_instanceName',
    'version',
  ];

  /// Audit / soft-delete style fields (fixed order when present).
  static const softDeleteFieldOrder = <String>[
    'createdBy',
    'createdDate',
    'deletedBy',
    'deletedDate',
    'lastModifiedBy',
    'lastModifiedDate',
  ];

  static const _frameworkSet = {'_entityName', '_instanceName', 'version'};
  static const _softDeleteSet = {
    'createdBy',
    'createdDate',
    'deletedBy',
    'deletedDate',
    'lastModifiedBy',
    'lastModifiedDate',
  };

  /// Splits [orderedKeys] (e.g. from [entityRowColumnKeysSortedByDisplay]) into
  /// framework, soft-delete, and application buckets. Application preserves
  /// the relative order from [orderedKeys].
  static EntityRecordKeySections partition(List<String> orderedKeys) {
    final keySet = orderedKeys.toSet();

    final framework = <String>[
      for (final k in frameworkFieldOrder)
        if (keySet.contains(k)) k,
    ];

    final softDelete = <String>[
      for (final k in softDeleteFieldOrder)
        if (keySet.contains(k)) k,
    ];

    final application = <String>[
      for (final k in orderedKeys)
        if (!_frameworkSet.contains(k) && !_softDeleteSet.contains(k)) k,
    ];

    return EntityRecordKeySections(
      framework: framework,
      softDelete: softDelete,
      application: application,
    );
  }
}

/// Result of [EntityRecordFieldSections.partition].
final class EntityRecordKeySections {
  const EntityRecordKeySections({
    required this.framework,
    required this.softDelete,
    required this.application,
  });

  final List<String> framework;
  final List<String> softDelete;
  final List<String> application;
}
