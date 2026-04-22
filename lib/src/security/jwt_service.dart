import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtService {
  JwtService._();

  static String get _secret =>
      Platform.environment['JWT_SECRET'] ?? 'sair-dev-secret-change-me';

  static String issueToken({
    required String userId,
    required String role,
    required String email,
  }) {
    final jwt = JWT({
      'sub': userId,
      'role': role,
      'email': email,
    });
    return jwt.sign(
      SecretKey(_secret),
      expiresIn: const Duration(hours: 12),
    );
  }

  static Map<String, dynamic>? verify(String token) {
    try {
      final verified = JWT.verify(token, SecretKey(_secret));
      return Map<String, dynamic>.from(verified.payload as Map);
    } catch (_) {
      return null;
    }
  }
}
