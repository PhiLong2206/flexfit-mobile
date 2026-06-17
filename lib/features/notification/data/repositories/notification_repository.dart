import '../../../../core/services/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  NotificationRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _getWithFallback(const [
      '/notifications',
      '/notifications/my',
    ]);
    return _readList(response)
        .whereType<Map>()
        .map(
          (item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((notification) => notification.id.isNotEmpty)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> markAsRead(String id) async {
    await _writeWithFallback([
      () => _apiClient.patch('/notifications/$id/read'),
      () => _apiClient.put('/notifications/$id/read'),
    ]);
  }

  Future<void> markAllAsRead() async {
    await _writeWithFallback([
      () => _apiClient.patch('/notifications/read-all'),
      () => _apiClient.put('/notifications/read-all'),
      () => _apiClient.post('/notifications/read-all'),
    ]);
  }

  Future<dynamic> _getWithFallback(List<String> paths) async {
    Object? lastError;
    for (final path in paths) {
      try {
        return await _apiClient.get(path);
      } catch (error) {
        lastError = error;
        if (!_shouldTryFallback(error)) {
          rethrow;
        }
      }
    }
    throw lastError ?? const ApiException('Không tải được thông báo.');
  }

  Future<void> _writeWithFallback(
    List<Future<dynamic> Function()> requests,
  ) async {
    Object? lastError;
    for (final request in requests) {
      try {
        await request();
        return;
      } catch (error) {
        lastError = error;
        if (!_shouldTryFallback(error)) {
          rethrow;
        }
      }
    }
    throw lastError ?? const ApiException('Không cập nhật được thông báo.');
  }

  bool _shouldTryFallback(Object error) {
    return error is ApiException &&
        (error.statusCode == 404 || error.statusCode == 405);
  }

  List<dynamic> _readList(dynamic response) {
    if (response is List) {
      return response;
    }
    if (response is Map) {
      final data = response['data'] ?? response['Data'] ?? response['items'];
      if (data is List) {
        return data;
      }
    }
    return const [];
  }
}
