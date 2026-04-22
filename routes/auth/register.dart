import 'package:dart_frog/dart_frog.dart';
import 'package:sair_apis/src/features/auth/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  final body = await context.request.json() as Map<String, dynamic>;
  final fullName = body['fullName'];
  final email = body['email'];
  final phone = body['phone'];
  final nationalId = body['nationalId'];
  final password = body['password'];
  final role = (body['role'] as String?) ?? 'citizen';
  if (fullName is! String ||
      email is! String ||
      phone is! String ||
      nationalId is! String ||
      password is! String) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'VALIDATION_ERROR',
        'message': 'Missing required registration fields.',
      },
    );
  }
  try {
    final user = await AuthService.register(
      fullName: fullName,
      email: email,
      phone: phone,
      nationalId: nationalId,
      password: password,
      role: role,
    );
    return Response.json(statusCode: 201, body: user.toJson());
  } on Exception catch (e) {
    if (!e.toString().contains('EMAIL_ALREADY_EXISTS')) rethrow;
    return Response.json(
      statusCode: 409,
      body: {
        'error': 'EMAIL_ALREADY_EXISTS',
        'message': 'Email already registered.',
      },
    );
  }
}
