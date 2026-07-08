import '../../../../core/network/api_client.dart';
import '../../../catalog/data/models/fitness_class_model.dart';
import '../models/staff_booking_model.dart';
import '../models/staff_check_in_log_model.dart';
import '../models/staff_review_model.dart';

abstract class StaffRemoteDataSource {
  Future<List<StaffBookingModel>> getCheckInCandidates();
  Future<List<StaffCheckInLogModel>> getManagedCheckInLogs();
  Future<List<FitnessClassModel>> getStaffSchedule();
  Future<StaffCheckInLogModel> checkInGym({required String bookingCode});
  Future<StaffCheckInLogModel> checkInClass({
    required String userId,
    required String classBookingId,
  });
  Future<String?> getGymIdForBranch(String branchId);
  Future<List<StaffReviewModel>> getGymReviews(String gymId);
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  StaffRemoteDataSourceImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  @override
  Future<List<StaffBookingModel>> getCheckInCandidates() async {
    final response = await _apiClient.get('/bookings/staff/check-in');
    return _readList(
      response,
    ).map((json) => StaffBookingModel.fromJson(json)).toList(growable: false);
  }

  @override
  Future<List<StaffCheckInLogModel>> getManagedCheckInLogs() async {
    final response = await _apiClient.get('/check-in-logs/manager/all');
    return _readList(response)
        .map((json) => StaffCheckInLogModel.fromJson(json))
        .toList(growable: false);
  }

  @override
  Future<List<FitnessClassModel>> getStaffSchedule() async {
    final response = await _apiClient.get('/classes/staff-schedule');
    return _readList(
      response,
    ).map((json) => FitnessClassModel.fromJson(json)).toList(growable: false);
  }

  @override
  Future<StaffCheckInLogModel> checkInGym({required String bookingCode}) async {
    final response = await _apiClient.post(
      '/check-in-logs/gym',
      body: {'bookingCode': bookingCode},
    );
    return StaffCheckInLogModel.fromJson(_readData(response));
  }

  @override
  Future<StaffCheckInLogModel> checkInClass({
    required String userId,
    required String classBookingId,
  }) async {
    final response = await _apiClient.post(
      '/check-in-logs/class',
      body: {
        'userId': userId,
        'classBookingId': classBookingId,
        'status': 'Success',
      },
    );
    return StaffCheckInLogModel.fromJson(_readData(response));
  }

  @override
  Future<String?> getGymIdForBranch(String branchId) async {
    final response = await _apiClient.get('/branches/$branchId');
    if (response is! Map) return null;
    final map = Map<String, dynamic>.from(response);
    final value = map['gymId'] ?? map['GymId'];
    final gymId = value?.toString().trim();
    return gymId == null || gymId.isEmpty ? null : gymId;
  }

  @override
  Future<List<StaffReviewModel>> getGymReviews(String gymId) async {
    final response = await _apiClient.get('/Review/gym/$gymId');
    return _readList(response)
        .map(StaffReviewModel.fromJson)
        .where((review) => review.reviewId.isNotEmpty)
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _readList(dynamic response) {
    final items = response is List
        ? response
        : response is Map
        ? response['data'] ?? response['Data'] ?? response['items']
        : null;
    if (items is! List) return const [];
    return items
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }

  Map<String, dynamic> _readData(dynamic response) {
    if (response is! Map) return const {};
    final map = Map<String, dynamic>.from(response);
    final data = map['data'] ?? map['Data'];
    return data is Map ? Map<String, dynamic>.from(data) : map;
  }
}
