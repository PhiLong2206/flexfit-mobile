import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> login({required String email, required String password});

  Future<AuthSession> googleLogin();
  Future<AuthSession> googleLoginWithIdToken(String idToken);

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  });

  Future<void> verifyEmail({required String email, required String otpCode});

  Future<void> resendOtp({required String email});

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
