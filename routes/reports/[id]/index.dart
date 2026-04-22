import 'package:dart_frog/dart_frog.dart';

import 'package:sair_apis/src/features/reports/report_repository_impl.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final repo = ReportRepositoryImpl();
  final report = await repo.getReportById(id);
  final user = context.read<Map<String, dynamic>>();

  if (report == null) {
    return Response(statusCode: 404, body: 'Report not found');
  }
  final role = user['role'] as String;
  if (role == 'citizen' && report.citizenId != user['uid']) {
    return Response.json(
      statusCode: 403,
      body: {
        'error': 'FORBIDDEN',
        'message': 'You can only view your own reports.',
      },
    );
  }

  return Response.json(body: report.toJson());
}
