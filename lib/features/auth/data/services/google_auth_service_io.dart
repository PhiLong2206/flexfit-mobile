import 'dart:developer' as developer;

import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/constants/app_constants.dart';
import 'google_login_exception.dart';

class GoogleAuthService {
  bool _initialized = false;

  Future<String> signInAndGetIdToken({required String clientId}) async {
    final signIn = GoogleSignIn.instance;

    if (!_initialized) {
      await signIn.initialize(
        serverClientId: AppConstants.googleClientId,
      );
      _initialized = true;
      developer.log('GoogleAuthService mobile initialized');
    }

    try {
      await signIn.signOut();

      final account = await signIn.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw const GoogleLoginException('Không lấy được Google ID Token.');
      }

      return idToken;
    } on GoogleSignInException catch (error) {
      throw GoogleLoginException(error.toString());
    }
  }
}