import 'google_login_exception.dart';

class GoogleAuthService {
  Future<String> signInAndGetIdToken({required String clientId}) {
    throw const GoogleLoginException(
      'Google đăng nhập không được hỗ trợ trên nền tảng này.',
    );
  }
}
