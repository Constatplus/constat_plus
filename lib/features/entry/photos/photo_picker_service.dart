import 'package:image_picker/image_picker.dart';

import '../models/photo_item.dart';

class PhotoPickerService {
  PhotoPickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<List<PhotoItem>> pickFromGallery() async {
    final files = await _picker.pickMultiImage(
      imageQuality: 88,
      requestFullMetadata: false,
    );

    return Future.wait(
      files.map((file) async {
        final bytes = await file.readAsBytes();
        return PhotoItem(
          id: '${DateTime.now().microsecondsSinceEpoch}-${file.name}',
          name: file.name,
          bytes: bytes,
          createdAt: DateTime.now(),
        );
      }),
    );
  }

  Future<PhotoItem?> takePhoto() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 88,
      requestFullMetadata: false,
    );

    if (file == null) {
      return null;
    }

    return PhotoItem(
      id: '${DateTime.now().microsecondsSinceEpoch}-${file.name}',
      name: file.name,
      bytes: await file.readAsBytes(),
      createdAt: DateTime.now(),
    );
  }
}
