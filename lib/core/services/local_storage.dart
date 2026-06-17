import 'dart:convert';

class LocalStorage {
  LocalStorage._();

  static String? _token;

  // TODO: Replace with shared_preferences once the package is available.
  static Future<void> saveToken(String token) async {
    _token = token;
  }

  static Future<String?> getToken() async => _token;

  static Future<void> removeToken() async {
    _token = null;
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
