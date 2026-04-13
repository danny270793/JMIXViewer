import '../../../auth/foodie_session.dart';
import '../../../business/business_ops.dart';

/// OAuth2 client-credentials sign-in against the configured Jmix backend.
final class SignInWithClientCredentialsUseCase {
  SignInWithClientCredentialsUseCase(this._session);

  final FoodieSession _session;

  Future<void> call() {
    return BusinessOps.run('auth.signIn.clientCredentials', () async {
      await _session.signInWithClientCredentials();
    });
  }
}
