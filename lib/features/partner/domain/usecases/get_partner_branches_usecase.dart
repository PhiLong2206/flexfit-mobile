import '../../../catalog/domain/entities/branch.dart';
import '../repositories/partner_repository.dart';

class GetPartnerBranchesUseCase {
  final PartnerRepository repository;

  GetPartnerBranchesUseCase(this.repository);

  Future<List<Branch>> call() {
    return repository.getBranches();
  }
}
