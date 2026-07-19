import '../../../../core/network/api_client.dart';
import '../models/review_model.dart';

class ReviewRepository {
  ReviewRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<List<ReviewModel>> getGymReviews(String gymId) async {
    final response = await _apiClient.get('/Review/gym/$gymId');
    return (response as List)
        .map((item) => ReviewModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<ReviewModel> submitReview({
    required String gymId,
    required double rating,
    required String comment,
  }) async {
    final response = await _apiClient.post(
      '/Review',
      body: {
        'gymId': gymId,
        'rating': rating,
        'comment': comment,
      },
    );
    final data = Map<String, dynamic>.from(response as Map);
    final reviewData = data['data'] ?? data['Data'] ?? data;
    return ReviewModel.fromJson(Map<String, dynamic>.from(reviewData as Map));
  }
}
