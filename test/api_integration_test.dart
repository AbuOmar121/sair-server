import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  Process? process;
  const baseUrl = 'http://127.0.0.1:8091';

  setUpAll(() async {
    final dbFile = File('data/db.json');
    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    process = await Process.start(
      'dart',
      ['run', 'dart_frog_cli:dart_frog', 'dev', '-p', '8091', '-d', '0'],
      workingDirectory: Directory.current.path,
    );
    var ready = false;
    for (var i = 0; i < 30; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      try {
        final res = await http.get(Uri.parse('$baseUrl/'));
        if (res.statusCode == 200) {
          ready = true;
          break;
        }
      } catch (_) {}
    }
    if (!ready) {
      throw StateError('Server did not start on $baseUrl');
    }
  });

  tearDownAll(() async {
    process?.kill(ProcessSignal.sigterm);
  });

  test('health endpoint', () async {
    final res = await http.get(Uri.parse('$baseUrl/'));
    expect(res.statusCode, 200);
  });

  test('register/login/me/logout flow', () async {
    final register = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'fullName': 'Test User',
        'email': 'testuser@sair.local',
        'phone': '0792222222',
        'nationalId': 'NID-TEST-01',
        'password': 'Pass@123',
      }),
    );
    expect(register.statusCode, 201);

    final login = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'email': 'testuser@sair.local',
        'password': 'Pass@123',
      }),
    );
    expect(login.statusCode, 200);
    final token =
        (jsonDecode(login.body) as Map<String, dynamic>)['token'] as String;
    expect(token, isNotEmpty);

    final me = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {'authorization': 'Bearer $token'},
    );
    expect(me.statusCode, 200);

    final logout = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: {'authorization': 'Bearer $token'},
    );
    expect(logout.statusCode, 200);
  });

  test('reports endpoints including filters and details', () async {
    final login = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'email': 'citizen@sair.local',
        'password': 'Pass@123',
      }),
    );
    final token =
        (jsonDecode(login.body) as Map<String, dynamic>)['token'] as String;

    final create = await http.post(
      Uri.parse('$baseUrl/reports'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'lat': 31.95,
        'lng': 35.91,
        'description': 'Integration test incident',
        'accidentType': 'collision',
        'locationSource': 'gps',
      }),
    );
    expect(create.statusCode, 201);
    final reportId =
        (jsonDecode(create.body) as Map<String, dynamic>)['id'] as String;

    final myReports = await http.get(
      Uri.parse('$baseUrl/reports/my?status=submitted'),
      headers: {'authorization': 'Bearer $token'},
    );
    expect(myReports.statusCode, 200);

    final details = await http.get(
      Uri.parse('$baseUrl/reports/$reportId'),
      headers: {'authorization': 'Bearer $token'},
    );
    expect(details.statusCode, 200);

    final media = await http.post(
      Uri.parse('$baseUrl/reports/$reportId/media'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $token',
      },
      body: jsonEncode({'mediaUrl': 'https://cdn.local/example.jpg'}),
    );
    expect(media.statusCode, 200);
  });

  test('status update + notifications + admin users', () async {
    final citizenLogin = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'email': 'citizen@sair.local',
        'password': 'Pass@123',
      }),
    );
    final citizenToken = (jsonDecode(citizenLogin.body)
        as Map<String, dynamic>)['token'] as String;

    final create = await http.post(
      Uri.parse('$baseUrl/reports'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $citizenToken',
      },
      body: jsonEncode({
        'lat': 31.95,
        'lng': 35.91,
        'description': 'Another incident',
        'accidentType': 'collision',
      }),
    );
    final reportId =
        (jsonDecode(create.body) as Map<String, dynamic>)['id'] as String;

    final officerLogin = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'email': 'officer@sair.local',
        'password': 'Pass@123',
      }),
    );
    final officerToken = (jsonDecode(officerLogin.body)
        as Map<String, dynamic>)['token'] as String;

    final patch = await http.patch(
      Uri.parse('$baseUrl/reports/$reportId/status'),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $officerToken',
      },
      body: jsonEncode({'status': 'under_review'}),
    );
    expect(patch.statusCode, 200);

    final notifications = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: {'authorization': 'Bearer $citizenToken'},
    );
    expect(notifications.statusCode, 200);

    final adminLogin = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'email': 'admin@sair.local',
        'password': 'Pass@123',
      }),
    );
    final adminToken = (jsonDecode(adminLogin.body)
        as Map<String, dynamic>)['token'] as String;

    final users = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: {'authorization': 'Bearer $adminToken'},
    );
    expect(users.statusCode, 200);
  });

  test('openapi and docs endpoints', () async {
    final spec = await http.get(Uri.parse('$baseUrl/openapi'));
    expect(spec.statusCode, 200);
    expect(spec.body, contains('openapi: 3.0.3'));

    final docs = await http.get(Uri.parse('$baseUrl/docs'));
    expect(docs.statusCode, 200);
    expect(docs.body, contains('SwaggerUIBundle'));
  });
}
