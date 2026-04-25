import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

class ImageService {
  static const String uploadDir = 'public/uploads/photos';

  Future<String> saveImage(List<int> bytes) async {
    // 1. Ensure directory exists
    final directory = Directory(uploadDir);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // 2. Generate unique name
    final fileName = '${const Uuid().v4()}.png';
    final filePath = p.join(uploadDir, fileName);

    // 3. Decode and convert to WebP
    final decoded = img.decodeImage(Uint8List.fromList(bytes));
    if (decoded == null) {
      throw Exception('Failed to decode image.');
    }

    // 4. Encode to PNG
    final webpBytes = img.encodePng(decoded);

    // 5. Save to disk
    await File(filePath).writeAsBytes(webpBytes);

    // Return the relative URL path
    return '/uploads/photos/$fileName';
  }
}
