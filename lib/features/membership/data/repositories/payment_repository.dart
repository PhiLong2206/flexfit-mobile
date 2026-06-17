import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/api_client.dart';
import '../models/payment_model.dart';

class PaymentRepository {
  PaymentRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<PaymentCreateResult> createPayment({
    required String packageId,
    String paymentMethod = 'PAYOS',
  }) async {
    final response = await _apiClient.post(
      '/payment/create',
      body: {'packageId': packageId, 'paymentMethod': paymentMethod},
    );
    return PaymentCreateResult.fromJson(_readMap(response));
  }

  Future<List<PaymentHistoryModel>> getMyPaymentHistory() async {
    final response = await _apiClient.get('/payment/history');
    return _readList(response)
        .whereType<Map>()
        .map(
          (item) =>
              PaymentHistoryModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  String resolvePaymentUrl(String paymentUrl) {
    final parsed = Uri.tryParse(paymentUrl);
    if (parsed == null) {
      throw const ApiException('Liên kết thanh toán không hợp lệ.');
    }
    if (parsed.hasScheme) {
      return parsed.toString();
    }

    final base = Uri.parse(AppConstants.baseUrl);
    final origin = Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
    );
    return origin.resolve(paymentUrl).toString();
  }
}

Map<String, dynamic> _readMap(dynamic response) {
  if (response is Map) {
    final data = response['data'] ?? response['Data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return Map<String, dynamic>.from(response);
  }
  return const {};
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
        response['history'] ??
        response['History'];
    if (data is List) {
      return data;
    }
  }
  return const [];
}
