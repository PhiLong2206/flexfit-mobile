import '../../domain/entities/staff_booking.dart';

class StaffBookingModel extends StaffBooking {
  const StaffBookingModel({
    required super.bookingId,
    required super.bookingCode,
    required super.bookingType,
    required super.userId,
    required super.userFullName,
    required super.userEmail,
    required super.branchId,
    required super.branchName,
    required super.startTime,
    required super.endTime,
    required super.status,
    required super.checkInStatus,
    super.gymName,
    super.sessionName,
    super.className,
    super.qrToken,
  });

  factory StaffBookingModel.fromJson(Map<String, dynamic> json) {
    return StaffBookingModel(
      bookingId: _read(json, 'bookingId')?.toString() ?? '',
      bookingCode: _read(json, 'bookingCode')?.toString() ?? '',
      bookingType: _read(json, 'bookingType')?.toString() ?? '',
      userId: _read(json, 'userId')?.toString() ?? '',
      userFullName: _read(json, 'userFullName')?.toString() ?? '',
      userEmail: _read(json, 'userEmail')?.toString() ?? '',
      branchId: _read(json, 'branchId')?.toString() ?? '',
      branchName: _read(json, 'branchName')?.toString() ?? '',
      gymName: _read(json, 'gymName')?.toString(),
      sessionName: _read(json, 'sessionName')?.toString(),
      className: _read(json, 'className')?.toString(),
      qrToken: _read(json, 'qrToken')?.toString(),
      startTime: _readDate(json, 'startTime'),
      endTime: _readDate(json, 'endTime'),
      status: _read(json, 'status')?.toString() ?? '',
      checkInStatus: _read(json, 'checkInStatus')?.toString() ?? '',
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}

DateTime _readDate(Map<String, dynamic> json, String key) {
  return DateTime.tryParse(_read(json, key)?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);
}
