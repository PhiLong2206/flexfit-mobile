import 'package:flutter/foundation.dart';

import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/admin_repository.dart';

class AdminRevenueProvider extends ChangeNotifier {
  AdminRevenueProvider({required AdminRepository repository})
    : _repository = repository;

  final AdminRepository _repository;

  AdminRevenueSummary? _summary;
  List<AdminPaymentHistory> _payments = const [];
  bool _isLoading = false;
  String? _errorMessage;

  AdminRevenueSummary? get summary => _summary;
  List<AdminPaymentHistory> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final summaryFuture = _repository.getRevenueSummary();
      final paymentsFuture = _repository.getPaymentHistory();
      _summary = await summaryFuture;
      _payments = await paymentsFuture;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);
}
