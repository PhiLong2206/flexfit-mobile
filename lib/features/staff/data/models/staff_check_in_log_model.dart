import '../../domain/entities/staff_check_in_log.dart';

class StaffCheckInLogModel extends StaffCheckInLog {
  const StaffCheckInLogModel({
    required super.id,
    required super.userId,
    required super.memberName,
    required super.memberEmail,
    required super.status,
    required super.scannedAt,
    super.className,
    super.message,
  });

  factory StaffCheckInLogModel.fromJson(Map<String, dynamic> json) {
    return StaffCheckInLogModel(
      id: _read(json, 'checkInLogId')?.toString() ?? '',
      userId: _read(json, 'userId')?.toString() ?? '',
      memberName: _read(json, 'memberName')?.toString() ?? '',
      memberEmail: _read(json, 'memberEmail')?.toString() ?? '',
      className: _read(json, 'className')?.toString(),
      status: _read(json, 'status')?.toString() ?? '',
      message: _read(json, 'message')?.toString(),
      scannedAt:
          DateTime.tryParse(_read(json, 'scannedAt')?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
