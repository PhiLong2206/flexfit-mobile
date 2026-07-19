import '../../data/models/partner_dashboard_stats_model.dart';
import '../repositories/partner_repository.dart';

class GetPartnerDashboardStatsUseCase {
  final PartnerRepository repository;

  GetPartnerDashboardStatsUseCase(this.repository);

  Future<PartnerDashboardStatsModel> call() {
    return repository.getDashboardStats();
  }
}
