import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  final file = File('openapi.yaml');
  if (!await file.exists()) {
    return Response.json(
      statusCode: 404,
      body: {'error': 'NOT_FOUND', 'message': 'openapi.yaml is missing.'},
    );
  }
  return Response(
    body: await file.readAsString(),
    headers: {'content-type': 'application/yaml; charset=utf-8'},
  );
}
