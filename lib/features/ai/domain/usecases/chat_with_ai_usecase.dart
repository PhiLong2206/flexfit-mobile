import '../../data/models/ai_models.dart';
import '../repositories/ai_repository.dart';

class ChatWithAiUseCase {
  const ChatWithAiUseCase(this.repository);

  final AiRepository repository;

  Future<AiChatResponseModel> call(AiChatRequestModel request) {
    return repository.sendChatMessage(request);
  }
}
