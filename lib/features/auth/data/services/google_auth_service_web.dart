import 'dart:async';

import 'package:google_identity_services_web/id.dart' as google_id;
import 'package:google_identity_services_web/loader.dart' as google_loader;

import '../../../../core/constants/app_constants.dart';
import 'google_login_exception.dart';

class GoogleAuthService {
  Completer<String>? _pendingCredential;
  bool _initialized = false;

  Future<String> signInAndGetIdToken({required String clientId}) async {
    await google_loader.loadWebSdk();

    if (!_initialized) {
      google_id.id.initialize(
        google_id.IdConfiguration(
          client_id: clientId,
          callback: _handleCredential,
          use_fedcm_for_prompt: true,
        ),
      );
      _initialized = true;
    }

    final completer = Completer<String>();
    _pendingCredential = completer;
    google_id.id.prompt(_handlePromptMoment);

    return completer.future.timeout(
      const Duration(minutes: 2),
      onTimeout: () {
        throw GoogleLoginException(
          'Google đăng nhập quá thời gian chờ. Hãy kiểm tra OAuth origin ${AppConstants.googleOAuthOrigin}.',
        );
      },
    );
  }

  void _handleCredential(google_id.CredentialResponse response) {
    final completer = _pendingCredential;
    if (completer == null || completer.isCompleted) {
      return;
    }

    final error = response.error;
    if (error != null && error.isNotEmpty) {
      final detail = response.error_detail;
      completer.completeError(
        GoogleLoginException(
          detail == null || detail.isEmpty ? error : '$error: $detail',
        ),
      );
      return;
    }

    final credential = response.credential;
    if (credential == null || credential.isEmpty) {
      completer.completeError(
        const GoogleLoginException(
          'Không nhận được Google token. Vui lòng thử lại.',
        ),
      );
      return;
    }

    completer.complete(credential);
  }

  void _handlePromptMoment(google_id.PromptMomentNotification notification) {
    final completer = _pendingCredential;
    if (completer == null || completer.isCompleted) {
      return;
    }

    if (notification.isNotDisplayed()) {
      final reason = notification.getNotDisplayedReason();
      completer.completeError(
        GoogleLoginException(
          'Google popup/sign-in không hiển thị: ${reason ?? 'unknown'}. Hãy cấu hình Authorized JavaScript origin ${AppConstants.googleOAuthOrigin}.',
        ),
      );
      return;
    }

    if (notification.isSkippedMoment()) {
      final reason = notification.getSkippedReason();
      completer.completeError(
        GoogleLoginException(
          'Google đăng nhập bị bỏ qua: ${reason ?? 'unknown'}.',
        ),
      );
      return;
    }

    if (notification.isDismissedMoment()) {
      final reason = notification.getDismissedReason();
      if (reason == google_id.MomentDismissedReason.credential_returned) {
        return;
      }
      completer.completeError(
        GoogleLoginException(
          'Google đăng nhập đã đóng: ${reason ?? 'unknown'}.',
        ),
      );
    }
  }
}
