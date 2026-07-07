import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  const ChangePasswordUseCase(this.repository);

  final AuthRepository repository;

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
