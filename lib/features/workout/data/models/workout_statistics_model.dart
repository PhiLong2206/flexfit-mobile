class WorkoutStatisticsModel {
  const WorkoutStatisticsModel({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalCalories,
    required this.weeklyCompletionRate,
  });

  final int totalWorkouts;
  final int totalMinutes;
  final double totalCalories;
  final double weeklyCompletionRate;

  factory WorkoutStatisticsModel.fromJson(Map<String, dynamic> json) {
    return WorkoutStatisticsModel(
      totalWorkouts: int.tryParse(_read(json, 'totalWorkouts')?.toString() ?? '') ?? 0,
      totalMinutes: int.tryParse(_read(json, 'totalMinutes')?.toString() ?? '') ?? 0,
      totalCalories: double.tryParse(_read(json, 'totalCalories')?.toString() ?? '') ?? 0.0,
      weeklyCompletionRate: double.tryParse(_read(json, 'weeklyCompletionRate')?.toString() ?? '') ?? 0.0,
    );
  }
}

Object? _read(Map<String, dynamic> json, String key) {
  final pascalKey = key[0].toUpperCase() + key.substring(1);
  return json[key] ?? json[pascalKey];
}
