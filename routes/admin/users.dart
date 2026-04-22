import 'package:dart_frog/dart_frog.dart';
import 'package:sair_apis/src/features/auth/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  final user = context.read<Map<String, dynamic>>();
  if (user['role'] != 'admin') {
    return Response.json(
      statusCode: 403,
      body: {'error': 'FORBIDDEN', 'message': 'Admin role required.'},
    );
  }
  return Response.json(
    body: (await AuthService.allUsers()).map((u) => u.toJson()).toList(),
  );
}
