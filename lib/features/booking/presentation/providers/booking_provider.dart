import 'package:flutter/material.dart';

import '../../../catalog/domain/entities/branch.dart';
import '../../../profile/data/models/booking_item.dart';
import '../../data/models/booking_model.dart';
import '../../data/repositories/booking_repository.dart';

class GymTimeSlotSelection {
  const GymTimeSlotSelection({
    required this.branch,
    required this.startTime,
    required this.endTime,
  });

  final Branch branch;
  final DateTime startTime;
  final DateTime endTime;
}

class BookingTimeSlot {
  const BookingTimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isPast,
  });

  final DateTime startTime;
  final DateTime endTime;
  final bool isPast;
}

class BookingProvider extends ChangeNotifier {
  BookingProvider({BookingRepository? repository})
    : _repository = repository ?? BookingRepository();

  static const _slotDuration = Duration(minutes: 60);

  final BookingRepository _repository;

  List<BookingModel> _bookings = [];
  bool _isLoading = false;
  String? _error;
  String? _bookingClassId;

  Branch? _slotBranch;
  _TimeOfDayValue _openTime = const _TimeOfDayValue(hour: 5, minute: 0);
  _TimeOfDayValue _closeTime = const _TimeOfDayValue(hour: 22, minute: 0);
  List<DateTime> _slotDates = const [];
  int _selectedDateIndex = 0;
  DateTime? _selectedStartTime;

  List<BookingModel> get bookings => List.unmodifiable(_bookings);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get bookingClassId => _bookingClassId;

  List<DateTime> get slotDates => List.unmodifiable(_slotDates);
  int get selectedDateIndex => _selectedDateIndex;
  DateTime? get selectedStartTime => _selectedStartTime;

  DateTime? get selectedEndTime {
    final start = _selectedStartTime;
    if (start == null) {
      return null;
    }
    return start.add(_slotDuration);
  }

  String get hoursLabel => '${_openTime.label} - ${_closeTime.label}';

  DateTime? get selectedDate {
    if (_slotDates.isEmpty) {
      return null;
    }
    return _slotDates[_selectedDateIndex];
  }

  bool get canContinueWithSlot {
    final start = _selectedStartTime;
    return start != null && start.isAfter(DateTime.now());
  }

  GymTimeSlotSelection? get selectedGymTimeSlot {
    final branch = _slotBranch;
    final start = _selectedStartTime;
    final end = selectedEndTime;
    if (branch == null ||
        start == null ||
        end == null ||
        !canContinueWithSlot) {
      return null;
    }
    return GymTimeSlotSelection(branch: branch, startTime: start, endTime: end);
  }

  void initializeSlotPicker(Branch branch) {
    _slotBranch = branch;
    _openTime =
        _TimeOfDayValue.tryParse(branch.openTime) ??
        const _TimeOfDayValue(hour: 5, minute: 0);
    _closeTime =
        _TimeOfDayValue.tryParse(branch.closeTime) ??
        const _TimeOfDayValue(hour: 22, minute: 0);
    _slotDates = List.generate(7, (index) {
      final now = DateTime.now();
      final date = now.add(Duration(days: index));
      return DateTime(date.year, date.month, date.day);
    });
    _selectedDateIndex = 0;
    _selectedStartTime = null;
  }

  void selectSlotDate(int index) {
    if (index < 0 || index >= _slotDates.length) {
      return;
    }
    _selectedDateIndex = index;
    _selectedStartTime = null;
    notifyListeners();
  }

  void selectTimeSlot(DateTime startTime) {
    _selectedStartTime = startTime;
    notifyListeners();
  }

  List<BookingTimeSlot> slotsForSelectedDate() {
    final date = selectedDate;
    if (date == null) {
      return const [];
    }

    final slots = <BookingTimeSlot>[];
    final openMinutes = _openTime.totalMinutes;
    final closeMinutes = _closeTime.totalMinutes;
    final latestStart = closeMinutes - _slotDuration.inMinutes;

    if (latestStart < openMinutes) {
      return slots;
    }

    for (var minutes = openMinutes; minutes <= latestStart; minutes += 60) {
      final start = DateTime(
        date.year,
        date.month,
        date.day,
        minutes ~/ 60,
        minutes % 60,
      );
      final end = start.add(_slotDuration);
      final isPast =
          _isSameDay(date, DateTime.now()) && !start.isAfter(DateTime.now());
      slots.add(
        BookingTimeSlot(startTime: start, endTime: end, isPast: isPast),
      );
    }
    return slots;
  }

  Future<BookingModel> createGymBooking({
    required String branchId,
    required String sessionName,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    _setLoading(true);
    try {
      final booking = await _repository.bookGym(
        branchId: branchId,
        sessionName: sessionName,
        startTime: startTime,
        endTime: endTime,
      );
      _error = null;
      return booking;
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createClassBooking(String classId) async {
    _bookingClassId = classId;
    _setLoading(true);
    try {
      await _repository.bookClass(classId);
      _error = null;
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _bookingClassId = null;
      _setLoading(false);
    }
  }

  Future<void> fetchBookings({bool force = false}) async {
    if (_isLoading && !force) return;
    _setLoading(true);
    try {
      _bookings = await _repository.getMyBookings();
      _error = null;
    } catch (error) {
      _error = error.toString();
    } finally {
      _setLoading(false);
    }
  }

  List<BookingModel> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((booking) {
      final value = booking.status.toLowerCase();
      switch (status) {
        case BookingStatus.upcoming:
          return !_isCompletedLike(booking.checkInStatus) &&
              (value == 'booked' || value == 'pending' || value == 'confirmed');
        case BookingStatus.completed:
          return _isCompletedLike(value) ||
              _isCompletedLike(booking.checkInStatus);
        case BookingStatus.cancelled:
          return value == 'cancelled' || value == 'canceled';
      }
    }).toList();
  }

  Future<void> cancelBooking(BookingModel booking) async {
    _setLoading(true);
    try {
      await _repository.cancelBooking(booking);
      _bookings = await _repository.getMyBookings();
      _error = null;
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markBookingReviewed(BookingModel booking) async {
    _bookings = _bookings.map((item) {
      if (item.id != booking.id || item.type != booking.type) {
        return item;
      }
      return item.copyWith(hasReview: true);
    }).toList();
    notifyListeners();
    await fetchBookings(force: true);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _error = null;
    }
    notifyListeners();
  }
}

bool _isCompletedLike(String value) {
  final normalized = value
      .toLowerCase()
      .replaceAll('-', '')
      .replaceAll('_', '');
  return normalized == 'completed' ||
      normalized == 'checkedin' ||
      normalized == 'finished';
}

class _TimeOfDayValue {
  const _TimeOfDayValue({required this.hour, required this.minute});

  final int hour;
  final int minute;

  int get totalMinutes => hour * 60 + minute;

  String get label {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  static _TimeOfDayValue? tryParse(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parts = value.split(':');
    if (parts.length < 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return _TimeOfDayValue(hour: hour, minute: minute);
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
