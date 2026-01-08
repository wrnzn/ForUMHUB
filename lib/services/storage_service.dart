import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery or camera
  Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile, String path) async {
    try {
      final ref = _storage.ref().child(path);
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // Upload multiple images
  Future<List<String>> uploadImages(List<File> imageFiles, String basePath) async {
    final List<String> urls = [];
    for (int i = 0; i < imageFiles.length; i++) {
      final url = await uploadImage(imageFiles[i], '$basePath/image_$i.jpg');
      if (url != null) {
        urls.add(url);
      }
    }
    return urls;
  }

  // Delete image from Firebase Storage
  Future<void> deleteImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      // Ignore errors
    }
  }
}
