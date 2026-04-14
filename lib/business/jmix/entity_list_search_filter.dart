import 'entity_list_search_operators.dart';

/// JSON for Jmix `GET entities/{name}/search` `filter` query parameter.
Map<String, dynamic> entityListSearchRestFilter({
  required String property,
  required String op,
  required String query,
}) {
  switch (op) {
    case 'isNull':
    case 'notEmpty':
      return <String, dynamic>{
        'conditions': [
          <String, dynamic>{
            'property': property,
            'operator': op,
          },
        ],
      };
    case 'in':
    case 'notIn':
      return <String, dynamic>{
        'conditions': [
          <String, dynamic>{
            'property': property,
            'operator': op,
            'value': entityListSearchParseInList(query),
          },
        ],
      };
    default:
      return <String, dynamic>{
        'conditions': [
          <String, dynamic>{
            'property': property,
            'operator': op,
            'value': query.trim(),
          },
        ],
      };
  }
}
