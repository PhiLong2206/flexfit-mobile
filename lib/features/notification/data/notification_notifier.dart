import 'package:flutter/material.dart';
import 'models/notification_model.dart';
import 'repositories/notification_repository.dart';

class NotificationNotifier extends ChangeNotifier {
  final _repository = NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _repository.getNotifications();
      _notifications = fetched;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    // Local-first immediate update
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      final updatedList = List<NotificationModel>.from(_notifications);
      updatedList[index] = updatedList[index].copyWith(isRead: true);
      _notifications = updatedList;
      notifyListeners();
    }

    try {
      await _repository.readNotification(id);
    } catch (e) {
      debugPrint('Error marking notification read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    // Local-first immediate update
    final updatedList = _notifications.map((n) {
      if (!n.isRead) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    _notifications = updatedList;
    notifyListeners();

    try {
      await _repository.readAllNotifications();
    } catch (e) {
      debugPrint('Error marking all notifications read: $e');
    }
  }
}
