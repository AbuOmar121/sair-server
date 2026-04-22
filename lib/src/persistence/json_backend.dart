import 'package:sair_apis/src/persistence/json_db.dart';
import 'package:sair_apis/src/persistence/storage_backend.dart';

class JsonBackend implements StorageBackend {
  @override
  Future<void> init() async {
    await JsonDb.instance.read();
  }

  @override
  Future<Map<String, dynamic>?> get(String collection, String id) async {
    final db = await JsonDb.instance.read();
    final items = (db[collection] as List<dynamic>?) ?? <dynamic>[];
    for (final item in items) {
      final map = Map<String, dynamic>.from(item as Map);
      if (map['id'] == id) return map;
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> list(String collection) async {
    final db = await JsonDb.instance.read();
    final items = (db[collection] as List<dynamic>?) ?? <dynamic>[];
    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  @override
  Future<void> put(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    final db = await JsonDb.instance.read();
    final items = (db[collection] as List<dynamic>?) ?? <dynamic>[];
    final list = items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    final index = list.indexWhere((m) => m['id'] == id);
    final stored = <String, dynamic>{...data, 'id': id};
    if (index == -1) {
      list.add(stored);
    } else {
      list[index] = stored;
    }
    db[collection] = list;
    await JsonDb.instance.write(db);
  }

  @override
  Future<void> delete(String collection, String id) async {
    final db = await JsonDb.instance.read();
    final items = (db[collection] as List<dynamic>?) ?? <dynamic>[];
    final list = items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    list.removeWhere((m) => m['id'] == id);
    db[collection] = list;
    await JsonDb.instance.write(db);
  }
}
