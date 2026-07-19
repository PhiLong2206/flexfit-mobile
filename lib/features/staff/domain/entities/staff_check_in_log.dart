class StaffCheckInLog {
  const StaffCheckInLog({
    required this.id,
    required this.userId,
    required this.memberName,
    required this.memberEmail,
    required this.status,
    required this.scannedAt,
    this.className,
    this.message,
  });

  final String id;
  final String userId;
  final String memberName;
  final String memberEmail;
  final String? className;
  final String status;
  final String? message;
  final DateTime scannedAt;
}
