/// Base URLs for a Jmix application.
///
/// The generic OpenAPI spec uses `servers: [ url: /rest ]` — the REST API is mounted
/// at `{applicationBase}/rest`. OAuth2 token endpoint defaults to `{applicationBase}/oauth2/token`
/// (Authorization Server add-on; override [tokenPath] if your server differs).
class JmixClientConfig {
  const JmixClientConfig({
    required this.applicationBaseUri,
    this.restPath = 'rest',
    this.tokenPath = 'oauth2/token',
  });

  /// Application root, e.g. `https://demo.example.com/app` or `http://localhost:8080`.
  final Uri applicationBaseUri;

  /// Path segment(s) for the REST API relative to [applicationBaseUri] (default `rest`).
  final String restPath;

  /// Path segment(s) for the OAuth2 token endpoint relative to [applicationBaseUri].
  final String tokenPath;

  Uri _join(Uri base, String relative) {
    final path = base.path;
    final normalized =
        path.endsWith('/') ? '$path$relative' : '$path/$relative';
    return base.replace(path: normalized);
  }

  /// Base URI for REST calls (OpenAPI server `/rest`).
  Uri get restBaseUri => _join(applicationBaseUri, restPath);

  /// URI for password / refresh token grants.
  Uri get tokenUri => _join(applicationBaseUri, tokenPath);
}
