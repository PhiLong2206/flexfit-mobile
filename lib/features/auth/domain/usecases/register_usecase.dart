import '../repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) {
    return repository.register(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );
  }
}
