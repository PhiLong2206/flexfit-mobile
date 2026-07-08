import 'package:flutter/foundation.dart';

import '../../domain/usecases/google_login_usecase.dart';
import '../../domain/usecases/change_password_usecase.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required GoogleLoginUseCase googleLoginUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
  }) : _googleLoginUseCase = googleLoginUseCase,
       _changePasswordUseCase = changePasswordUseCase;

  final GoogleLoginUseCase _googleLoginUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isChangingPassword = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;
  bool get isChangingPassword => _isChangingPassword;
  String? get error => _error;

  Future<void> googleLogin() async {
    if (_isGoogleLoading) {
      return;
    }
    _setGoogleLoading(true);
    try {
      await _googleLoginUseCase();
      _error = null;
    } catch (error) {
      _error = error.toString();
      debugPrint('Google login failed: $error');
      rethrow;
    } finally {
      _setGoogleLoading(false);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_isChangingPassword) return;

    _isChangingPassword = true;
    _error = null;
    notifyListeners();

    try {
      await _changePasswordUseCase(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (error) {
      _error = error.toString();
      rethrow;
    } finally {
      _isChangingPassword = false;
      notifyListeners();
    }
  }

  void setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }
    _isLoading = value;
    notifyListeners();
  }

  void _setGoogleLoading(bool value) {
    if (_isGoogleLoading == value) {
      return;
    }
    _isGoogleLoading = value;
    if (value) {
      _error = null;
    }
    notifyListeners();
  }
}
