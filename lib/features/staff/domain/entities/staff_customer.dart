import 'staff_booking.dart';

class StaffCustomer {
  const StaffCustomer({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.bookings,
  });

  final String userId;
  final String fullName;
  final String email;
  final List<StaffBooking> bookings;

  DateTime? get latestBookingAt {
    if (bookings.isEmpty) return null;
    return bookings
        .map((booking) => booking.startTime)
        .reduce((first, second) => first.isAfter(second) ? first : second);
  }
}
