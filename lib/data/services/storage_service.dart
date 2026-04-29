import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

class StorageService {
  final ImagePicker _picker = ImagePicker();
  
  // TODO: Replace with your actual Cloudinary credentials
  // Create an unsigned upload preset in Settings -> Upload -> Upload presets
  final String _cloudName = 'dfv1fonga';
  final String _uploadPreset = 'o4is0yr9';

  late final CloudinaryPublic _cloudinary;

  StorageService() {
    _cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);
  }

  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    return await _picker.pickImage(
      source: source,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 80,
    );
  }

  Future<String> uploadAssetImage(XFile file, String assetId) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: 'assets/$assetId',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image to Cloudinary: $e');
    }
  }

  Future<String> uploadEmployeePhoto(XFile file, String employeeId) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          folder: 'employees/$employeeId',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload photo to Cloudinary: $e');
    }
  }

  Future<void> deleteImage(String url) async {
    // Note: Deleting images from client-side Cloudinary is restricted 
    // unless you use a signed API or specific settings.
    // For free/simple setup, we usually just replace the URL in Firestore.
  }
}
