import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RememberedCredentials {
  const RememberedCredentials({
    required this.email,
    required this.password,
    required this.rememberMe,
  });

  final String email;
  final String password;
  final bool rememberMe;
}

class LocalStorage {
  LocalStorage._();

  static const _tokenKey = 'auth_token';
  static const _rememberMeKey = 'remember_me';
  static const _rememberedEmailKey = 'remembered_email';
  static const _rememberedPasswordKey = 'remembered_password';

  static String? _token;

  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    if (_token != null) {
      return _token;
    }
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    return _token;
  }

  static Future<void> removeToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> saveRememberedCredentials({
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, true);
    await prefs.setString(_rememberedEmailKey, email);
    await prefs.setString(_rememberedPasswordKey, password);
  }

  static Future<void> clearRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMeKey, false);
    await prefs.remove(_rememberedEmailKey);
    await prefs.remove(_rememberedPasswordKey);
  }

  static Future<RememberedCredentials> getRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    return RememberedCredentials(
      email: rememberMe ? prefs.getString(_rememberedEmailKey) ?? '' : '',
      password: rememberMe ? prefs.getString(_rememberedPasswordKey) ?? '' : '',
      rememberMe: rememberMe,
    );
  }

  static Future<String?> getUserIdFromToken() async {
    final token = await getToken();
    if (token == null) return null;

    final parts = token.split('.');
    if (parts.length < 2) return null;

    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      if (payload is! Map<String, dynamic>) return null;

      const nameIdentifierClaim =
          'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
      return (payload[nameIdentifierClaim] ??
              payload['nameid'] ??
              payload['sub'] ??
              payload['userId'])
          ?.toString();
    } catch (_) {
      return null;
    }
  }
}
