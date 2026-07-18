class PartnerReviewModel {
  final String reviewId;
  final int rating;
  final String comment;
  final String customerName;
  final String gymName;
  final String className;
  final DateTime createdAt;

  const PartnerReviewModel({
    required this.reviewId,
    required this.rating,
    required this.comment,
    required this.customerName,
    required this.gymName,
    required this.className,
    required this.createdAt,
  });

  factory PartnerReviewModel.fromJson(Map<String, dynamic> json) {
    return PartnerReviewModel(
      reviewId: (json['reviewId'] ?? json['ReviewId'] ?? '').toString(),
      rating: int.tryParse((json['rating'] ?? json['Rating'] ?? 0).toString()) ?? 0,
      comment: (json['comment'] ?? json['Comment'] ?? '').toString(),
      customerName: (json['customerName'] ?? json['CustomerName'] ?? json['userFullName'] ?? json['UserFullName'] ?? json['memberName'] ?? json['MemberName'] ?? 'Hội viên').toString(),
      gymName: (json['gymName'] ?? json['GymName'] ?? '').toString(),
      className: (json['className'] ?? json['ClassName'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['createdAt'] ?? json['CreatedAt'] ?? '').toString()) ?? DateTime.now(),
    );
  }
}
