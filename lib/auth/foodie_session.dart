import '../api/jmix/jmix_client_config.dart';
import '../api/jmix/jmix_oauth_connector.dart';
import '../api/jmix/jmix_rest_connector.dart';
import '../api/jmix/models/jmix_token.dart';
import '../config/foodie_jmix_config.dart';

/// Holds OAuth tokens and shared API clients for the configured Jmix backend.
final class FoodieSession {
  FoodieSession._() {
    configure(
      applicationBaseUri: Uri.parse(FoodieJmixConfig.applicationBase),
      clientId: FoodieJmixConfig.clientId,
      clientSecret: FoodieJmixConfig.clientSecret,
    );
  }

  static final FoodieSession instance = FoodieSession._();

  late JmixClientConfig _config;
  late JmixOAuthConnector _oauth;
  late JmixRestConnector _rest;
  late String _clientId;
  late String _clientSecret;

  JmixClientConfig get config => _config;

  JmixOAuthConnector get oauth => _oauth;

  JmixRestConnector get rest => _rest;

  JmixToken? token;

  /// Sets the application root URL and OAuth2 client credentials, then rebuilds connectors.
  void configure({
    required Uri applicationBaseUri,
    required String clientId,
    required String clientSecret,
  }) {
    _config = JmixClientConfig(applicationBaseUri: applicationBaseUri);
    _clientId = clientId;
    _clientSecret = clientSecret;
    _oauth = JmixOAuthConnector(config: _config);
    _rest = JmixRestConnector(
      config: _config,
      accessTokenProvider: () => token?.accessToken,
    );
  }

  /// OAuth2 client credentials (Basic auth + `grant_type=client_credentials`).
  Future<void> signInWithClientCredentials() async {
    token = await oauth.obtainTokenWithClientCredentials(
      clientId: _clientId,
      clientSecret: _clientSecret,
    );
  }

  void signOut() {
    token = null;
  }

  bool get isSignedIn => token != null;
}
