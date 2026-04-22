import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  return Response.json(
    body: {
      'service': 'SAIR Accident Reporting API',
      'version': '1.0.0',
      'status': 'healthy',
      'timestamp': DateTime.now().toIso8601String(),
    },
  );
}
