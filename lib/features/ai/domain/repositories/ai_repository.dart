import '../../data/models/ai_models.dart';

abstract class AiRepository {
  Future<AiSuggestionModel> getWorkoutSuggestion();
  Future<AiSuggestionModel> getClassSuggestion();
  Future<AiChatResponseModel> sendChatMessage(AiChatRequestModel request);
}
