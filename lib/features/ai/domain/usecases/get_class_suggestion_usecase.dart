import '../../data/models/ai_models.dart';
import '../repositories/ai_repository.dart';

class GetClassSuggestionUseCase {
  const GetClassSuggestionUseCase(this.repository);

  final AiRepository repository;

  Future<AiSuggestionModel> call() {
    return repository.getClassSuggestion();
  }
}
