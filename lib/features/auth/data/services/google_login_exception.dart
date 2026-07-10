class GoogleLoginException implements Exception {
  const GoogleLoginException(this.message);

  final String message;

  @override
  String toString() => message;
}
