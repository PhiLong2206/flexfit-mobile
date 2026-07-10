import '../../../../core/network/api_client.dart';
import '../../../catalog/domain/entities/branch.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/gym.dart';
import '../../../membership/data/models/credit_package_model.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_data_source.dart';
import '../models/admin_models.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl({required AdminRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  final AdminRemoteDataSource _remoteDataSource;

  @override
  Future<AdminDashboardData> getDashboardData() async {
    final usersFuture = getUsers();
    final gymsFuture = getGyms();
    final branchesFuture = getBranches();
    final revenueFuture = _nullableRevenueSummary();
    final paymentsFuture = _nullablePaymentHistory();

    return AdminDashboardData(
      users: await usersFuture,
      gyms: await gymsFuture,
      branches: await branchesFuture,
      revenue: await revenueFuture,
      payments: await paymentsFuture,
    );
  }

  @override
  Future<List<AdminUser>> getUsers() => _remoteDataSource.getUsers();

  @override
  Future<List<Gym>> getGyms() async {
    final raw = await _remoteDataSource.getRawGyms();
    return adminGymsFromResponse(raw);
  }

  @override
  Future<List<Branch>> getBranches() async {
    final raw = await _remoteDataSource.getRawBranches();
    return adminBranchesFromResponse(raw);
  }

  @override
  Future<List<Category>> getCategories() async {
    final raw = await _remoteDataSource.getRawCategories();
    return adminCategoriesFromResponse(raw);
  }

  @override
  Future<AdminUtilityData> getUtilityData() async {
    final categoriesFuture = getCategories();
    final packagesFuture = _nullableCreditPackages();

    return AdminUtilityData(
      categories: await categoriesFuture,
      creditPackages: await packagesFuture,
    );
  }

  @override
  Future<AdminRevenueSummary> getRevenueSummary() {
    return _remoteDataSource.getRevenueSummary();
  }

  @override
  Future<List<AdminPaymentHistory>> getPaymentHistory() {
    return _remoteDataSource.getPaymentHistory();
  }

  @override
  Future<AdminSystemLogsPage> getSystemLogs({int pageNumber = 1}) {
    return _remoteDataSource.getSystemLogs(pageNumber: pageNumber);
  }

  @override
  Future<void> updateUser({
    required String userId,
    required String fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? dateOfBirth,
  }) {
    return _remoteDataSource.updateUser(
      userId,
      _cleanBody({
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'avatarUrl': avatarUrl,
        'dateOfBirth': dateOfBirth,
      }),
    );
  }

  @override
  Future<void> changeUserStatus({
    required String userId,
    required bool isActive,
  }) {
    return _remoteDataSource.changeUserStatus(userId, isActive);
  }

  @override
  Future<void> deleteUser(String userId) {
    return _remoteDataSource.deleteUser(userId);
  }

  @override
  Future<void> assignRole({
    required String userId,
    required String roleName,
    String? gymId,
    String? branchId,
  }) {
    return _remoteDataSource.assignRole(
      _cleanBody({
        'userId': userId,
        'roleName': roleName,
        'role': roleName,
        'gymId': gymId,
        'branchId': branchId,
      }),
    );
  }

  @override
  Future<void> revokeRole({required String userId, required String roleName}) {
    return _remoteDataSource.revokeRole(userId: userId, roleName: roleName);
  }

  @override
  Future<void> createGym({
    required String ownerId,
    required String gymName,
    String? description,
    String? thumbnailUrl,
    String? phoneNumber,
    String? email,
  }) {
    return _remoteDataSource.createGym(
      _cleanBody({
        'ownerId': ownerId,
        'gymName': gymName,
        'description': description,
        'thumbnailUrl': thumbnailUrl,
        'phoneNumber': phoneNumber,
        'email': email,
      }),
    );
  }

  @override
  Future<void> changeGymStatus({
    required String gymId,
    required String status,
  }) {
    return _remoteDataSource.changeGymStatus(gymId, status);
  }

  @override
  Future<void> createCategory({
    required String categoryName,
    String? description,
  }) {
    return _remoteDataSource.createCategory(
      _cleanBody({'categoryName': categoryName, 'description': description}),
    );
  }

  @override
  Future<void> updateCategory({
    required String categoryId,
    required String categoryName,
    String? description,
  }) {
    return _remoteDataSource.updateCategory(
      categoryId,
      _cleanBody({'categoryName': categoryName, 'description': description}),
    );
  }

  @override
  Future<void> deleteCategory(String categoryId) {
    return _remoteDataSource.deleteCategory(categoryId);
  }

  @override
  Future<void> createCreditPackage({
    required String packageName,
    required int creditAmount,
    required double price,
    String? description,
  }) {
    return _remoteDataSource.createCreditPackage(
      _cleanBody({
        'packageName': packageName,
        'creditAmount': creditAmount,
        'price': price,
        'description': description,
      }),
    );
  }

  @override
  Future<void> updateCreditPackage({
    required String packageId,
    String? packageName,
    int? creditAmount,
    double? price,
    String? description,
  }) {
    return _remoteDataSource.updateCreditPackage(
      packageId,
      _cleanBody({
        'packageName': packageName,
        'creditAmount': creditAmount,
        'price': price,
        'description': description,
      }),
    );
  }

  @override
  Future<void> deleteCreditPackage(String packageId) {
    return _remoteDataSource.deleteCreditPackage(packageId);
  }

  Future<AdminRevenueSummary?> _nullableRevenueSummary() async {
    try {
      return await getRevenueSummary();
    } on ApiException {
      return null;
    }
  }

  Future<List<AdminPaymentHistory>> _nullablePaymentHistory() async {
    try {
      return await getPaymentHistory();
    } on ApiException {
      return const [];
    }
  }

  Future<List<CreditPackageModel>> _nullableCreditPackages() async {
    try {
      final raw = await _remoteDataSource.getRawCreditPackages();
      return adminCreditPackagesFromResponse(raw);
    } on ApiException {
      return const [];
    }
  }

  Map<String, dynamic> _cleanBody(Map<String, dynamic> body) {
    final cleaned = Map<String, dynamic>.from(body);
    cleaned.removeWhere((_, value) {
      if (value == null) return true;
      if (value is String && value.trim().isEmpty) return true;
      return false;
    });
    return cleaned;
  }
}
