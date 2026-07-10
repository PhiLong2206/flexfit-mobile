import '../../data/models/partner_review_model.dart';
import '../repositories/partner_repository.dart';

class GetPartnerReviewsUseCase {
  final PartnerRepository repository;

  GetPartnerReviewsUseCase(this.repository);

  Future<List<PartnerReviewModel>> call(String gymId) {
    return repository.getReviews(gymId);
  }
}
