import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_session.dart';

class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required super.token,
    required super.expiresAt,
    required super.roles,
  });

  factory AuthSessionModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] ?? json['Token'];
    final expiresAt = json['expiresAt'] ?? json['ExpiresAt'];
    final rolesJson = json['roles'] ?? json['Roles'];
    final roles = rolesJson is Iterable
        ? rolesJson.map((role) => role.toString()).toList(growable: false)
        : rolesJson == null
        ? <String>[]
        : <String>[rolesJson.toString()];
    debugPrint('Auth response roles: $roles');

    return AuthSessionModel(
      token: token?.toString() ?? '',
      expiresAt:
          DateTime.tryParse(expiresAt?.toString() ?? '') ?? DateTime.now(),
      roles: roles,
    );
  }
}
