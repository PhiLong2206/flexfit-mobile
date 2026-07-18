class AuthSession {
  const AuthSession({
    required this.token,
    required this.expiresAt,
    required this.roles,
  });

  final String token;
  final DateTime expiresAt;
  final List<String> roles;
}
