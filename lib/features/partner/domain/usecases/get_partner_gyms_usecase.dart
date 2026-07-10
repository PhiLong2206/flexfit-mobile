import '../../../catalog/domain/entities/gym.dart';
import '../repositories/partner_repository.dart';

class GetPartnerGymsUseCase {
  final PartnerRepository repository;

  GetPartnerGymsUseCase(this.repository);

  Future<List<Gym>> call() {
    return repository.getGyms();
  }
}
