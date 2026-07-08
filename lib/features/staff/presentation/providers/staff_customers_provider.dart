import 'package:flutter/foundation.dart';

import '../../domain/entities/staff_customer.dart';
import '../../domain/entities/staff_booking.dart';
import '../../domain/repositories/staff_repository.dart';

class StaffCustomersProvider extends ChangeNotifier {
  StaffCustomersProvider({required StaffRepository repository})
    : _repository = repository;

  final StaffRepository _repository;

  List<StaffCustomer> _customers = const [];
  String _query = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<StaffCustomer> get visibleCustomers {
    final query = _query.trim().toLowerCase();
    final result =
        _customers.where((customer) {
          if (query.isEmpty) return true;
          return customer.fullName.toLowerCase().contains(query) ||
              customer.email.toLowerCase().contains(query);
        }).toList()..sort((first, second) {
          final firstDate = first.latestBookingAt;
          final secondDate = second.latestBookingAt;
          if (firstDate == null && secondDate == null) return 0;
          if (firstDate == null) return 1;
          if (secondDate == null) return -1;
          return secondDate.compareTo(firstDate);
        });
    return List.unmodifiable(result);
  }

  Future<void> load({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final bookings = await _repository.getCheckInCandidates();
      final grouped = <String, List<StaffBooking>>{};
      for (final booking in bookings) {
        final key = booking.userId.trim().isNotEmpty
            ? booking.userId.trim().toLowerCase()
            : booking.userEmail.trim().toLowerCase();
        if (key.isEmpty) continue;
        grouped.putIfAbsent(key, () => []).add(booking);
      }
      _customers = grouped.values
          .map((items) {
            final first = items.first;
            return StaffCustomer(
              userId: first.userId,
              fullName: first.userFullName,
              email: first.userEmail,
              bookings: List.unmodifiable(items),
            );
          })
          .toList(growable: false);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(force: true);

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }
}
