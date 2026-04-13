import 'entity_value_formatting.dart';
import 'jmix_constants.dart';

/// Collapsed row title / tooltip for an entity JSON record row.
abstract final class EntityRecordCollapseTitles {
  EntityRecordCollapseTitles._();

  static String titleText(
    Map<String, dynamic> row,
    List<String> orderedColumnKeys,
  ) {
    final v = row[kJmixInstanceNameField];
    if (v != null) {
      final s = EntityValueFormatting.formatCell(v);
      if (s != '—' && s.trim().isNotEmpty) return s;
    }
    if (row['id'] != null) {
      return EntityValueFormatting.formatCell(row['id']);
    }
    if (orderedColumnKeys.isNotEmpty) {
      return EntityValueFormatting.formatCell(row[orderedColumnKeys.first]);
    }
    return '—';
  }

  static String titleTooltip(
    Map<String, dynamic> row,
    List<String> orderedColumnKeys,
  ) {
    final v = row[kJmixInstanceNameField];
    if (v != null) return EntityValueFormatting.formatFull(v);
    if (row['id'] != null) return EntityValueFormatting.formatFull(row['id']);
    if (orderedColumnKeys.isNotEmpty) {
      return EntityValueFormatting.formatFull(row[orderedColumnKeys.first]);
    }
    return '—';
  }
}
