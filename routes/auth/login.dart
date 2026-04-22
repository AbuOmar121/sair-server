import 'package:dart_frog/dart_frog.dart';
import 'package:sair_apis/src/features/auth/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  final body = await context.request.json() as Map<String, dynamic>;
  final email = body['email'];
  final password = body['password'];
  if (email is! String || password is! String) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'VALIDATION_ERROR',
        'message': 'email and password are required.',
      },
    );
  }
  try {
    final token = await AuthService.login(email: email, password: password);
    final user = await AuthService.getUserByToken(token);
    return Response.json(
      body: {
        'token': token,
        'user': user?.toJson(),
      },
    );
  } on Exception catch (e) {
    if (!e.toString().contains('INVALID_CREDENTIALS')) rethrow;
    return Response.json(
      statusCode: 401,
      body: {
        'error': 'INVALID_CREDENTIALS',
        'message': 'Invalid email or password.',
      },
    );
  }
}
