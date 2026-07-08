import '../../../catalog/domain/entities/branch.dart';
import '../../../catalog/domain/entities/fitness_class.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../data/models/partner_customer_model.dart';
import '../../data/models/partner_dashboard_stats_model.dart';
import '../../data/models/partner_promotion_model.dart';
import '../../data/models/partner_revenue_report_model.dart';
import '../../data/models/partner_review_model.dart';

abstract class PartnerRepository {
  Future<PartnerDashboardStatsModel> getDashboardStats();
  Future<List<Branch>> getBranches();
  Future<List<FitnessClass>> getClasses();
  Future<void> createClass(Map<String, dynamic> body);
  Future<void> updateClass(String classId, Map<String, dynamic> body);
  Future<void> deleteClass(String classId);
  Future<List<Gym>> getGyms();
  Future<void> updateGym(String gymId, Map<String, dynamic> body);
  Future<List<PartnerCustomerModel>> getCustomers();
  Future<PartnerRevenueReportModel> getRevenueReport();
  Future<List<PartnerReviewModel>> getReviews(String gymId);

  // Staff
  Future<void> assignStaff(String branchId, String email);
  Future<void> removeStaff(String branchId, String staffId);

  // Branch CRUD
  Future<void> createBranch(Map<String, dynamic> body);
  Future<void> updateBranch(String branchId, Map<String, dynamic> body);
  Future<void> deleteBranch(String branchId);

  // Promotions
  Future<List<PartnerPromotionModel>> getPromotions();
  Future<void> createPromotion(Map<String, dynamic> body);
  Future<void> deletePromotion(String promotionId);
}
