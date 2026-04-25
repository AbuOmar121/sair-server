import 'package:dart_frog/dart_frog.dart';
import 'package:sair_apis/src/application/usecases/create_report.dart';
import 'package:sair_apis/src/domain/constants/report_status.dart';
import 'package:sair_apis/src/features/reports/report_repository_impl.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }

  final contentType = context.request.headers['content-type'] ?? '';
  Map<String, dynamic> body = {};
  List<List<int>> mediaData = [];

  if (contentType.contains('multipart/form-data')) {
    final formData = await context.request.formData();
    body = Map.from(formData.fields);
    
    // Convert string numbers to doubles if present
    if (body['lat'] != null) body['lat'] = double.tryParse(body['lat'] as String);
    if (body['lng'] != null) body['lng'] = double.tryParse(body['lng'] as String);

    // Extract files
    for (final file in formData.files.values) {
      final dynamic f = file;
      
      // Multi-property fallback without prints
      List<int>? data;
      try { data ??= f.bytes; } catch (_) {}
      try { data ??= f.contents; } catch (_) {}
      try { data ??= f.buffer; } catch (_) {}
      try { data ??= f.data; } catch (_) {}
      
      if (data != null) {
        mediaData.add(data);
      }
    }
  } else {
    body = await context.request.json() as Map<String, dynamic>;
  }

  final user = context.read<Map<String, dynamic>>();
  final lat = body['lat'];
  final lng = body['lng'];
  final description = body['description'];
  final accidentType = body['accidentType'];
  final platesNumberRaw = body['platesNumber'];

  if (lat is! num ||
      lng is! num ||
      description is! String ||
      accidentType is! String ||
      platesNumberRaw == null) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'VALIDATION_ERROR',
        'message':
            'lat, lng, description, accidentType, and platesNumber are required.',
      },
    );
  }

  final List<String> platesNumber = platesNumberRaw is List
      ? platesNumberRaw.cast<String>()
      : [platesNumberRaw.toString()];
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

  try {
    final report = await usecase.execute(
      citizenId: user['uid'] as String,
      lat: lat.toDouble(),
      lng: lng.toDouble(),
      description: description,
      accidentType: accidentType,
      occurredAt: occurredAt,
      locationSource: locationSource,
      platesNumber: platesNumber,
      mediaData: mediaData.isNotEmpty ? mediaData : null,
    );

    if (!reportStatuses.contains(report.status)) {
      return Response.json(
        statusCode: 500,
        body: {
          'error': 'INTERNAL_ERROR',
          'message': 'Invalid status generated.'
        },
      );
    }
    return Response.json(statusCode: 201, body: report.toJson());
  } catch (e, stack) {
    return Response.json(
      statusCode: 500,
      body: {
        'error': 'INTERNAL_ERROR',
        'message': e.toString(),
        'stackTrace': stack.toString(),
      },
    );
  }
}
