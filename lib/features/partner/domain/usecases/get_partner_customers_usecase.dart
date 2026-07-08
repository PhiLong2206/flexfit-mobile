import '../../data/models/partner_customer_model.dart';
import '../repositories/partner_repository.dart';

class GetPartnerCustomersUseCase {
  final PartnerRepository repository;

  GetPartnerCustomersUseCase(this.repository);

  Future<List<PartnerCustomerModel>> call() {
    return repository.getCustomers();
  }
}
