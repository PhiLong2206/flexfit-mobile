import '../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  const VerifyEmailUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call({required String email, required String otpCode}) {
    return repository.verifyEmail(email: email, otpCode: otpCode);
  }
}
