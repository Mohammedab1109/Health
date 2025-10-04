import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health/services/cloudinary_service.dart';
import 'package:health/services/auth_service.dart';
import 'package:health/theme/app_theme.dart';

/// A utility page to test image upload and storage functionality
class TestImageUploadPage extends StatefulWidget {
  const TestImageUploadPage({super.key});

  @override
  State<TestImageUploadPage> createState() => _TestImageUploadPageState();
}

class _TestImageUploadPageState extends State<TestImageUploadPage> {
  bool _isLoading = false;
  File? _selectedImage;
  String? _uploadedImageUrl;
  String? _savedImageUrl;
  String _status = '';
  
  Future<void> _pickImage() async {
    final imageFile = await CloudinaryService.showImagePickerDialog(context);
    if (imageFile != null) {
      setState(() {
        _selectedImage = imageFile;
        _uploadedImageUrl = null;
        _savedImageUrl = null;
        _status = 'Image selected: ${imageFile.path}';
      });
    }
  }
  
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      setState(() {
        _status = 'Please select an image first';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _status = 'Uploading image...';
    });
    
    try {
      // Upload the image to Cloudinary
      final userId = AuthService.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _status = 'Error: Not signed in';
          _isLoading = false;
        });
        return;
      }
      
      final imageUrl = await CloudinaryService.uploadProfileImage(
        _selectedImage!,
        userId,
      );
      
      setState(() {
        _uploadedImageUrl = imageUrl;
        _status = imageUrl != null 
            ? '✅ Successfully uploaded to Cloudinary' 
            : '❌ Failed to upload image';
      });
      
    } catch (e) {
      setState(() {
        _status = '❌ Error uploading: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveToProfile() async {
    if (_uploadedImageUrl == null) {
      setState(() {
        _status = 'Please upload the image to Cloudinary first';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _status = 'Saving to profile...';
    });
    
    try {
      // Save the image URL to the user's profile
      await AuthService.updateUserProfile(
        profileImageUrl: _uploadedImageUrl,
      );
      
      // Verify it was saved
      final userData = await AuthService.getUserData();
      final savedImageUrl = userData?['profileImageUrl'];
      
      setState(() {
        _savedImageUrl = savedImageUrl;
        if (savedImageUrl == _uploadedImageUrl) {
          _status = '✅ Successfully saved to profile';
        } else {
          _status = '❌ Image URL mismatch: $savedImageUrl vs $_uploadedImageUrl';
        }
      });
      
    } catch (e) {
      setState(() {
        _status = '❌ Error saving to profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _verifyProfile() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking profile...';
    });
    
    try {
      final userData = await AuthService.getUserData();
      final profileImageUrl = userData?['profileImageUrl'];
      
      setState(() {
        _savedImageUrl = profileImageUrl;
        _status = profileImageUrl != null 
            ? '✅ Profile has image URL: $profileImageUrl' 
            : '❌ No profile image URL found';
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error checking profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Profile Image Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image preview
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: _buildImagePreview(),
                    ),
                    const SizedBox(height: 16),
                    
                    // Status
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _status.contains('✅') 
                            ? Colors.green.withOpacity(0.1)
                            : _status.contains('❌')
                                ? Colors.red.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        _status.isNotEmpty ? _status : 'No action taken yet',
                        style: TextStyle(
                          color: _status.contains('✅') 
                              ? Colors.green
                              : _status.contains('❌')
                                  ? Colors.red
                                  : Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Image URLs
                    if (_uploadedImageUrl != null)
                      _buildInfoRow('Uploaded URL:', _uploadedImageUrl!),
                    if (_savedImageUrl != null)
                      _buildInfoRow('Saved URL:', _savedImageUrl!),
                    const SizedBox(height: 24),
                    
                    // Test steps
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo),
                      label: const Text('1. Select Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ElevatedButton.icon(
                      onPressed: _selectedImage != null ? _uploadImage : null,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('2. Upload to Cloudinary'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ElevatedButton.icon(
                      onPressed: _uploadedImageUrl != null ? _saveToProfile : null,
                      icon: const Icon(Icons.save),
                      label: const Text('3. Save to Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.vibrantTeal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    ElevatedButton.icon(
                      onPressed: _verifyProfile,
                      icon: const Icon(Icons.verified_user),
                      label: const Text('4. Verify Profile Image'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
  
  Widget _buildImagePreview() {
    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
        ),
      );
    } else if (_savedImageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          _savedImageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(height: 8),
                  Text('Error loading image: $error'),
                ],
              ),
            );
          },
        ),
      );
    } else {
      return const Center(
        child: Text('No image selected'),
      );
    }
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}