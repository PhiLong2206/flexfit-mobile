import '../../../../core/network/api_client.dart';
import '../../../partner/data/models/partner_review_model.dart';
import '../models/booking_model.dart';
import '../models/review_model.dart';

class ReviewRepository {
  ReviewRepository({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<ReviewModel> createReview({
    required BookingModel booking,
    required int rating,
    required String comment,
  }) async {
    final isGymBooking = booking.type == BookingType.gym;
    final response = await _apiClient.post(
      '/Review',
      body: {
        'bookingId': booking.id,
        'bookingType': isGymBooking ? 'Gym' : 'Class',
        if (isGymBooking) 'gymBookingId': booking.id,
        if (!isGymBooking) 'classBookingId': booking.id,
        'rating': rating,
        'comment': comment.trim().isEmpty ? null : comment.trim(),
      },
    );
    return ReviewModel.fromJson(_readMap(response));
  }

  Future<List<PartnerReviewModel>> getReviewsForGym(String gymId) async {
    try {
      final response = await _apiClient.get('/Review/gym/$gymId');
      final List<PartnerReviewModel> list = [];
      dynamic items = response;
      if (response is Map) {
        items = response['data'] ?? response['Data'] ?? response['items'] ?? response['Items'] ?? response['result'] ?? response['Result'] ?? response;
      }
      if (items is List) {
        for (final item in items) {
          if (item is Map) {
            list.add(PartnerReviewModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
      return list;
    } catch (_) {
      return [];
    }
  }
}

Map<String, dynamic> _readMap(dynamic response) {
  if (response is Map) {
    final data = response['data'] ?? response['Data'];
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return Map<String, dynamic>.from(response);
  }
  return const {};
}
