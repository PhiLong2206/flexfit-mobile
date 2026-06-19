import 'package:flutter/material.dart';

import '../../../../core/services/api_client.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationRepository? repository})
    : _repository = repository ?? NotificationRepository();

  final NotificationRepository _repository;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  Future<void> loadNotifications({bool force = false}) async {
    if (_isLoading && !force) return;
    _setLoading(true);
    try {
      _notifications = await _repository.getNotifications();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _friendlyError(error);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => loadNotifications(force: true);

  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );
    if (index == -1 || _notifications[index].isRead) {
      return;
    }

    try {
      await _repository.markAsRead(id);
      final updated = [..._notifications];
      updated[index] = updated[index].copyWith(isRead: true);
      _notifications = updated;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0) {
      return;
    }
    try {
      await _repository.markAllAsRead();
      _notifications = _notifications
          .map((notification) => notification.copyWith(isRead: true))
          .toList();
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _errorMessage = _friendlyError(error);
      notifyListeners();
      rethrow;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  String _friendlyError(Object error) {
    if (error is ApiException && error.statusCode == 401) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    }
    return error.toString();
  }
}
