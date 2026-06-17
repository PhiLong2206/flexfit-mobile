import '../../../../core/services/api_client.dart';
import '../../../../core/services/local_storage.dart';
import '../models/credit_package_model.dart';

class CreditRepository {
  CreditRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<CreditPackageModel>> getPackages() async {
    final response = await _getPackagesResponse();
    return _readList(response)
        .map(
          (item) => CreditPackageModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .where((package) => package.isActive)
        .toList();
  }

  Future<dynamic> _getPackagesResponse() async {
    try {
      return await _apiClient.get('/payment/packages');
    } on ApiException {
      return _apiClient.get('/credit-packages');
    }
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

List<dynamic> _readList(dynamic response) {
  if (response is List) {
    return response;
  }
  if (response is Map) {
    final data =
        response['data'] ??
        response['Data'] ??
        response['items'] ??
        response['Items'] ??
        response['packages'] ??
        response['Packages'];
    if (data is List) {
      return data;
    }
  }
  return const [];
}
