class Branch {
  const Branch({
    required this.id,
    required this.gymId,
    required this.name,
    this.address,
    this.city,
    this.district,
    this.openTime,
    this.closeTime,
    this.thumbnailUrl,
    required this.creditCost,
    required this.isActive,
  });

  final String id;
  final String gymId;
  final String name;
  final String? address;
  final String? city;
  final String? district;
  final String? openTime;
  final String? closeTime;
  final String? thumbnailUrl;
  final int creditCost;
  final bool isActive;

  String get displayAddress {
    final parts = [
      address,
      district,
      city,
    ].where((part) => part != null && part.trim().isNotEmpty).cast<String>();
    final value = parts.join(', ');
    return value.isEmpty ? name : value;
  }
}
