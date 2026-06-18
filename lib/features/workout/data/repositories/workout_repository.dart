import '../../../../core/services/api_client.dart';
import '../models/workout_history_model.dart';
import '../models/workout_statistics_model.dart';

class WorkoutRepository {
  WorkoutRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<WorkoutHistoryModel>> getMyHistory() async {
    final response = await _apiClient.get('/workoutHistory/my-history');
    return (response as List)
        .map((item) => WorkoutHistoryModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<WorkoutStatisticsModel> getStatistics() async {
    final response = await _apiClient.get('/workoutHistory/statistics');
    return WorkoutStatisticsModel.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<WorkoutHistoryModel> updateWorkoutHistory(
    String id, {
    required int durationMinutes,
    required double caloriesBurned,
    required String notes,
  }) async {
    final response = await _apiClient.put(
      '/workoutHistory/$id',
      body: {
        'durationMinutes': durationMinutes,
        'caloriesBurned': caloriesBurned,
        'notes': notes,
      },
    );
    final data = Map<String, dynamic>.from(response as Map);
    final workoutData = data['data'] ?? data['Data'] ?? data;
    return WorkoutHistoryModel.fromJson(Map<String, dynamic>.from(workoutData as Map));
  }
}
