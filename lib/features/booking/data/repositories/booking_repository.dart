import '../../../../core/services/api_client.dart';
import '../models/booking_model.dart';
import 'package:dio/dio.dart'; // Giữ lại để dùng object Response cho 2 hàm chi tiết của ông

class BookingRepository {
  BookingRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  // --- 2 HÀM CHI TIẾT CHÍNH CHỦ CỦA ÔNG (Đã được sửa sang dùng _apiClient cho đồng bộ nhóm) ---
  Future<dynamic> getGymDetail(String gymId) async {
    return await _apiClient.get('/bookings/gyms/$gymId');
  }

  Future<dynamic> getClassDetail(String classId) async {
    return await _apiClient.get('/bookings/classes/$classId');
  }

  // --- CÁC HÀM CỦA CẢ NHÓM (Nhóm trưởng viết bằng ApiClient) ---
  Future<BookingModel> bookGym({
    required String branchId,
    required String sessionName,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final response = await _apiClient.post(
      '/bookings/gym',
      body: {
        'branchId': branchId,
        'sessionName': sessionName,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      },
    );
    final data = _readData(response);
    return BookingModel.fromGymJson(data);
  }

  Future<BookingModel> bookClass(String classId) async {
    final response = await _apiClient.post(
      '/bookings/class',
      body: {'classId': classId},
    );
    final data = _readData(response);
    return BookingModel.fromClassJson(data);
  }

  Future<List<BookingModel>> getMyGymBookings() async {
    final response = await _apiClient.get('/bookings/gym/my-bookings');
    return (response as List)
        .map(
          (item) =>
          BookingModel.fromGymJson(Map<String, dynamic>.from(item as Map)),
    )
        .toList();
  }

  Future<List<BookingModel>> getMyClassBookings() async {
    final response = await _apiClient.get('/bookings/class/my-bookings');
    return (response as List)
        .map(
          (item) => BookingModel.fromClassJson(
        Map<String, dynamic>.from(item as Map),
      ),
    )
        .toList();
  }

  Future<List<BookingModel>> getMyBookings() async {
    final results = await Future.wait([
      getMyGymBookings(),
      getMyClassBookings(),
    ]);
    final bookings = [...results[0], ...results[1]];
    bookings.sort((a, b) => a.startTime.compareTo(b.startTime));
    return bookings;
  }

  Future<void> cancelBooking(BookingModel booking) async {
    final segment = booking.type == BookingType.gym ? 'gym' : 'class';
    await _apiClient.put('/bookings/$segment/${booking.id}/cancel');
  }

  Map<String, dynamic> _readData(dynamic response) {
    final map = Map<String, dynamic>.from(response as Map);
    final data = map['data'] ?? map['Data'];
    return Map<String, dynamic>.from(data as Map);
  }
}