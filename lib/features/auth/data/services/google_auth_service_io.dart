import 'package:google_sign_in/google_sign_in.dart';

import 'google_login_exception.dart';

class GoogleAuthService {
  bool _initialized = false;

  Future<String> signInAndGetIdToken({required String clientId}) async {
    final signIn = GoogleSignIn.instance;
    if (!_initialized) {
      await signIn.initialize(clientId: clientId, serverClientId: clientId);
      _initialized = true;
    }

    if (!signIn.supportsAuthenticate()) {
      throw const GoogleLoginException(
        'Google đăng nhập không được hỗ trợ trên nền tảng này.',
      );
    }

    final account = await signIn.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw const GoogleLoginException(
        'Không nhận được Google token. Vui lòng thử lại.',
      );
    }
    return idToken;
  }
}
