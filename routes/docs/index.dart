import 'package:dart_frog/dart_frog.dart';

Response onRequest(RequestContext context) {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: 405);
  }
  const html = '''
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>SAIR API Docs</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
  </head>
  <body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <script>
      window.ui = SwaggerUIBundle({
        url: '/openapi',
        dom_id: '#swagger-ui'
      });
    </script>
  </body>
</html>
''';
  return Response(
    body: html,
    headers: {'content-type': 'text/html; charset=utf-8'},
  );
}
