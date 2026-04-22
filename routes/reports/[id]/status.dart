import 'package:dart_frog/dart_frog.dart';
import 'package:sair_apis/src/domain/constants/report_status.dart';
import 'package:sair_apis/src/features/notifications/notification_service.dart';
import 'package:sair_apis/src/features/reports/report_repository_impl.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.patch) {
    return Response(statusCode: 405);
  }
  final user = context.read<Map<String, dynamic>>();
  final role = user['role'] as String;
  if (role != 'officer' && role != 'admin') {
    return Response.json(
      statusCode: 403,
      body: {
        'error': 'FORBIDDEN',
        'message': 'Only officers/admins can update status.',
      },
    );
  }
  final body = await context.request.json() as Map<String, dynamic>;
  final status = body['status'];
  if (status is! String || !reportStatuses.contains(status)) {
    return Response.json(
      statusCode: 400,
      body: {'error': 'VALIDATION_ERROR', 'message': 'Invalid status value.'},
    );
  }
  final repo = ReportRepositoryImpl();
  final updated = await repo.updateStatus(id, status);
  if (updated == null) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'NOT_FOUND', 'message': 'Report not found.'},
    );
  }
  await NotificationService.create(
    userId: updated.citizenId,
    title: 'Report Status Updated',
    message: 'Your report ${updated.id} is now ${updated.status}.',
    reportId: updated.id,
  );
  return Response.json(body: updated.toJson());
}
