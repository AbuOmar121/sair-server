import 'package:dart_frog/dart_frog.dart';
import 'package:sair_apis/src/features/reports/report_repository_impl.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: 405);
  }
  final body = await context.request.json() as Map<String, dynamic>;
  final mediaUrl = body['mediaUrl'];
  final mediaUrlsRaw = body['mediaUrls'];
  final mediaUrls = <String>[];
  if (mediaUrl is String && mediaUrl.isNotEmpty) {
    mediaUrls.add(mediaUrl);
  }
  if (mediaUrlsRaw is List) {
    for (final item in mediaUrlsRaw) {
      if (item is String && item.isNotEmpty) {
        mediaUrls.add(item);
      }
    }
  }
  if (mediaUrls.isEmpty) {
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'VALIDATION_ERROR',
        'message': 'mediaUrl or mediaUrls is required.',
      },
    );
  }
  final updated = await ReportRepositoryImpl().appendMedia(id, mediaUrls);
  if (updated == null) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'NOT_FOUND', 'message': 'Report not found.'},
    );
  }
  return Response.json(body: updated.toJson());
}
