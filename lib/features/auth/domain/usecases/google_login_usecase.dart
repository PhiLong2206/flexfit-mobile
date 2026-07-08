import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class GoogleLoginUseCase {
  const GoogleLoginUseCase(this.repository);

  final AuthRepository repository;

  Future<AuthSession> call() {
    return repository.googleLogin();
  }
}
