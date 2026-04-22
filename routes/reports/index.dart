import 'package:dart_frog/dart_frog.dart';
import 'package:sair_apis/src/application/usecases/create_report.dart';
import 'package:sair_apis/src/domain/constants/report_status.dart';
import 'package:sair_apis/src/features/reports/report_repository_impl.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final body = await context.request.json() as Map<String, dynamic>;
  final user = context.read<Map<String, dynamic>>();
  final lat = body['lat'];
  final lng = body['lng'];
  final description = body['description'];
  final accidentType = body['accidentType'];
  if (lat is! num ||
      lng is! num ||
      description is! String ||
      accidentType is! String) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'VALIDATION_ERROR',
        'message': 'lat, lng, description, and accidentType are required.',
      },
    );
  }
  final locationSource = (body['locationSource'] as String?) ?? 'gps';
  if (locationSource != 'gps' && locationSource != 'manual') {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'VALIDATION_ERROR',
        'message': 'locationSource must be gps or manual.',
      },
    );
  }
  final occurredAtRaw = body['occurredAt'] as String?;
  final occurredAt =
      occurredAtRaw == null ? DateTime.now() : DateTime.tryParse(occurredAtRaw);
  if (occurredAt == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'VALIDATION_ERROR',
        'message': 'occurredAt must be ISO-8601 date-time.',
      },
    );
  }

  final usecase = CreateReportUseCase(
    ReportRepositoryImpl(),
  );

  final report = await usecase.execute(
    citizenId: user['uid'] as String,
    lat: lat.toDouble(),
    lng: lng.toDouble(),
    description: description,
    accidentType: accidentType,
    occurredAt: occurredAt,
    locationSource: locationSource,
  );
  if (!reportStatuses.contains(report.status)) {
    return Response.json(
      statusCode: 500,
      body: {'error': 'INTERNAL_ERROR', 'message': 'Invalid status generated.'},
    );
  }
  return Response.json(statusCode: 201, body: report.toJson());
}
