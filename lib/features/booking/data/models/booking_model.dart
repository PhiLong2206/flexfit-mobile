class BookingModel {
  const BookingModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.gymName,
    this.branchName,
    this.branchAddress,
    required this.startTime,
    required this.endTime,
    required this.bookingCode,
    this.qrToken,
    required this.status,
    required this.creditUsed,
    required this.type,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? gymName;
  final String? branchName;
  final String? branchAddress;
  final DateTime startTime;
  final DateTime endTime;
  final String bookingCode;
  final String? qrToken;
  final String status;
  final int creditUsed;
  final BookingType type;

  factory BookingModel.fromGymJson(Map<String, dynamic> json) {
    final branchName = _readString(json, 'branchName');
    return BookingModel(
      id: _read(json, 'bookingId').toString(),
      title: _readString(json, 'sessionName') ?? 'Gym session',
      subtitle: branchName,
      gymName: _readString(json, 'gymName'),
      branchName: branchName,
      branchAddress:
          _readString(json, 'branchAddress') ?? _readString(json, 'address'),
      startTime:
          DateTime.tryParse(_read(json, 'startTime')?.toString() ?? '') ??
          DateTime.now(),
      endTime:
          DateTime.tryParse(_read(json, 'endTime')?.toString() ?? '') ??
          DateTime.now(),
      bookingCode: _readString(json, 'bookingCode') ?? '',
      qrToken: _readString(json, 'qrToken'),
      status: _readString(json, 'status') ?? '',
      creditUsed:
          int.tryParse(_read(json, 'creditUsed')?.toString() ?? '') ?? 0,
      type: BookingType.gym,
    );
  }

  factory BookingModel.fromClassJson(Map<String, dynamic> json) {
    final coachName = _readString(json, 'coachName');
    return BookingModel(
      id: _read(json, 'bookingId').toString(),
      title: _readString(json, 'className') ?? 'Class',
      subtitle: coachName,
      gymName: _readString(json, 'gymName'),
      branchName: _readString(json, 'branchName'),
      branchAddress:
          _readString(json, 'branchAddress') ?? _readString(json, 'address'),
      startTime:
          DateTime.tryParse(_read(json, 'startTime')?.toString() ?? '') ??
          DateTime.now(),
      endTime:
          DateTime.tryParse(_read(json, 'endTime')?.toString() ?? '') ??
          DateTime.now(),
      bookingCode: _readString(json, 'bookingCode') ?? '',
      qrToken: _readString(json, 'qrToken'),
      status: _readString(json, 'status') ?? '',
      creditUsed:
          int.tryParse(_read(json, 'creditUsed')?.toString() ?? '') ?? 0,
      type: BookingType.classBooking,
    );
  }
}

enum BookingType { gym, classBooking }

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}

String? _readString(Map<String, dynamic> json, String key) {
  final value = _read(json, key)?.toString().trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  return value;
}
