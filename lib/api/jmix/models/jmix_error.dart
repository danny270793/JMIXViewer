/// Error payload from Jmix REST (`components.schemas.error` in the OpenAPI spec).
class JmixError {
  const JmixError({this.error, this.details});

  final String? error;
  final String? details;

  factory JmixError.fromJson(Map<String, dynamic> json) {
    return JmixError(
      error: json['error'] as String?,
      details: json['details'] as String?,
    );
  }
}

/// Prefer non-empty [details], then [error] (e.g. `{ "error": "Server error", "details": "" }`).
String jmixErrorUserMessage(JmixError err) {
  final d = err.details?.trim();
  final e = err.error?.trim();
  if (d != null && d.isNotEmpty) return d;
  if (e != null && e.isNotEmpty) return e;
  return 'Request failed';
}

/// Bean-validation style JSON array from failed POST/PUT (field `path` + `message`).
String formatJmixValidationErrorList(List<dynamic> data) {
  final parts = <String>[];
  for (final e in data) {
    if (e is! Map) continue;
    final m = Map<String, dynamic>.from(e);
    final path = m['path']?.toString();
    final message = m['message']?.toString();
    if (path != null &&
        path.isNotEmpty &&
        message != null &&
        message.isNotEmpty) {
      parts.add('$path: $message');
    } else if (message != null && message.isNotEmpty) {
      parts.add(message);
    }
  }
  if (parts.isEmpty) return 'Validation failed';
  return parts.join('; ');
}

/// OAuth token error (`components.schemas.oauthError`).
class JmixOAuthError {
  const JmixOAuthError({this.error, this.errorDescription});

  final String? error;
  final String? errorDescription;

  factory JmixOAuthError.fromJson(Map<String, dynamic> json) {
    return JmixOAuthError(
      error: json['error'] as String?,
      errorDescription: json['error_description'] as String?,
    );
  }
}
