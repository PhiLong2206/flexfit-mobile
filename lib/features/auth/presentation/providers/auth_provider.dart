import 'package:flutter/foundation.dart';

import '../../domain/usecases/google_login_usecase.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required GoogleLoginUseCase googleLoginUseCase})
    : _googleLoginUseCase = googleLoginUseCase;

  final GoogleLoginUseCase _googleLoginUseCase;

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isGoogleLoading => _isGoogleLoading;
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
