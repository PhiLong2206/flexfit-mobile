import 'package:flutter/material.dart';
import '../../domain/usecases/get_workout_suggestion_usecase.dart';
import '../../domain/usecases/get_class_suggestion_usecase.dart';

class AiSuggestionProvider extends ChangeNotifier {
  AiSuggestionProvider({
    required this.getWorkoutSuggestionUseCase,
    required this.getClassSuggestionUseCase,
  });

  final GetWorkoutSuggestionUseCase getWorkoutSuggestionUseCase;
  final GetClassSuggestionUseCase getClassSuggestionUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _suggestionText;
  String? get suggestionText => _suggestionText;

  String? _error;
  String? get error => _error;

  bool _hasFetched = false;

  Future<void> fetchSuggestion({bool force = false}) async {
    if ((_isLoading || _hasFetched) && !force) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For dashboard, we might want a workout suggestion
      final suggestion = await getWorkoutSuggestionUseCase();
      _suggestionText = suggestion.suggestion;
      _hasFetched = true;
    } catch (e) {
      _error = 'Không thể tải gợi ý. Thử lại sau.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
