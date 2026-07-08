import '../../domain/entities/gym.dart';

class GymModel extends Gym {
  const GymModel({
    required super.id,
    required super.name,
    super.description,
    super.thumbnailUrl,
    super.phoneNumber,
    super.email,
    super.branchId,
    super.branchName,
    super.branchAddress,
    required super.status,
    required super.ratingAverage,
    required super.totalReviews,
  });

  factory GymModel.fromJson(Map<String, dynamic> json) {
    return GymModel(
      id: _read(json, 'gymId').toString(),
      name: _read(json, 'gymName')?.toString() ?? 'Phòng gym FlexFit',
      description: _read(json, 'description')?.toString(),
      thumbnailUrl: _read(json, 'thumbnailUrl')?.toString(),
      phoneNumber: _read(json, 'phoneNumber')?.toString(),
      email: _read(json, 'email')?.toString(),
      branchId: _readStringAny(json, const [
        'branchId',
        'primaryBranchId',
        'defaultBranchId',
      ]),
      branchName: _readStringAny(json, const [
        'branchName',
        'primaryBranchName',
        'defaultBranchName',
      ]),
      branchAddress: _readStringAny(json, const [
        'branchAddress',
        'address',
        'primaryBranchAddress',
        'defaultBranchAddress',
      ]),
      status: _read(json, 'status')?.toString() ?? '',
      ratingAverage:
          double.tryParse(_read(json, 'ratingAverage')?.toString() ?? '') ?? 0,
      totalReviews:
          int.tryParse(_read(json, 'totalReviews')?.toString() ?? '') ?? 0,
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}

String? _readStringAny(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _read(json, key)?.toString().trim();
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }
  return null;
}
