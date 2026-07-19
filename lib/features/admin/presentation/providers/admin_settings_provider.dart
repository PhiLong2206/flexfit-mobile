import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminSettingsProvider extends ChangeNotifier {
  AdminSettingsProvider({required AdminRepository repository})
    : _repository = repository;

  final AdminRepository _repository;

  AdminSystemLogsPage? _logsPage;
  bool _isLoading = false;
  String? _errorMessage;

  AdminSystemLogsPage? get logsPage => _logsPage;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _logsPage = await _repository.getSystemLogs();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);
}
