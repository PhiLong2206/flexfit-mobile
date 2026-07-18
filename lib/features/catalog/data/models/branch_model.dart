import '../../domain/entities/branch.dart';

class BranchModel extends Branch {
  const BranchModel({
    required super.id,
    required super.gymId,
    required super.name,
    super.address,
    super.city,
    super.district,
    super.openTime,
    super.closeTime,
    super.thumbnailUrl,
    required super.creditCost,
    required super.isActive,
    super.staffs,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: _readStringAny(json, const ['branchId', 'id']) ?? '',
      gymId: _readStringAny(json, const ['gymId']) ?? '',
      name: _read(json, 'branchName')?.toString() ?? 'FlexFit Branch',
      address: _readString(json, 'address'),
      city: _readString(json, 'city'),
      district: _readString(json, 'district'),
      openTime: _readString(json, 'openTime'),
      closeTime: _readString(json, 'closeTime'),
      thumbnailUrl: _readString(json, 'thumbnailUrl'),
      creditCost:
          int.tryParse(_read(json, 'creditCost')?.toString() ?? '') ?? 0,
      isActive:
          bool.tryParse(_read(json, 'isActive')?.toString() ?? '') ?? true,
      staffs: json['staffs'] ?? json['Staffs'],
    );
  }
}

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

String? _readStringAny(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = _readString(json, key);
    if (value != null) {
      return value;
    }
  }
  return null;
}
