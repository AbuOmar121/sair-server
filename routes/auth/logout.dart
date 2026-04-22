import 'package:dart_frog/dart_frog.dart';
import 'package:sair_apis/src/features/auth/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  final authHeader = context.request.headers['authorization'];
  String? token;
  if (authHeader != null && authHeader.startsWith('Bearer ')) {
    token = authHeader.substring('Bearer '.length).trim();
  }
  token ??= context.request.headers['x-auth-token'];
  if (token == null || token.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'VALIDATION_ERROR',
        'message': 'x-auth-token header is required.',
      },
    );
  }
  await AuthService.logout(token);
  return Response.json(body: {'message': 'Logged out successfully.'});
}
