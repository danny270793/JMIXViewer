import '../../../auth/foodie_session.dart';
import '../../business_use_case.dart';

/// OAuth2 client-credentials sign-in against the configured Jmix backend.
final class SignInWithClientCredentialsUseCase extends BusinessUseCase {
  SignInWithClientCredentialsUseCase(this._session) : super();

  final FoodieSession _session;

  Future<void> call() {
    return run('auth.signIn.clientCredentials', () async {
      await _session.signInWithClientCredentials();
    });
  }
}
