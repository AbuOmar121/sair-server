import 'package:dart_frog/dart_frog.dart';
import 'package:sair_apis/src/features/notifications/notification_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  final user = context.read<Map<String, dynamic>>();
  final items = await NotificationService.byUser(user['uid'] as String);
  return Response.json(body: items.map((n) => n.toJson()).toList());
}
