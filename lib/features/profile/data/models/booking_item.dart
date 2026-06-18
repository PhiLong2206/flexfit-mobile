enum BookingStatus {
  upcoming,
  completed,
  cancelled,
}

class BookingItem {
  final String gymName;
  final String address;
  final DateTime date;
  final String timeSlot;
  final int creditCost;
  final double rating;
  final String imageUrl;
  final BookingStatus status;

  BookingItem({
    required this.gymName,
    required this.address,
    required this.date,
    required this.timeSlot,
    required this.creditCost,
    required this.rating,
    required this.imageUrl,
    required this.status,
  });
}
