import 'package:flutter/foundation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/local_storage.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../services/google_auth_service.dart';
import '../services/google_login_exception.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    GoogleAuthService? googleAuthService,
  }) : _remoteDataSource = remoteDataSource ?? AuthRemoteDataSource(),
       _googleAuthService = googleAuthService ?? GoogleAuthService();

  final AuthRemoteDataSource _remoteDataSource;
  final GoogleAuthService _googleAuthService;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await LocalStorage.saveToken(session.token);
    return session;
  }

  @override
  Future<AuthSession> googleLogin() async {
    final clientId = AppConstants.googleClientId.trim();
    debugPrint("Google ClientId used: $clientId");
    if (clientId.isEmpty) {
      throw const GoogleLoginException('Google đăng nhập chưa được cấu hình.');
    }

    if (kDebugMode) {
      debugPrint('Google OAuth origin: ${AppConstants.googleOAuthOrigin}');
    }
    debugPrint('Starting Google sign in');
    final idToken = kIsWeb
        ? await _googleAuthService.signInAndGetIdToken(clientId: clientId)
        : await _googleAuthService.signInAndGetIdToken(
            clientId: AppConstants.googleClientId,
          );
    debugPrint('Google token received');
    return googleLoginWithIdToken(idToken);
  }

  @override
  Future<AuthSession> googleLoginWithIdToken(String idToken) async {
    debugPrint('Sending Google token to backend');
    final session = await _remoteDataSource.googleLogin(idToken: idToken);
    await LocalStorage.saveToken(session.token);
    debugPrint('Backend login success');
    return session;
  }

  @override
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) {
    return _remoteDataSource.register(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
    );
  }

  @override
  Future<void> verifyEmail({required String email, required String otpCode}) {
    return _remoteDataSource.verifyEmail(email: email, otpCode: otpCode);
  }

  @override
  Future<void> resendOtp({required String email}) {
    return _remoteDataSource.resendOtp(email: email);
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
