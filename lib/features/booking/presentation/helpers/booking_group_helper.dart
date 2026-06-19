import '../../data/models/booking_model.dart';

enum BookingSectionType { today, tomorrow, upcoming, past }

class BookingSectionGroup {
  const BookingSectionGroup({required this.type, required this.bookings});

  final BookingSectionType type;
  final List<BookingModel> bookings;

  String get title {
    switch (type) {
      case BookingSectionType.today:
        return 'Hôm nay';
      case BookingSectionType.tomorrow:
        return 'Ngày mai';
      case BookingSectionType.upcoming:
        return 'Sắp tới';
      case BookingSectionType.past:
        return 'Đã qua';
    }
  }

  String get subtitle {
    switch (type) {
      case BookingSectionType.today:
        return 'Lịch tập trong ngày';
      case BookingSectionType.tomorrow:
        return 'Chuẩn bị cho buổi tập tiếp theo';
      case BookingSectionType.upcoming:
        return 'Các lịch tập sắp diễn ra';
      case BookingSectionType.past:
        return 'Lịch tập đã kết thúc';
    }
  }
}

List<BookingSectionGroup> groupBookingsBySchedule(
  List<BookingModel> bookings, {
  DateTime? now,
}) {
  final current = now ?? DateTime.now();
  final today = _dateOnly(current);
  final tomorrow = today.add(const Duration(days: 1));

  final todayBookings = <BookingModel>[];
  final tomorrowBookings = <BookingModel>[];
  final upcomingBookings = <BookingModel>[];
  final pastBookings = <BookingModel>[];

  for (final booking in bookings) {
    final startDate = _dateOnly(booking.startTime);

    if (_isPastBooking(booking, current)) {
      pastBookings.add(booking);
    } else if (startDate == today) {
      todayBookings.add(booking);
    } else if (startDate == tomorrow) {
      tomorrowBookings.add(booking);
    } else if (startDate.isAfter(tomorrow)) {
      upcomingBookings.add(booking);
    } else {
      pastBookings.add(booking);
    }
  }

  todayBookings.sort(_sortStartAsc);
  tomorrowBookings.sort(_sortStartAsc);
  upcomingBookings.sort(_sortStartAsc);
  pastBookings.sort((a, b) => b.startTime.compareTo(a.startTime));

  return [
    if (todayBookings.isNotEmpty)
      BookingSectionGroup(
        type: BookingSectionType.today,
        bookings: todayBookings,
      ),
    if (tomorrowBookings.isNotEmpty)
      BookingSectionGroup(
        type: BookingSectionType.tomorrow,
        bookings: tomorrowBookings,
      ),
    if (upcomingBookings.isNotEmpty)
      BookingSectionGroup(
        type: BookingSectionType.upcoming,
        bookings: upcomingBookings,
      ),
    if (pastBookings.isNotEmpty)
      BookingSectionGroup(
        type: BookingSectionType.past,
        bookings: pastBookings,
      ),
  ];
}

int _sortStartAsc(BookingModel a, BookingModel b) {
  return a.startTime.compareTo(b.startTime);
}

DateTime _dateOnly(DateTime value) {
  final local = value.toLocal();
  return DateTime(local.year, local.month, local.day);
}

bool _isPastBooking(BookingModel booking, DateTime now) {
  if (booking.endTime.isBefore(now)) {
    return true;
  }

  return _isCompletedLike(booking.status) && !booking.endTime.isAfter(now);
}

bool _isCompletedLike(String value) {
  final normalized = value
      .toLowerCase()
      .replaceAll('-', '')
      .replaceAll('_', '')
      .replaceAll(' ', '');

  return normalized == 'completed' ||
      normalized == 'finished' ||
      normalized == 'checkedin';
}
