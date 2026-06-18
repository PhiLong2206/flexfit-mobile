import 'package:flutter/material.dart';
import 'models/workout_history_model.dart';
import 'models/workout_statistics_model.dart';
import 'repositories/workout_repository.dart';

class WorkoutNotifier extends ChangeNotifier {
  final _repository = WorkoutRepository();
  List<WorkoutHistoryModel> _history = [];
  WorkoutStatisticsModel? _statistics;
  bool _isLoading = false;
  String? _error;

  List<WorkoutHistoryModel> get history => List.unmodifiable(_history);
  WorkoutStatisticsModel? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _repository.getMyHistory();
      _history = fetched;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStatistics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stats = await _repository.getStatistics();
      _statistics = stats;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<WorkoutHistoryModel> updateWorkout(
    String id, {
    required int durationMinutes,
    required double caloriesBurned,
    required String notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _repository.updateWorkoutHistory(
        id,
        durationMinutes: durationMinutes,
        caloriesBurned: caloriesBurned,
        notes: notes,
      );

      // Update local history item
      final index = _history.indexWhere((item) => item.id == id);
      if (index != -1) {
        final updatedList = List<WorkoutHistoryModel>.from(_history);
        updatedList[index] = updated;
        _history = updatedList;
      }
      return updated;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
