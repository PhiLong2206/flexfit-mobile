import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class GoogleLoginWithIdTokenUseCase {
  const GoogleLoginWithIdTokenUseCase(this.repository);

  final AuthRepository repository;

  Future<AuthSession> call(String idToken) {
    return repository.googleLoginWithIdToken(idToken);
  }
}
