import '../../data/models/ai_models.dart';
import '../repositories/ai_repository.dart';

class GetWorkoutSuggestionUseCase {
  const GetWorkoutSuggestionUseCase(this.repository);

  final AiRepository repository;

  Future<AiSuggestionModel> call() {
    return repository.getWorkoutSuggestion();
  }
}
