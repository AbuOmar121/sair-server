import 'dart:io';

import 'package:sair_apis/src/persistence/firestore_backend.dart';
import 'package:sair_apis/src/persistence/json_backend.dart';
import 'package:sair_apis/src/persistence/storage_backend.dart';

class AppBackend {
  AppBackend._();

  static StorageBackend? _instance;

  static Future<StorageBackend> instance() async {
    if (_instance != null) return _instance!;
    final projectId = Platform.environment['FIRESTORE_PROJECT_ID'];
    final credPath = Platform.environment['FIRESTORE_CREDENTIAL_PATH'];
    if (projectId != null &&
        projectId.isNotEmpty &&
        credPath != null &&
        credPath.isNotEmpty) {
      final fb =
          FirestoreBackend(projectId: projectId, credentialPath: credPath);
      await fb.init();
      _instance = fb;
      return fb;
    }
    final json = JsonBackend();
    await json.init();
    _instance = json;
    return json;
  }
}
