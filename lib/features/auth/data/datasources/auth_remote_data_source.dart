import 'package:flutter/foundation.dart';

import '../../../../core/network/api_client.dart';
import '../models/auth_session_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/Auth/login',
      body: {'email': email, 'password': password},
    );
    return AuthSessionModel.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<AuthSessionModel> googleLogin({required String idToken}) async {
    try {
      final response = await _apiClient.post(
        '/Auth/google-login',
        body: {'idToken': idToken},
      );
      return AuthSessionModel.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } catch (error) {
      if (error is ApiException && error.body?.isNotEmpty == true) {
        debugPrint('Backend Google login failed: ${error.body}');
      } else {
        debugPrint('Backend Google login failed: $error');
      }
      rethrow;
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    await _apiClient.post(
      '/Auth/register',
      body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phoneNumber': phoneNumber,
      },
    );
  }

  Future<void> verifyEmail({
    required String email,
    required String otpCode,
  }) async {
    await _apiClient.post(
      '/Auth/verify-email',
      body: {'email': email, 'otpCode': otpCode},
    );
  }

  Future<void> resendOtp({required String email}) async {
    await _apiClient.post(
      '/Auth/resend-otp',
      body: {'email': email, 'reason': 'VERIFY_EMAIL'},
    );
  }
}
