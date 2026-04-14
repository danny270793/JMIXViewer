import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/use_cases/auth/sign_in_with_client_credentials_use_case.dart';
import '../auth/foodie_session.dart';

final signInWithClientCredentialsUseCaseProvider =
    Provider<SignInWithClientCredentialsUseCase>((ref) {
  return SignInWithClientCredentialsUseCase(FoodieSession.instance);
});
