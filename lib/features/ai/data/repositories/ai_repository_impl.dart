import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_data_source.dart';
import '../models/ai_models.dart';

class AiRepositoryImpl implements AiRepository {
  const AiRepositoryImpl({required this.remoteDataSource});

  final AiRemoteDataSource remoteDataSource;

  @override
  Future<AiSuggestionModel> getWorkoutSuggestion() {
    return remoteDataSource.getWorkoutSuggestion();
  }

  @override
  Future<AiSuggestionModel> getClassSuggestion() {
    return remoteDataSource.getClassSuggestion();
  }

  @override
  Future<AiChatResponseModel> sendChatMessage(AiChatRequestModel request) {
    return remoteDataSource.sendChatMessage(request);
  }
}
