import '../api/jmix/jmix_client_config.dart';
import '../api/jmix/jmix_oauth_connector.dart';
import '../api/jmix/jmix_rest_connector.dart';
import '../api/jmix/models/jmix_token.dart';
import '../config/foodie_jmix_config.dart';

/// Holds OAuth tokens and shared API clients for the Foodie Jmix backend.
final class FoodieSession {
  FoodieSession._();

  static final FoodieSession instance = FoodieSession._();

  final JmixClientConfig config = FoodieJmixConfig.clientConfig;

  late final JmixOAuthConnector oauth = JmixOAuthConnector(config: config);

  JmixToken? token;

  late final JmixRestConnector rest = JmixRestConnector(
    config: config,
    accessTokenProvider: () => token?.accessToken,
  );

  /// OAuth2 client credentials (Basic auth + `grant_type=client_credentials`).
  Future<void> signInWithClientCredentials() async {
    token = await oauth.obtainTokenWithClientCredentials(
      clientId: FoodieJmixConfig.clientId,
      clientSecret: FoodieJmixConfig.clientSecret,
    );
  }

  void signOut() {
    token = null;
  }

  bool get isSignedIn => token != null;
}
