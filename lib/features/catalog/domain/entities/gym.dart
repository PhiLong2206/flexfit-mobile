class Gym {
  const Gym({
    required this.id,
    required this.name,
    this.description,
    this.thumbnailUrl,
    this.phoneNumber,
    this.email,
    this.branchId,
    this.branchName,
    this.branchAddress,
    required this.status,
    required this.ratingAverage,
    required this.totalReviews,
  });

  final String id;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final String? phoneNumber;
  final String? email;
  final String? branchId;
  final String? branchName;
  final String? branchAddress;
  final String status;
  final double ratingAverage;
  final int totalReviews;
}
