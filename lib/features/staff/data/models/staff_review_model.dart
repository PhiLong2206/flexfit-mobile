import '../../domain/entities/staff_review.dart';

class StaffReviewModel extends StaffReview {
  const StaffReviewModel({
    required super.reviewId,
    required super.userFullName,
    required super.rating,
    required super.createdAt,
    super.comment,
    super.gymName,
    super.className,
  });

  factory StaffReviewModel.fromJson(Map<String, dynamic> json) {
    return StaffReviewModel(
      reviewId: _read(json, 'reviewId')?.toString() ?? '',
      userFullName: _read(json, 'userFullName')?.toString() ?? '',
      rating: int.tryParse(_read(json, 'rating')?.toString() ?? '') ?? 0,
      createdAt:
          DateTime.tryParse(_read(json, 'createdAt')?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      comment: _read(json, 'comment')?.toString(),
      gymName: _read(json, 'gymName')?.toString(),
      className: _read(json, 'className')?.toString(),
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
