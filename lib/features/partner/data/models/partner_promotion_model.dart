class PartnerPromotionModel {
  final String promotionId;
  final String title;
  final String description;
  final int discountPercent;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const PartnerPromotionModel({
    required this.promotionId,
    required this.title,
    required this.description,
    required this.discountPercent,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory PartnerPromotionModel.fromJson(Map<String, dynamic> json) {
    return PartnerPromotionModel(
      promotionId: (json['promotionId'] ?? json['PromotionId'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? '').toString(),
      description: (json['description'] ?? json['Description'] ?? '').toString(),
      discountPercent: int.tryParse((json['discountPercent'] ?? json['DiscountPercent'] ?? 0).toString()) ?? 0,
      startDate: DateTime.tryParse((json['startDate'] ?? json['StartDate'] ?? '').toString()) ?? DateTime.now(),
      endDate: DateTime.tryParse((json['endDate'] ?? json['EndDate'] ?? '').toString()) ?? DateTime.now(),
      isActive: json['isActive'] ?? json['IsActive'] ?? false,
    );
  }
}
