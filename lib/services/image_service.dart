// lib/services/firebase_image_service.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class FirebaseImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  // Pick single image
  Future<XFile?> pickSingleImage() async {
    try {
      return await _picker.pickImage(source: ImageSource.gallery);
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Pick multiple images
  Future<List<XFile>?> pickMultipleImages() async {
    try {
      final images = await _picker.pickMultiImage();
      return images.isNotEmpty ? images : null;
    } catch (e) {
      print('Error picking images: $e');
      return null;
    }
  }

  // Upload single image to Firebase Storage
  Future<String?> uploadSingleImage(XFile image) async {
    try {
      // Generate unique filename
      final String fileName =
          '${_uuid.v4()}_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';

      // Create reference to Firebase Storage
      final Reference ref = _storage.ref().child('item_images/$fileName');

      // Upload file
      final UploadTask uploadTask = ref.putFile(File(image.path));

      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;

      // Get download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading imagessss: $e');
      return null;
    }
  }

  // Upload multiple images to Firebase Storage
  Future<List<String>> uploadMultipleImages(List<XFile> images) async {
    List<String> uploadedUrls = [];

    for (XFile image in images) {
      try {
        final String? url = await uploadSingleImage(image);
        if (url != null) {
          uploadedUrls.add(url);
        }
      } catch (e) {
        print('Error uploading image ${image.path}: $e');
        // Continue with other images even if one fails
      }
    }
    return uploadedUrls;
  }

  // Delete image from Firebase Storage
  Future<bool> deleteImageByUrl(String imageUrl) async {
    try {
      // Extract the file path from the URL
      final Uri uri = Uri.parse(imageUrl);
      final String filePath = uri.pathSegments.last;

      // Create reference and delete
      final Reference ref = _storage.ref().child('item_images/$filePath');
      await ref.delete();

      return true;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  // Delete multiple images
  Future<List<bool>> deleteMultipleImages(List<String> imageUrls) async {
    List<bool> results = [];

    for (String url in imageUrls) {
      final bool result = await deleteImageByUrl(url);
      results.add(result);
    }

    return results;
  }
}
