/// Result of list/search/query calls that may return [X-Total-Count].
class JmixEntityListResult {
  const JmixEntityListResult({required this.items, this.totalCount});

  final List<Map<String, dynamic>> items;
  final int? totalCount;
}

/// Parsed file descriptor after upload (`components.schemas.fileInfo`).
class JmixFileInfo {
  const JmixFileInfo({required this.id, this.name, this.size});

  final String id;
  final String? name;
  final double? size;

  factory JmixFileInfo.fromJson(Map<String, dynamic> json) {
    return JmixFileInfo(
      id: json['id'] as String,
      name: json['name'] as String?,
      size: (json['size'] as num?)?.toDouble(),
    );
  }
}

/// Current user (`components.schemas.userInfo`).
class JmixUserInfo {
  const JmixUserInfo({this.username, this.locale, this.attributes});

  final String? username;
  final String? locale;
  final Map<String, dynamic>? attributes;

  factory JmixUserInfo.fromJson(Map<String, dynamic> json) {
    final raw = json['attributes'];
    return JmixUserInfo(
      username: json['username'] as String?,
      locale: json['locale'] as String?,
      attributes: raw is Map ? Map<String, dynamic>.from(raw) : null,
    );
  }
}
