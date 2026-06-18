import 'package:flutter/material.dart';
import 'models/booking_item.dart';
import '../../booking/data/models/booking_model.dart';
import '../../booking/data/repositories/booking_repository.dart';

class BookingNotifier extends ChangeNotifier {
  final _repository = BookingRepository();
  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBookings({bool force = false}) async {
    if (_isLoading && !force) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _repository.getMyBookings();
      _bookings = fetched;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<BookingModel> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((b) {
      final s = b.status.toLowerCase();
      switch (status) {
        case BookingStatus.upcoming:
          return s == 'booked' || s == 'pending' || s == 'confirmed';
        case BookingStatus.completed:
          return s == 'completed';
        case BookingStatus.cancelled:
          return s == 'cancelled' || s == 'canceled';
      }
    }).toList();
  }

  Future<void> cancelBooking(BookingModel booking) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.cancelBooking(booking);
      // Re-fetch bookings from server after cancel
      final fetched = await _repository.getMyBookings();
      _bookings = fetched;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void markBookingAsReviewedLocally(String bookingId) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final updatedList = List<BookingModel>.from(_bookings);
      updatedList[index] = updatedList[index].copyWith(isReviewed: true);
      _bookings = updatedList;
      notifyListeners();
    }
  }
}
