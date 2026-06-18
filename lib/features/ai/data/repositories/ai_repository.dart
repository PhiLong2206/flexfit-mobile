import '../../../../core/services/api_client.dart';
import '../models/ai_suggestion_model.dart';

class AiRepository {
  AiRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<WorkoutSuggestionModel> getSuggestWorkout() async {
    try {
      final response = await _apiClient.get('/AI/suggest-workout');
      if (response is Map) {
        return WorkoutSuggestionModel.fromJson(Map<String, dynamic>.from(response));
      }
      return WorkoutSuggestionModel(
        title: 'Gợi ý lịch tập hôm nay',
        description: response.toString(),
        points: [],
      );
    } catch (e) {
      // Return a structured error or fallback suggestion
      return const WorkoutSuggestionModel(
        title: 'Gợi ý lịch tập hôm nay',
        description: 'Không thể kết nối đến hệ thống AI để tải gợi ý tập luyện.',
        points: [
          'Hãy tập trung vào các bài tập Cardio hoặc HIIT nhẹ nhàng.',
          'Uống đủ nước và thực hiện giãn cơ trước và sau buổi tập.',
        ],
      );
    }
  }

  Future<ClassSuggestionModel> getSuggestClasses() async {
    try {
      final response = await _apiClient.get('/AI/suggest-classes');
      if (response is Map) {
        return ClassSuggestionModel.fromJson(Map<String, dynamic>.from(response));
      }
      return ClassSuggestionModel(
        title: 'Hôm nay nên tập gì',
        description: response.toString(),
        points: [],
      );
    } catch (e) {
      return const ClassSuggestionModel(
        title: 'Hôm nay nên tập gì',
        description: 'Không thể kết nối đến hệ thống AI để tải gợi ý lớp học.',
        points: [
          'Tham gia lớp Yoga để cải thiện độ dẻo dai.',
          'Tham gia lớp Boxing hoặc Group X để đốt cháy calories hiệu quả.',
        ],
      );
    }
  }

  Future<String> sendChatMessage(String message) async {
    final response = await _apiClient.post(
      '/AI/chat',
      body: {'message': message},
    );
    if (response is Map) {
      final reply = response['response'] ??
          response['Response'] ??
          response['reply'] ??
          response['Reply'] ??
          response['message'] ??
          response['Message'] ??
          response['content'] ??
          response['Content'];
      if (reply != null) {
        return reply.toString();
      }
    }
    return response.toString();
  }
}
