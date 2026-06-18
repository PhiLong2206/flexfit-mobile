class BookingModel {
  const BookingModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.gymName,
    this.gymId,
    required this.startTime,
    required this.endTime,
    required this.bookingCode,
    required this.status,
    required this.creditUsed,
    required this.type,
    this.isReviewed = false,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? gymName;
  final String? gymId;
  final DateTime startTime;
  final DateTime endTime;
  final String bookingCode;
  final String status;
  final int creditUsed;
  final BookingType type;
  final bool isReviewed;

  BookingModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? gymName,
    String? gymId,
    DateTime? startTime,
    DateTime? endTime,
    String? bookingCode,
    String? status,
    int? creditUsed,
    BookingType? type,
    bool? isReviewed,
  }) {
    return BookingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      gymName: gymName ?? this.gymName,
      gymId: gymId ?? this.gymId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      bookingCode: bookingCode ?? this.bookingCode,
      status: status ?? this.status,
      creditUsed: creditUsed ?? this.creditUsed,
      type: type ?? this.type,
      isReviewed: isReviewed ?? this.isReviewed,
    );
  }

  factory BookingModel.fromGymJson(Map<String, dynamic> json) {
    return BookingModel(
      id: _read(json, 'bookingId').toString(),
      title: _read(json, 'sessionName')?.toString() ?? 'Buổi tập gym',
      subtitle: _read(json, 'branchName')?.toString(),
      gymName: _read(json, 'gymName')?.toString(),
      gymId: _read(json, 'gymId')?.toString() ?? _read(json, 'branchId')?.toString(),
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
      isReviewed: _read(json, 'isReviewed') == true,
    );
  }

  factory BookingModel.fromClassJson(Map<String, dynamic> json) {
    return BookingModel(
      id: _read(json, 'bookingId').toString(),
      title: _read(json, 'className')?.toString() ?? 'Lớp học',
      subtitle: _read(json, 'coachName')?.toString(),
      gymName: _read(json, 'gymName')?.toString(),
      gymId: _read(json, 'gymId')?.toString() ?? _read(json, 'branchId')?.toString(),
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
      isReviewed: _read(json, 'isReviewed') == true,
    );
  }
}

enum BookingType { gym, classBooking }

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
