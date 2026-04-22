import 'package:dart_frog/dart_frog.dart';
import 'package:sair_apis/src/features/reports/report_repository_impl.dart';

Future<Response> onRequest(RequestContext context) async {
  final user = context.read<Map<String, dynamic>>();
  final status = context.request.uri.queryParameters['status'];
  final fromRaw = context.request.uri.queryParameters['from'];
  final toRaw = context.request.uri.queryParameters['to'];
  final from = fromRaw == null ? null : DateTime.tryParse(fromRaw);
  final to = toRaw == null ? null : DateTime.tryParse(toRaw);
  if ((fromRaw != null && from == null) || (toRaw != null && to == null)) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'VALIDATION_ERROR',
        'message': 'from/to must be ISO-8601 date-time.',
      },
    );
  }
  final reports = await ReportRepositoryImpl().getReportsByCitizen(
    user['uid'] as String,
    status: status,
    from: from,
    to: to,
  );
  return Response.json(body: reports.map((r) => r.toJson()).toList());
}
