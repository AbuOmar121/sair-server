import 'dart:convert';
import 'dart:io';

import 'package:googleapis/firestore/v1.dart' as fs;
import 'package:googleapis_auth/auth_io.dart';
import 'package:sair_apis/src/persistence/storage_backend.dart';

class FirestoreBackend implements StorageBackend {
  FirestoreBackend({
    required this.projectId,
    required this.credentialPath,
  });

  final String projectId;
  final String credentialPath;

  late final fs.FirestoreApi _api;
  late final String _databasePath;

  @override
  Future<void> init() async {
    final file = File(credentialPath);
    if (!await file.exists()) {
      throw StateError('Firestore credentials not found: $credentialPath');
    }
    final raw = await file.readAsString();
    final serviceAccount = ServiceAccountCredentials.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    final client = await clientViaServiceAccount(
      serviceAccount,
      [fs.FirestoreApi.datastoreScope],
    );
    _api = fs.FirestoreApi(client);
    _databasePath = 'projects/$projectId/databases/(default)/documents';
  }

  String _docName(String collection, String id) =>
      '$_databasePath/$collection/$id';

  @override
  Future<Map<String, dynamic>?> get(String collection, String id) async {
    try {
      final doc = await _api.projects.databases.documents.get(
        _docName(collection, id),
      );
      return _fromDoc(doc, id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> list(String collection) async {
    final parent = _databasePath;
    final res = await _api.projects.databases.documents.list(
      parent,
      collection,
    );
    final docs = res.documents ?? const <fs.Document>[];
    return docs.map((d) {
      final id = d.name?.split('/').last ?? '';
      return _fromDoc(d, id);
    }).toList();
  }

  @override
  Future<void> put(
      String collection, String id, Map<String, dynamic> data) async {
    final doc =
        fs.Document(fields: _toFields(<String, dynamic>{...data, 'id': id}));
    await _api.projects.databases.documents.patch(
      doc,
      _docName(collection, id),
    );
  }

  @override
  Future<void> delete(String collection, String id) async {
    await _api.projects.databases.documents.delete(_docName(collection, id));
  }

  Map<String, dynamic> _fromDoc(fs.Document doc, String id) {
    final fields = doc.fields ?? <String, fs.Value>{};
    final map = <String, dynamic>{};
    for (final entry in fields.entries) {
      map[entry.key] = _fromValue(entry.value);
    }
    map['id'] = map['id'] ?? id;
    return map;
  }

  Map<String, fs.Value> _toFields(Map<String, dynamic> map) {
    final fields = <String, fs.Value>{};
    for (final entry in map.entries) {
      fields[entry.key] = _toValue(entry.value);
    }
    return fields;
  }

  fs.Value _toValue(dynamic v) {
    if (v == null) return fs.Value(nullValue: 'NULL_VALUE');
    if (v is bool) return fs.Value(booleanValue: v);
    if (v is int) return fs.Value(integerValue: v.toString());
    if (v is double) return fs.Value(doubleValue: v);
    if (v is num) return fs.Value(doubleValue: v.toDouble());
    if (v is String) return fs.Value(stringValue: v);
    if (v is DateTime) return fs.Value(stringValue: v.toIso8601String());
    if (v is List) {
      return fs.Value(
        arrayValue: fs.ArrayValue(
          values: v.map(_toValue).toList(),
        ),
      );
    }
    if (v is Map) {
      final fields = <String, fs.Value>{};
      v.forEach((key, value) {
        fields[key.toString()] = _toValue(value);
      });
      return fs.Value(mapValue: fs.MapValue(fields: fields));
    }
    return fs.Value(stringValue: v.toString());
  }

  dynamic _fromValue(fs.Value value) {
    if (value.nullValue != null) return null;
    if (value.booleanValue != null) return value.booleanValue;
    if (value.integerValue != null) return int.tryParse(value.integerValue!);
    if (value.doubleValue != null) return value.doubleValue;
    if (value.stringValue != null) return value.stringValue;
    if (value.arrayValue != null) {
      final vals = value.arrayValue!.values ?? const <fs.Value>[];
      return vals.map(_fromValue).toList();
    }
    if (value.mapValue != null) {
      final fields = value.mapValue!.fields ?? <String, fs.Value>{};
      final out = <String, dynamic>{};
      for (final entry in fields.entries) {
        out[entry.key] = _fromValue(entry.value);
      }
      return out;
    }
    return null;
  }
}
