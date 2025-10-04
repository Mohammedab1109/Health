import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health/services/auth_service.dart';
import 'package:health/services/cloudinary_service.dart';
import 'package:health/widgets/loading_indicator.dart';
import 'package:health/widgets/image_uploader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:health/theme/app_theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  
  // State variables
  bool _isLoading = true;
  bool _isSaving = false;
  String _errorMessage = '';
  Map<String, dynamic>? _userData;
  
  // Profile image
  File? _selectedImage;
  String? _profileImageUrl;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = AuthService.currentUser;
      
      if (user != null) {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
            
        if (docSnapshot.exists) {
          setState(() {
            _userData = docSnapshot.data();
            _isLoading = false;
            
            // Set profile image URL
            _profileImageUrl = _userData?['profileImageUrl'];
            
            // Initialize form controllers
            _firstNameController.text = _userData?['firstName'] ?? '';
            _lastNameController.text = _userData?['lastName'] ?? '';
            _heightController.text = _userData?['height']?.toString() ?? '';
            _weightController.text = _userData?['weight']?.toString() ?? '';
          });
        } else {
          setState(() {
            _errorMessage = 'User profile not found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'User not authenticated';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  
  // Save profile changes
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = '';
    });
    
    try {
      // Upload profile image if a new one was selected
      String? newProfileImageUrl;
      if (_selectedImage != null) {
        try {
          // Show subtle loading indicator
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Updating profile picture...'),
                duration: Duration(seconds: 1),
              ),
            );
          }
          
          newProfileImageUrl = await CloudinaryService.uploadProfileImage(
            _selectedImage!,
            AuthService.currentUser!.uid,
          );
          
          if (newProfileImageUrl == null || newProfileImageUrl.isEmpty) {
            throw Exception('Failed to upload profile picture');
          }
        } catch (e) {
          // Continue with profile update even if image upload fails
          debugPrint('Image upload failed, continuing with profile update: $e');
        }
      }
      
      // Prepare profile data
      final profileData = {
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'fullName': '${_firstNameController.text} ${_lastNameController.text}',
      };
      
      // Add optional fields if they exist
      if (_heightController.text.isNotEmpty) {
        profileData['height'] = _heightController.text;
      }
      
      if (_weightController.text.isNotEmpty) {
        profileData['weight'] = _weightController.text;
      }
      
      // Update user profile
      await AuthService.updateUserProfile(
        data: profileData,
        profileImageUrl: newProfileImageUrl,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.of(context).pop(true); // Return true to indicate update was successful
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      setState(() {
        _errorMessage = 'Error updating profile: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  
  // Build initials for avatar
  String _getInitials() {
    final firstName = _firstNameController.text;
    final lastName = _lastNameController.text;
    
    String initials = '';
    if (firstName.isNotEmpty) initials += firstName[0];
    if (lastName.isNotEmpty) initials += lastName[0];
    if (initials.isEmpty) initials = 'U';
    
    return initials;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: _isSaving ? Colors.grey : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: LoadingIndicator(message: 'Loading profile...'))
          : _isSaving
              ? const Center(child: LoadingIndicator(message: 'Saving profile...'))
              : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
                  : _buildEditForm(),
    );
  }

  Widget _buildEditForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Image Editor
            Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: ImageUploader(
                    initialImageUrl: _profileImageUrl,
                    onImageSelected: (File image) {
                      setState(() {
                        _selectedImage = image;
                      });
                    },
                    height: 130,
                    width: 130,
                    borderRadius: 65,
                    placeholder: _getInitials(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () async {
                final imageFile = await CloudinaryService.showImagePickerDialog(context);
                if (imageFile != null) {
                  setState(() {
                    _selectedImage = imageFile;
                  });
                }
              },
              child: TextButton.icon(
                onPressed: () async {
                  final imageFile = await CloudinaryService.showImagePickerDialog(context);
                  if (imageFile != null) {
                    setState(() {
                      _selectedImage = imageFile;
                    });
                  }
                },
                icon: const Icon(Icons.camera_alt, size: 16),
                label: const Text('Change Profile Picture'),
              ),
            ),
            const SizedBox(height: 24),
            
            // Form Fields
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: 'First Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: 'Last Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Height
            TextFormField(
              controller: _heightController,
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Weight
            TextFormField(
              controller: _weightController,
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }
}