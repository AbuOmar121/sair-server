import 'package:dart_frog/dart_frog.dart';
import 'package:image/image.dart' as img;

void diagnostic(RequestContext context) async {
  final formData = await context.request.formData();
  for (final file in formData.files.values) {
    // This will error at compile time if we get it wrong, 
    // but at least we can try several.
    try {
       print(file.name);
       // print(file.bytes);
       // print(file.contents);
    } catch (e) {}
  }
  
  final i = img.decodeImage([]);
  // print(img.encodeWebP(i!));
}
