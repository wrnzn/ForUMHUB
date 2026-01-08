import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class FileService {
  final ImagePicker _picker = ImagePicker();
  
  // Cloudinary credentials
  final String _cloudName = "dnlkircmj"; 
  final String _uploadPreset = "ml_default"; 

  // 1. Pick an image from gallery
  Future<File?> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
      );
      if (image != null) return File(image.path);
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // 2. Upload to Cloudinary (Free, Fast, and Reliable)
  Future<String?> uploadImage(File file) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Cloudinary returns 'secure_url' for HTTPS links
        return jsonResponse['secure_url'];
      } else {
        debugPrint('Cloudinary Error: ${jsonResponse['error']?['message'] ?? 'Unknown error'}');
        return null;
      }
    } catch (e) {
      debugPrint('Upload failed: $e');
      return null;
    }
  }

  // Helper method for profile pictures
  Future<String?> uploadProfilePicture(String userId, File file) async {
    return await uploadImage(file);
  }
}
