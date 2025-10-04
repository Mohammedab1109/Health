import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // Cloudinary credentials - from your CLOUDINARY_URL
  static const String cloudName = 'dmsqlo9eu';
  static const String apiKey = '517459116676234';
  static const String apiSecret = '5z786TymlYWnO3nWpTZqeOqy0hk';
  static const String uploadPreset = 'ml_default';   // Using default upload preset

  static final cloudinary = CloudinaryPublic(cloudName, uploadPreset, cache: false);

  // Pick image from gallery
  static Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,  // Compress image quality
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Pick image from camera
  static Future<File?> takeImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,  // Compress image quality
    );

    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Upload image to Cloudinary
  static Future<String?> uploadImage(File imageFile, {String folder = 'fitconnect'}) async {
    try {
      debugPrint('Starting Cloudinary upload to folder: $folder');
      debugPrint('Image file exists: ${imageFile.existsSync()}');
      debugPrint('Image file size: ${imageFile.lengthSync()} bytes');
      
      // Upload to cloudinary
      final response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
          folder: folder,
        ),
      );
      
      // Return the secure URL
      debugPrint('Cloudinary upload success, URL: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      debugPrint('Error uploading to Cloudinary: $e');
      // Instead of returning null and silently failing, rethrow the error
      // so the calling function can properly handle it
      rethrow;
    }
  }

  // Upload profile image to Cloudinary
  static Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      debugPrint('Uploading profile image for user: $userId');
      debugPrint('File exists: ${imageFile.existsSync()}, Size: ${imageFile.lengthSync()} bytes');
      debugPrint('Using cloudName: $cloudName, apiKey: $apiKey');
      
      final result = await uploadImage(imageFile, folder: 'fitconnect/profiles/$userId');
      
      debugPrint('Profile image upload result: $result');
      if (result != null && result.isNotEmpty) {
        debugPrint('✅ SUCCESS: Image uploaded to Cloudinary');
      } else {
        debugPrint('❌ ERROR: Failed to get URL from Cloudinary');
      }
      
      return result;
    } catch (e) {
      debugPrint('❌ ERROR in uploadProfileImage: $e');
      rethrow;
    }
  }

  // Upload event image to Cloudinary
  static Future<String?> uploadEventImage(File imageFile, String eventId) async {
    return uploadImage(imageFile, folder: 'fitconnect/events/$eventId');
  }

  // Show image picker dialog
  static Future<File?> showImagePickerDialog(BuildContext context) async {
    return await showDialog<File?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Take a picture'),
                  onTap: () async {
                    final image = await takeImage();
                    Navigator.of(context).pop(image);
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  child: const Text('Select from gallery'),
                  onTap: () async {
                    final image = await pickImage();
                    Navigator.of(context).pop(image);
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}