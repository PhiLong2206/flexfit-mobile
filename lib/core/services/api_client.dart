import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../constants/app_constants.dart';
import 'api_transport.dart';
import 'api_transport_factory.dart';
import 'local_storage.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({String? baseUrl, Object? httpClient, ApiTransport? transport})
    : _baseUrl = baseUrl ?? AppConstants.baseUrl,
      _transport = transport ?? createApiTransport(httpClient) {
    debugPrint('API Base URL: $_baseUrl');
  }

  final String _baseUrl;
  final ApiTransport _transport;

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
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await LocalStorage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    final response = await _transport.send(
      method,
      uri,
      headers: headers,
      body: body == null ? null : jsonEncode(body),
    );
    final responseText = response.body;
    final decoded = _decode(responseText);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractError(decoded, responseText),
        statusCode: response.statusCode,
        body: responseText,
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
