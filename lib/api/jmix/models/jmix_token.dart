/// OAuth2 token response (`components.schemas.token` in the OpenAPI spec).
class JmixToken {
  const JmixToken({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn,
    this.scope,
  });

  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int? expiresIn;
  final String? scope;

  factory JmixToken.fromJson(Map<String, dynamic> json) {
    final expires = json['expires_in'];
    int? expiresIn;
    if (expires is int) {
      expiresIn = expires;
    } else if (expires is String) {
      expiresIn = int.tryParse(expires);
    }

    return JmixToken(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      tokenType: (json['token_type'] as String?) ?? 'Bearer',
      expiresIn: expiresIn,
      scope: json['scope'] as String?,
    );
  }
}
