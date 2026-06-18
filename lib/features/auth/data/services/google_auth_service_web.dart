import 'google_login_exception.dart';

class GoogleAuthService {
  Future<String> signInAndGetIdToken({required String clientId}) {
    throw const GoogleLoginException(
      'Google Web đăng nhập phải dùng nút Google được render bởi plugin.',
    );
  }
}
