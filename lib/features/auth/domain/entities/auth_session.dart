class AuthSession {
  const AuthSession({required this.token, required this.expiresAt});

  final String token;
  final DateTime expiresAt;
}
