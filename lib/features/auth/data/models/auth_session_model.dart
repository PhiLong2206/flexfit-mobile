import '../../domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({required super.token, required super.expiresAt});

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] ?? json['Token'];
    final expiresAt = json['expiresAt'] ?? json['ExpiresAt'];

    return AuthSessionModel(
      token: token?.toString() ?? '',
      expiresAt:
          DateTime.tryParse(expiresAt?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
