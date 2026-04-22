import 'package:dart_frog/dart_frog.dart';
import 'package:sair_apis/src/features/auth/auth_service.dart';

Handler middleware(Handler handler) {
  return (context) async {
    await AuthService.seedIfNeeded();
    final authHeader = context.request.headers['authorization'];
    String? token;
    if (authHeader != null && authHeader.startsWith('Bearer ')) {
      token = authHeader.substring('Bearer '.length).trim();
    }
    token ??= context.request.headers['x-auth-token'];
    if (token != null) {
      final user = await AuthService.getUserByToken(token);
      if (user != null) {
        return handler(
          context.provide(
            () => <String, dynamic>{
              'uid': user.id,
              'role': user.role,
              'email': user.email,
              'token': token,
            },
          ),
        );
      }
    }
    return handler(
      context.provide(
        () => <String, dynamic>{
          'uid': 'guest-citizen',
          'role': 'citizen',
          'email': 'guest@sair.local',
        },
      ),
    );
  };
}
