/// JSON for Jmix `GET entities/{name}/search` `filter` query parameter.
///
/// Uses a single `contains` condition (case depends on DB/collation).
Map<String, dynamic> entityListSearchContainsFilter(
  String property,
  String value,
) {
  return <String, dynamic>{
    'conditions': [
      <String, dynamic>{
        'property': property,
        'operator': 'contains',
        'value': value,
      },
    ],
  };
}
