import 'dart:convert';
import 'dart:io';

import '../constants/app_constants.dart';
import 'local_storage.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({String? baseUrl, HttpClient? httpClient})
    : _baseUrl = baseUrl ?? AppConstants.baseUrl,
      _httpClient = httpClient ?? HttpClient();

  final String _baseUrl;
  final HttpClient _httpClient;

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) {
    return _send('POST', path, body: body);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) {
    return _send('PUT', path, body: body);
  }

  Future<dynamic> patch(String path, {Object? body}) {
    return _send('PATCH', path, body: body);
  }

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(String method, String path, {Object? body}) async {
    final uri = Uri.parse('$_baseUrl${path.startsWith('/') ? path : '/$path'}');
    final request = await _httpClient.openUrl(method, uri);
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, ContentType.json.value);

    final token = await LocalStorage.getToken();
    if (token != null && token.isNotEmpty) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
    }

    if (body != null) {
      request.write(jsonEncode(body));
    }

    final response = await request.close();
    final responseText = await response.transform(utf8.decoder).join();
    final decoded = _decode(responseText);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractError(decoded, responseText),
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) {
      return null;
    }
    try {
      return jsonDecode(body);
    } on FormatException {
      return body;
    }
  }

  String _extractError(dynamic decoded, String raw) {
    if (decoded is Map<String, dynamic>) {
      final message =
          decoded['message'] ??
          decoded['Message'] ??
          decoded['title'] ??
          decoded['error'];
      if (message != null) {
        return message.toString();
      }
      final errors = decoded['errors'];
      if (errors is Map && errors.isNotEmpty) {
        return errors.values.first.toString();
      }
    }
    if (raw.trim().isNotEmpty) {
      return raw;
    }
    return 'Yêu cầu thất bại. Vui lòng thử lại.';
  }
}
