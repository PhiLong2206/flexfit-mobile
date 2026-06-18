class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.gymId,
    required this.rating,
    required this.comment,
    required this.userFullName,
    required this.createdAt,
  });

  final String id;
  final String gymId;
  final double rating;
  final String comment;
  final String userFullName;
  final DateTime createdAt;

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: _read(json, 'reviewId')?.toString() ?? _read(json, 'id')?.toString() ?? '',
      gymId: _read(json, 'gymId')?.toString() ?? '',
      rating: double.tryParse(_read(json, 'rating')?.toString() ?? '') ?? 0.0,
      comment: _read(json, 'comment')?.toString() ?? '',
      userFullName: _read(json, 'userFullName')?.toString() ?? 
                    _read(json, 'fullName')?.toString() ?? '',
      createdAt: DateTime.tryParse(_read(json, 'createdAt')?.toString() ?? '') ?? DateTime.now(),
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
