import '../../../../core/services/api_client.dart';
import '../../../../core/services/local_storage.dart';
import '../models/credit_package_model.dart';

class CreditRepository {
  CreditRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<CreditPackageModel>> getPackages() async {
    final response = await _apiClient.get('/credit-packages');
    return (response as List)
        .map(
          (item) => CreditPackageModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .where((package) => package.isActive)
        .toList();
  }

  Future<void> buyPackage(String packageId) async {
    final userId = await LocalStorage.getUserIdFromToken();
    if (userId == null || userId.isEmpty) {
      throw const ApiException(
        'Không thể xác định người dùng hiện tại từ token.',
      );
    }
    await _apiClient.post(
      '/credit-packages/$packageId/buy',
      body: {'userId': userId},
    );
  }

  Future<UserCreditModel> getMyCredit() async {
    final response = await _apiClient.get('/payment/my-credit');
    return UserCreditModel.fromJson(Map<String, dynamic>.from(response as Map));
  }
}
