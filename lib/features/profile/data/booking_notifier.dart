import 'package:flutter/material.dart';
import 'models/booking_item.dart';

class BookingNotifier extends ChangeNotifier {
  final List<BookingItem> _bookings = [
    BookingItem(
      gymName: 'FlexFit Elite Center',
      address: '12 Nguyễn Trãi, Quận 1, TP. Hồ Chí Minh',
      date: DateTime(2026, 6, 10),
      timeSlot: '08:00 - 09:30',
      creditCost: 15,
      rating: 4.8,
      imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48',
      status: BookingStatus.completed,
    ),
    BookingItem(
      gymName: 'Peak Performance Studio',
      address: '26 Đường Cầu Giấy, Quận Cầu Giấy, Hà Nội',
      date: DateTime(2026, 6, 5),
      timeSlot: '18:00 - 19:30',
      creditCost: 12,
      rating: 4.7,
      imageUrl: 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f',
      status: BookingStatus.completed,
    ),
    BookingItem(
      gymName: 'Urban Strength Club',
      address: '115 Trần Phú, Quận Hải Châu, Đà Nẵng',
      date: DateTime(2026, 6, 1),
      timeSlot: '15:00 - 16:30',
      creditCost: 10,
      rating: 4.6,
      imageUrl: 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438',
      status: BookingStatus.cancelled,
    ),
  ];

  List<BookingItem> get bookings => List.unmodifiable(_bookings);

  List<BookingItem> getBookingsByStatus(BookingStatus status) {
    return _bookings.where((b) => b.status == status).toList();
  }

  void addBooking(BookingItem booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void cancelBooking(int index) {
    // Implement cancellation if needed
    notifyListeners();
  }
}
