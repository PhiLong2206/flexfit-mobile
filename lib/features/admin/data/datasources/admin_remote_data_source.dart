import '../../../../core/network/api_client.dart';
import '../../domain/entities/admin_entities.dart';
import '../models/admin_models.dart';

abstract class AdminRemoteDataSource {
  Future<List<AdminUserModel>> getUsers();
  Future<List<dynamic>> getRawGyms();
  Future<List<dynamic>> getRawBranches();
  Future<List<dynamic>> getRawCategories();
  Future<List<dynamic>> getRawCreditPackages();
  Future<AdminRevenueSummaryModel> getRevenueSummary();
  Future<List<AdminPaymentHistoryModel>> getPaymentHistory();
  Future<AdminSystemLogsPage> getSystemLogs({int pageNumber = 1});
  Future<void> updateUser(String userId, Map<String, dynamic> body);
  Future<void> changeUserStatus(String userId, bool isActive);
  Future<void> deleteUser(String userId);
  Future<void> assignRole(Map<String, dynamic> body);
  Future<void> revokeRole({required String userId, required String roleName});
  Future<void> createGym(Map<String, dynamic> body);
  Future<void> changeGymStatus(String gymId, String status);
  Future<void> createCategory(Map<String, dynamic> body);
  Future<void> updateCategory(String categoryId, Map<String, dynamic> body);
  Future<void> deleteCategory(String categoryId);
  Future<void> createCreditPackage(Map<String, dynamic> body);
  Future<void> updateCreditPackage(String packageId, Map<String, dynamic> body);
  Future<void> deleteCreditPackage(String packageId);
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  AdminRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<AdminUserModel>> getUsers() async {
    final response = await _apiClient.get('/users');
    return adminUsersFromResponse(response);
  }

  @override
  Future<List<dynamic>> getRawGyms() async {
    final response = await _apiClient.get('/gyms');
    return _readRawList(response);
  }

  @override
  Future<List<dynamic>> getRawBranches() async {
    final response = await _apiClient.get('/branches');
    return _readRawList(response);
  }

  @override
  Future<List<dynamic>> getRawCategories() async {
    final response = await _apiClient.get('/categories');
    return _readRawList(response);
  }

  @override
  Future<List<dynamic>> getRawCreditPackages() async {
    final response = await _apiClient.get('/credit-packages');
    return _readRawList(response);
  }

  @override
  Future<AdminRevenueSummaryModel> getRevenueSummary() async {
    final response = await _apiClient.get('/admin/revenue/summary');
    if (response is Map) {
      return AdminRevenueSummaryModel.fromJson(
        Map<String, dynamic>.from(response),
      );
    }
    return const AdminRevenueSummaryModel(
      totalRevenueThisMonth: 0,
      successfulPaymentCount: 0,
      totalCreditsPaid: 0,
      revenueToday: 0,
      monthlyRevenue: [],
      packageSales: [],
    );
  }

  @override
  Future<List<AdminPaymentHistoryModel>> getPaymentHistory() async {
    final response = await _apiClient.get('/payment/admin/history');
    return adminPaymentsFromResponse(response);
  }

  @override
  Future<AdminSystemLogsPage> getSystemLogs({int pageNumber = 1}) async {
    final response = await _apiClient.get(
      '/SystemLog?pageNumber=$pageNumber&pageSize=20',
    );
    return adminLogsFromResponse(response);
  }

  @override
  Future<void> updateUser(String userId, Map<String, dynamic> body) async {
    await _apiClient.put('/users/$userId', body: body);
  }

  @override
  Future<void> changeUserStatus(String userId, bool isActive) async {
    await _apiClient.patch('/users/$userId/status', body: isActive);
  }

  @override
  Future<void> deleteUser(String userId) async {
    await _apiClient.delete('/users/$userId');
  }

  @override
  Future<void> assignRole(Map<String, dynamic> body) async {
    await _apiClient.post('/users/assign-role', body: body);
  }

  @override
  Future<void> revokeRole({
    required String userId,
    required String roleName,
  }) async {
    final role = Uri.encodeQueryComponent(roleName);
    await _apiClient.delete('/users/revoke-role?userId=$userId&roleName=$role');
  }

  @override
  Future<void> createGym(Map<String, dynamic> body) async {
    await _apiClient.post('/gyms', body: body);
  }

  @override
  Future<void> changeGymStatus(String gymId, String status) async {
    await _apiClient.patch('/gyms/$gymId/status', body: status);
  }

  @override
  Future<void> createCategory(Map<String, dynamic> body) async {
    await _apiClient.post('/categories', body: body);
  }

  @override
  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> body,
  ) async {
    await _apiClient.put('/categories/$categoryId', body: body);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    await _apiClient.delete('/categories/$categoryId');
  }

  @override
  Future<void> createCreditPackage(Map<String, dynamic> body) async {
    await _apiClient.post('/credit-packages', body: body);
  }

  @override
  Future<void> updateCreditPackage(
    String packageId,
    Map<String, dynamic> body,
  ) async {
    await _apiClient.put('/credit-packages/$packageId', body: body);
  }

  @override
  Future<void> deleteCreditPackage(String packageId) async {
    await _apiClient.delete('/credit-packages/$packageId');
  }

  List<dynamic> _readRawList(dynamic response) {
    if (response is List) return response;
    if (response is Map) {
      final data =
          response['data'] ??
          response['Data'] ??
          response['items'] ??
          response['Items'];
      if (data is List) return data;
    }
    return const [];
  }
}
