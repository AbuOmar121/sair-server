import 'dart:math';

import 'package:sair_apis/src/domain/entities/app_user.dart';
import 'package:sair_apis/src/persistence/app_backend.dart';
import 'package:sair_apis/src/security/jwt_service.dart';

class AuthService {
  static bool _seeded = false;

  static Future<void> seedIfNeeded() async {
    if (_seeded) return;
    final backend = await AppBackend.instance();
    final users =
        (await backend.list('users')).map((e) => AppUser.fromJson(e)).toList();
    _seeded = true;
    final existingEmails = users.map((u) => u.email).toSet();
    if (!existingEmails.contains('citizen@sair.local')) {
      await register(
        fullName: 'Demo Citizen',
        email: 'citizen@sair.local',
        phone: '0700000001',
        nationalId: 'NID-CITIZEN-1',
        password: 'Pass@123',
        role: 'citizen',
      );
    }
    if (!existingEmails.contains('officer@sair.local')) {
      await register(
        fullName: 'Demo Officer',
        email: 'officer@sair.local',
        phone: '0700000002',
        nationalId: 'NID-OFFICER-1',
        password: 'Pass@123',
        role: 'officer',
      );
    }
    if (!existingEmails.contains('admin@sair.local')) {
      await register(
        fullName: 'Demo Admin',
        email: 'admin@sair.local',
        phone: '0700000003',
        nationalId: 'NID-ADMIN-1',
        password: 'Pass@123',
        role: 'admin',
      );
    }
  }

  static Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String nationalId,
    required String password,
    required String role,
  }) async {
    final backend = await AppBackend.instance();
    final users =
        (await backend.list('users')).map((e) => AppUser.fromJson(e)).toList();
    final normalized = email.trim().toLowerCase();
    if (users.any((u) => u.email == normalized)) {
      throw Exception('EMAIL_ALREADY_EXISTS');
    }
    final user = AppUser(
      id: _id(),
      fullName: fullName,
      email: normalized,
      phone: phone,
      nationalId: nationalId,
      password: password,
      role: role,
      createdAt: DateTime.now(),
    );
    await backend.put('users', user.id, user.toStorageJson());
    return user;
  }

  static Future<String> login({
    required String email,
    required String password,
  }) async {
    final backend = await AppBackend.instance();
    final users =
        (await backend.list('users')).map((e) => AppUser.fromJson(e)).toList();
    final normalized = email.trim().toLowerCase();
    AppUser? user;
    for (final item in users) {
      if (item.email == normalized) {
        user = item;
        break;
      }
    }
    if (user == null || user.password != password) {
      throw Exception('INVALID_CREDENTIALS');
    }
    return JwtService.issueToken(
      userId: user.id,
      role: user.role,
      email: user.email,
    );
  }

  static Future<void> logout(String token) async {
    final backend = await AppBackend.instance();
    await backend.put(
      'revokedTokens',
      token,
      {'id': token, 'revokedAt': DateTime.now().toIso8601String()},
    );
  }

  static Future<AppUser?> getUserByToken(String token) async {
    final backend = await AppBackend.instance();
    final revoked = await backend.get('revokedTokens', token);
    if (revoked != null) return null;
    final payload = JwtService.verify(token);
    if (payload == null) return null;
    final users =
        (await backend.list('users')).map((e) => AppUser.fromJson(e)).toList();
    for (final user in users) {
      if (user.id == payload['sub']) return user;
    }
    return null;
  }

  static Future<List<AppUser>> allUsers() async {
    final backend = await AppBackend.instance();
    return (await backend.list('users')).map(AppUser.fromJson).toList();
  }

  static String _id() =>
      '${DateTime.now().microsecondsSinceEpoch}${Random().nextInt(99999)}';
}
