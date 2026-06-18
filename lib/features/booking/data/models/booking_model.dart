class BookingModel {
  const BookingModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.gymName,
    required this.startTime,
    required this.endTime,
    required this.bookingCode,
    required this.status,
    required this.creditUsed,
    required this.type,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? gymName;
  final DateTime startTime;
  final DateTime endTime;
  final String bookingCode;
  final String status;
  final int creditUsed;
  final BookingType type;

  factory BookingModel.fromGymJson(Map<String, dynamic> json) {
    return BookingModel(
      id: _read(json, 'bookingId').toString(),
      title: _read(json, 'sessionName')?.toString() ?? 'Buổi tập gym',
      subtitle: _read(json, 'branchName')?.toString(),
      gymName: _read(json, 'gymName')?.toString(),
      startTime:
          DateTime.tryParse(_read(json, 'startTime')?.toString() ?? '') ??
          DateTime.now(),
      endTime:
          DateTime.tryParse(_read(json, 'endTime')?.toString() ?? '') ??
          DateTime.now(),
      bookingCode: _read(json, 'bookingCode')?.toString() ?? '',
      status: _read(json, 'status')?.toString() ?? '',
      creditUsed:
          int.tryParse(_read(json, 'creditUsed')?.toString() ?? '') ?? 0,
      type: BookingType.gym,
    );
  }

  factory BookingModel.fromClassJson(Map<String, dynamic> json) {
    return BookingModel(
      id: _read(json, 'bookingId').toString(),
      title: _read(json, 'className')?.toString() ?? 'Lớp học',
      subtitle: _read(json, 'coachName')?.toString(),
      gymName: _read(json, 'gymName')?.toString(),
      startTime:
          DateTime.tryParse(_read(json, 'startTime')?.toString() ?? '') ??
          DateTime.now(),
      endTime:
          DateTime.tryParse(_read(json, 'endTime')?.toString() ?? '') ??
          DateTime.now(),
      bookingCode: _read(json, 'bookingCode')?.toString() ?? '',
      status: _read(json, 'status')?.toString() ?? '',
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
