import '../../../catalog/domain/entities/fitness_class.dart';
import '../repositories/partner_repository.dart';

class GetPartnerClassesUseCase {
  final PartnerRepository repository;

  GetPartnerClassesUseCase(this.repository);

  Future<List<FitnessClass>> call() {
    return repository.getClasses();
  }
}
