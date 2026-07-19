import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this.repository);

  final ProfileRepository repository;

  Future<Profile> call(Profile profile) async {
    return repository.updateProfile(profile);
  }
}
