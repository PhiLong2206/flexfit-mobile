class WorkoutHistoryModel {
  const WorkoutHistoryModel({
    required this.id,
    required this.title,
    this.gymName,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.notes,
    required this.status,
  });

  final String id;
  final String title;
  final String? gymName;
  final DateTime startTime;
  final DateTime endTime;
  final int durationMinutes;
  final double caloriesBurned;
  final String notes;
  final String status;

  factory WorkoutHistoryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryModel(
      id: _read(json, 'workoutHistoryId')?.toString() ?? _read(json, 'id')?.toString() ?? '',
      title: _read(json, 'sessionName')?.toString() ?? _read(json, 'title')?.toString() ?? 'Buổi tập',
      gymName: _read(json, 'gymName')?.toString() ?? _read(json, 'branchName')?.toString(),
      startTime: DateTime.tryParse(_read(json, 'startTime')?.toString() ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(_read(json, 'endTime')?.toString() ?? '') ?? DateTime.now(),
      durationMinutes: int.tryParse(_read(json, 'durationMinutes')?.toString() ?? '') ?? 0,
      caloriesBurned: double.tryParse(_read(json, 'caloriesBurned')?.toString() ?? '') ?? 0.0,
      notes: _read(json, 'notes')?.toString() ?? '',
      status: _read(json, 'status')?.toString() ?? 'completed',
    );
  }

  WorkoutHistoryModel copyWith({
    String? id,
    String? title,
    String? gymName,
    DateTime? startTime,
    DateTime? endTime,
    int? durationMinutes,
    double? caloriesBurned,
    String? notes,
    String? status,
  }) {
    return WorkoutHistoryModel(
      id: id ?? this.id,
      title: title ?? this.title,
      gymName: gymName ?? this.gymName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
