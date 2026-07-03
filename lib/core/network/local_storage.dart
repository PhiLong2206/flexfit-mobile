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

  static Future<bool> hasValidAuthToken({DateTime? now}) async {
    final token = await getToken();
    if (token == null || token.trim().isEmpty) {
      return false;
    }

    final payload = _decodeJwtPayload(token);
    if (payload == null) {
      await removeToken();
      return false;
    }

    final expiresAt = _readJwtExpiresAt(payload);
    if (expiresAt == null || !expiresAt.isAfter(now ?? DateTime.now())) {
      await removeToken();
      return false;
    }

    return true;
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

    final payload = _decodeJwtPayload(token);
    if (payload == null) return null;

    const nameIdentifierClaim =
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
    return (payload[nameIdentifierClaim] ??
            payload['nameid'] ??
            payload['sub'] ??
            payload['userId'])
        ?.toString();
  }

  static Map<String, dynamic>? _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length < 2) return null;

    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
      if (payload is! Map) return null;
      return Map<String, dynamic>.from(payload);
    } catch (_) {
      return null;
    }
  }

  static DateTime? _readJwtExpiresAt(Map<String, dynamic> payload) {
    final exp = payload['exp'];
    final seconds = exp is num
        ? exp.toInt()
        : int.tryParse(exp?.toString() ?? '');
    if (seconds == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
  }
}
