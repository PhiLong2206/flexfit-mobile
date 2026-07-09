import '../../../catalog/domain/entities/branch.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../entities/admin_entities.dart';

abstract class AdminRepository {
  Future<AdminDashboardData> getDashboardData();
  Future<List<AdminUser>> getUsers();
  Future<List<Gym>> getGyms();
  Future<List<Branch>> getBranches();
  Future<List<Category>> getCategories();
  Future<AdminUtilityData> getUtilityData();
  Future<AdminRevenueSummary> getRevenueSummary();
  Future<List<AdminPaymentHistory>> getPaymentHistory();
  Future<AdminSystemLogsPage> getSystemLogs({int pageNumber = 1});

  Future<void> updateUser({
    required String userId,
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? dateOfBirth,
  });
  Future<void> changeUserStatus({
    required String userId,
    required bool isActive,
  });
  Future<void> deleteUser(String userId);
  Future<void> assignRole({
    required String userId,
    required String roleName,
    String? gymId,
    String? branchId,
  });
  Future<void> revokeRole({required String userId, required String roleName});

  Future<void> createGym({
    required String ownerId,
    required String gymName,
    String? description,
    String? thumbnailUrl,
    String? phoneNumber,
    String? email,
  });
  Future<void> changeGymStatus({required String gymId, required String status});

  Future<void> createCategory({
    required String categoryName,
    String? description,
  });
  Future<void> updateCategory({
    required String categoryId,
    required String categoryName,
    String? description,
  });
  Future<void> deleteCategory(String categoryId);

  Future<void> createCreditPackage({
    required String packageName,
    required int creditAmount,
    required double price,
    String? description,
  });
  Future<void> updateCreditPackage({
    required String packageId,
    String? packageName,
    int? creditAmount,
    double? price,
    String? description,
  });
  Future<void> deleteCreditPackage(String packageId);
}
