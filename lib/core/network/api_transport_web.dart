import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'api_transport.dart';

ApiTransport createApiTransport([Object? httpClient]) {
  if (httpClient != null) {
    throw ArgumentError.value(
      httpClient,
      'httpClient',
      'Custom HttpClient instances are not supported on Flutter Web.',
    );
  }
  return WebApiTransport();
}

class WebApiTransport implements ApiTransport {
  @override
  Future<ApiResponse> send(
    String method,
    Uri uri, {
    required Map<String, String> headers,
    String? body,
  }) async {
    final requestHeaders = web.Headers();
    headers.forEach((name, value) {
      requestHeaders.append(name, value);
    });

    final response = await web.window
        .fetch(
          uri.toString().toJS,
          web.RequestInit(
            method: method,
            headers: requestHeaders,
            body: body?.toJS,
          ),
        )
        .toDart;
    final responseText = (await response.text().toDart).toDart;

    return ApiResponse(statusCode: response.status, body: responseText);
  }
}
