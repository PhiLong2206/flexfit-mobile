import '../../../../core/services/api_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  NotificationRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.get('/notifications');
    return (response as List)
        .map(
          (item) => NotificationModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<void> readNotification(String id) async {
    await _apiClient.patch('/notifications/$id/read');
  }

  Future<void> readAllNotifications() async {
    await _apiClient.patch('/notifications/read-all');
  }
}
