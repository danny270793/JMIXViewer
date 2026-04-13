import 'dart:convert';

/// Formats JSON field values for list/detail UI (no Flutter).
abstract final class EntityValueFormatting {
  EntityValueFormatting._();

  /// Short display (long JSON truncated).
  static String formatCell(dynamic value) {
    if (value == null) return '—';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    try {
      final s = jsonEncode(value);
      if (s.length > 200) return '${s.substring(0, 197)}…';
      return s;
    } catch (_) {
      return value.toString();
    }
  }

  /// Full text for tooltips (no 200-char cap).
  ///
  /// For entity detail/edit screens, prefer [formatDetailField] so [null] shows
  /// as the literal word `null`.
  static String formatFull(dynamic value) {
    if (value == null) return '—';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    try {
      return jsonEncode(value);
    } catch (_) {
      return value.toString();
    }
  }

  /// Full text for entity record view/edit: [null] renders as `null` (visible).
  static String formatDetailField(dynamic value) {
    if (value == null) return 'null';
    return formatFull(value);
  }
}
