class BookingModel {
  const BookingModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.gymName,
    this.gymId,
    this.branchName,
    this.branchAddress,
    required this.startTime,
    required this.endTime,
    required this.bookingCode,
    this.qrToken,
    required this.status,
    required this.checkInStatus,
    required this.creditUsed,
    required this.type,
    required this.hasReview,
    this.reviewId,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String? gymName;
  final String? gymId;
  final String? branchName;
  final String? branchAddress;
  final DateTime startTime;
  final DateTime endTime;
  final String bookingCode;
  final String? qrToken;
  final String status;
  final String checkInStatus;
  final int creditUsed;
  final BookingType type;
  final bool hasReview;
  final String? reviewId;

  bool get canReview {
    if (hasReview) {
      return false;
    }
    if (_isBlockedReviewStatus(status)) {
      return false;
    }
    return _isReviewableStatus(status) || _isReviewableStatus(checkInStatus);
  }

  BookingModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? gymName,
    String? gymId,
    String? branchName,
    String? branchAddress,
    DateTime? startTime,
    DateTime? endTime,
    String? bookingCode,
    String? qrToken,
    String? status,
    String? checkInStatus,
    int? creditUsed,
    BookingType? type,
    bool? hasReview,
    String? reviewId,
  }) {
    return BookingModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      gymName: gymName ?? this.gymName,
      gymId: gymId ?? this.gymId,
      branchName: branchName ?? this.branchName,
      branchAddress: branchAddress ?? this.branchAddress,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      bookingCode: bookingCode ?? this.bookingCode,
      qrToken: qrToken ?? this.qrToken,
      status: status ?? this.status,
      checkInStatus: checkInStatus ?? this.checkInStatus,
      creditUsed: creditUsed ?? this.creditUsed,
      type: type ?? this.type,
      hasReview: hasReview ?? this.hasReview,
      reviewId: reviewId ?? this.reviewId,
    );
  }

  factory BookingModel.fromGymJson(Map<String, dynamic> json) {
    final branchName = _readString(json, 'branchName');
    return BookingModel(
      id: _read(json, 'bookingId').toString(),
      title: _readString(json, 'sessionName') ?? 'Gym session',
      subtitle: branchName,
      gymName: _readString(json, 'gymName'),
      gymId: _read(json, 'gymId')?.toString() ?? _read(json, 'branchId')?.toString(),
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
      checkInStatus: _readString(json, 'checkInStatus') ?? '',
      creditUsed:
          int.tryParse(_read(json, 'creditUsed')?.toString() ?? '') ?? 0,
      type: BookingType.gym,
      hasReview: _readBool(json, 'hasReview'),
      reviewId: _readString(json, 'reviewId'),
    );
  }

  factory BookingModel.fromClassJson(Map<String, dynamic> json) {
    final coachName = _readString(json, 'coachName');
    return BookingModel(
      id: _read(json, 'bookingId').toString(),
      title: _readString(json, 'className') ?? 'Class',
      subtitle: coachName,
      gymName: _readString(json, 'gymName'),
      gymId: _read(json, 'gymId')?.toString() ?? _read(json, 'branchId')?.toString(),
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
      checkInStatus: _readString(json, 'checkInStatus') ?? '',
      creditUsed:
          int.tryParse(_read(json, 'creditUsed')?.toString() ?? '') ?? 0,
      type: BookingType.classBooking,
      hasReview: _readBool(json, 'hasReview'),
      reviewId: _readString(json, 'reviewId'),
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

bool _readBool(Map<String, dynamic> json, String key) {
  final value = _read(json, key);
  if (value is bool) {
    return value;
  }
  final text = value?.toString().toLowerCase();
  return text == 'true' || text == '1';
}

bool _isReviewableStatus(String value) {
  final normalized = value
      .toLowerCase()
      .replaceAll('-', '')
      .replaceAll('_', '');
  return normalized == 'completed' ||
      normalized == 'checkedin' ||
      normalized == 'finished';
}

bool _isBlockedReviewStatus(String value) {
  final normalized = value
      .toLowerCase()
      .replaceAll('-', '')
      .replaceAll('_', '');
  return normalized == 'pending' ||
      normalized == 'upcoming' ||
      normalized == 'cancelled' ||
      normalized == 'canceled';
}
