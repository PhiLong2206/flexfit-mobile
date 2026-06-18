import 'package:dio/dio.dart';

class BookingRepository {
  // Thay url này bằng URL deploy thực tế hoặc IP mạng LAN của backend nhóm ông nhé
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.flexfit.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  // --- API CHI TIẾT (GET) ---
  Future<Response> getGymDetail(String gymId) async {
    return await _dio.get('/api/gyms/$gymId');
  }

  Future<Response> getClassDetail(String classId) async {
    return await _dio.get('/api/classes/$classId');
  }

  // --- API ĐẶT LỊCH (POST) ---
  Future<Response> bookGym(String gymId, String date, String timeSlot) async {
    return await _dio.post('/api/bookings/gym', data: {
      'gymId': gymId,
      'date': date,
      'timeSlot': timeSlot,
    });
  }

  Future<Response> bookClass(String classId) async {
    return await _dio.post('/api/bookings/class', data: {
      'classId': classId,
    });
  }

  // --- API LỊCH SỬ / DANH SÁCH (GET) ---
  Future<Response> getMyGymBookings() async {
    return await _dio.get('/api/bookings/gym/my-bookings');
  }

  Future<Response> getMyClassBookings() async {
    return await _dio.get('/api/bookings/class/my-bookings');
  }

  // --- API HỦY LỊCH (PUT) ---
  Future<Response> cancelGymBooking(String bookingId) async {
    return await _dio.put('/api/bookings/gym/$bookingId/cancel');
  }

  Future<Response> cancelClassBooking(String bookingId) async {
    return await _dio.put('/api/bookings/class/$bookingId/cancel');
  }
}