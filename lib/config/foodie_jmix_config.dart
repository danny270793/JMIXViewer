import '../api/jmix/jmix_client_config.dart';

/// Foodie deployment on Azure. REST and OAuth paths use [JmixClientConfig] defaults
/// (`/rest`, `/oauth2/token`).
///
/// **Note:** Shipping a `clientSecret` in a client app is insecure; prefer a
/// confidential backend or public-client flow for production.
class FoodieJmixConfig {
  FoodieJmixConfig._();

  static const String applicationBase = 'https://foodie.eastus2.cloudapp.azure.com';

  static const String clientId = 'c3c0353462';
  static const String clientSecret = '2fc9f1be5d7b0d18f25be642b3af1e5b';

  static JmixClientConfig get clientConfig => JmixClientConfig(
        applicationBaseUri: Uri.parse(applicationBase),
      );
}
