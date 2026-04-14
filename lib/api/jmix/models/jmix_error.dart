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
