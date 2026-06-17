import 'package:flutter/foundation.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepositoryImpl();

  final AuthRepository _authRepository;

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
      await _authRepository.googleLogin();
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
