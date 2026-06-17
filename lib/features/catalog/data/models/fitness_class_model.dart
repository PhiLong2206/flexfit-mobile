import '../../domain/entities/fitness_class.dart';

class FitnessClassModel extends FitnessClass {
  const FitnessClassModel({
    required super.id,
    required super.branchId,
    required super.branchName,
    required super.categoryId,
    required super.categoryName,
    required super.name,
    super.description,
    super.coachName,
    required super.startTime,
    required super.endTime,
    required super.capacity,
    required super.creditCost,
    super.difficultyLevel,
    super.caloriesBurnEstimate,
    super.thumbnailUrl,
    required super.status,
  });

  factory FitnessClassModel.fromJson(Map<String, dynamic> json) {
    return FitnessClassModel(
      id: _read(json, 'classId').toString(),
      branchId: _read(json, 'branchId').toString(),
      branchName: _read(json, 'branchName')?.toString() ?? '',
      categoryId: _read(json, 'categoryId').toString(),
      categoryName: _read(json, 'categoryName')?.toString() ?? '',
      name: _read(json, 'className')?.toString() ?? 'Lớp học FlexFit',
      description: _read(json, 'description')?.toString(),
      coachName: _read(json, 'coachName')?.toString(),
      startTime:
          DateTime.tryParse(_read(json, 'startTime')?.toString() ?? '') ??
          DateTime.now(),
      endTime:
          DateTime.tryParse(_read(json, 'endTime')?.toString() ?? '') ??
          DateTime.now(),
      capacity: int.tryParse(_read(json, 'capacity')?.toString() ?? '') ?? 0,
      creditCost:
          int.tryParse(_read(json, 'creditCost')?.toString() ?? '') ?? 0,
      difficultyLevel: _read(json, 'difficultyLevel')?.toString(),
      caloriesBurnEstimate: int.tryParse(
        _read(json, 'caloriesBurnEstimate')?.toString() ?? '',
      ),
      thumbnailUrl: _read(json, 'thumbnailUrl')?.toString(),
      status: _read(json, 'status')?.toString() ?? '',
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
