import '../../data/models/booking_model.dart';

class BookingConflictException implements Exception {
  const BookingConflictException([
    this.message =
        'Bạn đã có lịch đặt trong khoảng thời gian này. Vui lòng chọn khung giờ khác.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class BookingOverlapValidator {
  const BookingOverlapValidator();

  static const _fallbackDuration = Duration(minutes: 60);

  void validate({
    required DateTime newStart,
    required DateTime newEnd,
    required Iterable<BookingModel> existingBookings,
    DateTime? now,
  }) {
    final normalizedNewEnd = _normalizeEnd(newStart, newEnd);
    final currentTime = now ?? DateTime.now();

    for (final booking in existingBookings) {
      if (!_isEffectiveBooking(booking, currentTime)) {
        continue;
      }

      final existingStart = booking.startTime;
      final existingEnd = _normalizeEnd(existingStart, booking.endTime);
      final overlaps =
          newStart.isBefore(existingEnd) &&
          normalizedNewEnd.isAfter(existingStart);

      if (overlaps) {
        throw const BookingConflictException();
      }
    }
  }

  DateTime _normalizeEnd(DateTime start, DateTime end) {
    if (end.isAfter(start)) {
      return end;
    }
    return start.add(_fallbackDuration);
  }

  bool _isEffectiveBooking(BookingModel booking, DateTime now) {
    final status = _normalize(booking.status);
    final checkInStatus = _normalize(booking.checkInStatus);
    final effectiveEnd = _normalizeEnd(booking.startTime, booking.endTime);

    if (_isIgnoredStatus(status) || _isIgnoredStatus(checkInStatus)) {
      return false;
    }

    if (_isCompletedStatus(status) || _isCompletedStatus(checkInStatus)) {
      return effectiveEnd.isAfter(now);
    }

    return _isActiveStatus(status) ||
        _isActiveStatus(checkInStatus) ||
        effectiveEnd.isAfter(now);
  }

  bool _isActiveStatus(String value) {
    return value == 'pending' ||
        value == 'confirmed' ||
        value == 'success' ||
        value == 'upcoming' ||
        value == 'active' ||
        value == 'paid' ||
        value == 'booked';
  }

  bool _isIgnoredStatus(String value) {
    return value == 'cancelled' ||
        value == 'canceled' ||
        value == 'failed' ||
        value == 'failure' ||
        value == 'error' ||
        value == 'rejected';
  }

  bool _isCompletedStatus(String value) {
    return value == 'completed' || value == 'checkedin' || value == 'finished';
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll('-', '').replaceAll('_', '');
  }
}
