import '../../../../core/network/api_client.dart';
import '../../../catalog/data/models/branch_model.dart';
import '../../../catalog/data/models/fitness_class_model.dart';
import '../../../catalog/data/models/gym_model.dart';
import '../models/partner_customer_model.dart';
import '../models/partner_dashboard_stats_model.dart';
import '../models/partner_promotion_model.dart';
import '../models/partner_revenue_report_model.dart';
import '../models/partner_review_model.dart';

abstract class PartnerRemoteDataSource {
  Future<PartnerDashboardStatsModel> getDashboardStats();
  Future<List<BranchModel>> getBranches();
  Future<List<FitnessClassModel>> getClasses();
  Future<void> createClass(Map<String, dynamic> body);
  Future<void> updateClass(String classId, Map<String, dynamic> body);
  Future<void> deleteClass(String classId);
  Future<List<GymModel>> getGyms();
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

class PartnerRemoteDataSourceImpl implements PartnerRemoteDataSource {
  final ApiClient _apiClient;

  PartnerRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<PartnerDashboardStatsModel> getDashboardStats() async {
    final response = await _apiClient.get('/partner/dashboard');
    return PartnerDashboardStatsModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  @override
  Future<List<BranchModel>> getBranches() async {
    final response = await _apiClient.get('/branches/partner');
    final List<BranchModel> list = [];
    if (response is List) {
      for (final item in response) {
        if (item is Map) {
          list.add(BranchModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return list;
  }

  @override
  Future<List<FitnessClassModel>> getClasses() async {
    final response = await _apiClient.get('/classes/partner');
    final List<FitnessClassModel> list = [];
    if (response is List) {
      for (final item in response) {
        if (item is Map) {
          list.add(FitnessClassModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return list;
  }

  @override
  Future<void> createClass(Map<String, dynamic> body) async {
    await _apiClient.post('/classes', body: body);
  }

  @override
  Future<void> updateClass(String classId, Map<String, dynamic> body) async {
    await _apiClient.put('/classes/$classId', body: body);
  }

  @override
  Future<void> deleteClass(String classId) async {
    await _apiClient.delete('/classes/$classId');
  }

  @override
  Future<List<GymModel>> getGyms() async {
    final response = await _apiClient.get('/gyms/partner');
    final List<GymModel> list = [];
    if (response is List) {
      for (final item in response) {
        if (item is Map) {
          list.add(GymModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return list;
  }

  @override
  Future<void> updateGym(String gymId, Map<String, dynamic> body) async {
    await _apiClient.put('/gyms/$gymId', body: body);
  }

  @override
  Future<List<PartnerCustomerModel>> getCustomers() async {
    final response = await _apiClient.get('/partner/customers');
    final List<PartnerCustomerModel> list = [];
    if (response is List) {
      for (final item in response) {
        if (item is Map) {
          list.add(PartnerCustomerModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return list;
  }

  @override
  Future<PartnerRevenueReportModel> getRevenueReport() async {
    final response = await _apiClient.get('/partner/revenue');
    return PartnerRevenueReportModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  @override
  Future<List<PartnerReviewModel>> getReviews(String gymId) async {
    final response = await _apiClient.get('/Review/gym/$gymId');
    final List<PartnerReviewModel> list = [];
    dynamic items = response;
    if (response is Map) {
      items = response['data'] ?? response['Data'] ?? response['items'] ?? response['Items'] ?? response['result'] ?? response['Result'] ?? response;
    }
    if (items is List) {
      for (final item in items) {
        if (item is Map) {
          list.add(PartnerReviewModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return list;
  }

  // Staff
  @override
  Future<void> assignStaff(String branchId, String email) async {
    await _apiClient.post('/partner/staff/assign-by-email', body: {
      'branchId': branchId,
      'email': email,
    });
  }

  @override
  Future<void> removeStaff(String branchId, String staffId) async {
    await _apiClient.delete('/branches/remove-staff?staffId=$staffId&branchId=$branchId');
  }

  // Branch CRUD
  @override
  Future<void> createBranch(Map<String, dynamic> body) async {
    await _apiClient.post('/branches', body: body);
  }

  @override
  Future<void> updateBranch(String branchId, Map<String, dynamic> body) async {
    await _apiClient.put('/branches/$branchId', body: body);
  }

  @override
  Future<void> deleteBranch(String branchId) async {
    await _apiClient.delete('/branches/$branchId');
  }

  // Promotions
  @override
  Future<List<PartnerPromotionModel>> getPromotions() async {
    final response = await _apiClient.get('/promotions?includeInactive=true');
    final List<PartnerPromotionModel> list = [];
    dynamic items = response;
    if (response is Map) {
      items = response['data'] ?? response['Data'] ?? response['items'] ?? response['Items'] ?? response['result'] ?? response['Result'] ?? response;
    }
    if (items is List) {
      for (final item in items) {
        if (item is Map) {
          list.add(PartnerPromotionModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return list;
  }

  @override
  Future<void> createPromotion(Map<String, dynamic> body) async {
    await _apiClient.post('/promotions', body: body);
  }

  @override
  Future<void> deletePromotion(String promotionId) async {
    await _apiClient.delete('/promotions/$promotionId');
  }
}
