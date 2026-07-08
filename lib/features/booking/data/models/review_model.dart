class ReviewModel {
  const ReviewModel({
    required this.reviewId,
    required this.rating,
    required this.createdAt,
    this.comment,
    this.gymBookingId,
    this.classBookingId,
  });

  final String reviewId;
  final int rating;
  final String? comment;
  final String? gymBookingId;
  final String? classBookingId;
  final DateTime createdAt;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: _read(json, 'reviewId')?.toString() ?? '',
      rating: int.tryParse(_read(json, 'rating')?.toString() ?? '') ?? 0,
      comment: _read(json, 'comment')?.toString(),
      gymBookingId: _read(json, 'gymBookingId')?.toString(),
      classBookingId: _read(json, 'classBookingId')?.toString(),
      createdAt:
          DateTime.tryParse(_read(json, 'createdAt')?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
