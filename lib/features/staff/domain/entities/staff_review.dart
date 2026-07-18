class StaffReview {
  const StaffReview({
    required this.reviewId,
    required this.userFullName,
    required this.rating,
    required this.createdAt,
    this.comment,
    this.gymName,
    this.className,
  });

  final String reviewId;
  final String userFullName;
  final int rating;
  final DateTime createdAt;
  final String? comment;
  final String? gymName;
  final String? className;
}
