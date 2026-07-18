import '../repositories/partner_repository.dart';

class DeleteClassUseCase {
  final PartnerRepository repository;

  DeleteClassUseCase(this.repository);

  Future<void> call(String classId) {
    return repository.deleteClass(classId);
  }
}
