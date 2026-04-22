abstract class StorageBackend {
  Future<void> init();

  Future<List<Map<String, dynamic>>> list(String collection);

  Future<Map<String, dynamic>?> get(String collection, String id);

  Future<void> put(String collection, String id, Map<String, dynamic> data);

  Future<void> delete(String collection, String id);
}
