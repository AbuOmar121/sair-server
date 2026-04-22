import 'dart:convert';
import 'dart:io';

class JsonDb {
  JsonDb._();
  static final JsonDb instance = JsonDb._();
  final File _file = File('data/db.json');

  Future<Map<String, dynamic>> read() async {
    if (!await _file.exists()) {
      await _file.parent.create(recursive: true);
      await _file.writeAsString(
        jsonEncode({
          'users': <Map<String, dynamic>>[],
          'reports': <Map<String, dynamic>>[],
          'notifications': <Map<String, dynamic>>[],
          'revokedTokens': <String>[],
        }),
      );
    }
    final raw = await _file.readAsString();
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    decoded.putIfAbsent('users', () => <Map<String, dynamic>>[]);
    decoded.putIfAbsent('reports', () => <Map<String, dynamic>>[]);
    decoded.putIfAbsent('notifications', () => <Map<String, dynamic>>[]);
    decoded.putIfAbsent('revokedTokens', () => <String>[]);
    return decoded;
  }

  Future<void> write(Map<String, dynamic> data) async {
    await _file.parent.create(recursive: true);
    await _file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );
  }
}
