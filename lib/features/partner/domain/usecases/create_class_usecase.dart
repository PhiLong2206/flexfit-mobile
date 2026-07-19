import '../repositories/partner_repository.dart';

class CreateClassUseCase {
  final PartnerRepository repository;

  CreateClassUseCase(this.repository);

  Future<void> call(Map<String, dynamic> body) {
    return repository.createClass(body);
  }
}
