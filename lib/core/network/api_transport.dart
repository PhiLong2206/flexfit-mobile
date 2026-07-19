class ApiResponse {
  const ApiResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

abstract interface class ApiTransport {
  Future<ApiResponse> send(
    String method,
    Uri uri, {
    required Map<String, String> headers,
    String? body,
  });
}
