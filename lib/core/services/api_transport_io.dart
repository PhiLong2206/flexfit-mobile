import 'dart:convert';
import 'dart:io';

import 'api_transport.dart';

ApiTransport createApiTransport([Object? httpClient]) {
  if (httpClient == null) {
    return IoApiTransport();
  }
  if (httpClient is HttpClient) {
    return IoApiTransport(httpClient);
  }
  throw ArgumentError.value(
    httpClient,
    'httpClient',
    'Expected a dart:io HttpClient on native platforms.',
  );
}

class IoApiTransport implements ApiTransport {
  IoApiTransport([HttpClient? httpClient])
    : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  @override
  Future<ApiResponse> send(
    String method,
    Uri uri, {
    required Map<String, String> headers,
    String? body,
  }) async {
    final request = await _httpClient.openUrl(method, uri);
    headers.forEach(request.headers.set);

    if (body != null) {
      request.write(body);
    }

    final response = await request.close();
    final responseText = await response.transform(utf8.decoder).join();

    return ApiResponse(statusCode: response.statusCode, body: responseText);
  }
}
