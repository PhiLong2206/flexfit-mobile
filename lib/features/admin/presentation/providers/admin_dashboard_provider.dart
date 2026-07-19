import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminDashboardProvider extends ChangeNotifier {
  AdminDashboardProvider({required AdminRepository repository})
    : _repository = repository;

  final AdminRepository _repository;

  AdminDashboardSummary? _summary;
  bool _isLoading = false;
  String? _errorMessage;

  AdminDashboardSummary? get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = (await _repository.getDashboardData()).toSummary();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);
}
