class StaffBooking {
  const StaffBooking({
    required this.bookingId,
    required this.bookingCode,
    required this.bookingType,
    required this.userId,
    required this.userFullName,
    required this.userEmail,
    required this.branchId,
    required this.branchName,
    this.gymName,
    this.sessionName,
    this.className,
    this.qrToken,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.checkInStatus,
  });

  final String bookingId;
  final String bookingCode;
  final String bookingType;
  final String userId;
  final String userFullName;
  final String userEmail;
  final String branchId;
  final String branchName;
  final String? gymName;
  final String? sessionName;
  final String? className;
  final String? qrToken;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final String checkInStatus;

  bool get isClassBooking => bookingType.trim().toUpperCase() == 'CLASS';

  bool get isCheckedIn {
    final normalized = checkInStatus
        .trim()
        .toLowerCase()
        .replaceAll('-', '')
        .replaceAll('_', '');
    return normalized == 'checkedin' || normalized == 'completed';
  }
}
