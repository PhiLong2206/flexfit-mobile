import 'package:flutter/material.dart';
import '../../../booking/domain/usecases/get_my_bookings_usecase.dart';
import '../../../booking/data/models/booking_model.dart';

class UpcomingScheduleProvider extends ChangeNotifier {
  UpcomingScheduleProvider(this._getMyBookingsUseCase);

  final GetMyBookingsUseCase _getMyBookingsUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  List<BookingModel> _upcomingBookings = [];
  List<BookingModel> get upcomingBookings => List.unmodifiable(_upcomingBookings);

  bool _hasFetched = false;

  Future<void> fetchUpcomingBookings({bool force = false}) async {
    if (_hasFetched && !force) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final bookings = await _getMyBookingsUseCase();
      final now = DateTime.now();
      _upcomingBookings = bookings
          .where((b) => b.startTime.isAfter(now) && b.status.toLowerCase() != 'cancelled' && b.status.toLowerCase() != 'canceled')
          .toList();
      _upcomingBookings.sort((a, b) => a.startTime.compareTo(b.startTime));
      _hasFetched = true;
    } catch (e) {
      _error = 'Không thể tải lịch tập.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
