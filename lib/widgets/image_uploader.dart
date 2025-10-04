import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health/services/cloudinary_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageUploader extends StatefulWidget {
  final String? initialImageUrl;
  final Function(File) onImageSelected;
  final double height;
  final double width;
  final double borderRadius;
  final String placeholder;
  
  const ImageUploader({
    super.key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.height = 200,
    this.width = double.infinity,
    this.borderRadius = 12.0,
    this.placeholder = 'Upload Image',
  });

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  File? _selectedImage;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final imageFile = await CloudinaryService.showImagePickerDialog(context);
        if (imageFile != null) {
          setState(() {
            _selectedImage = imageFile;
          });
          widget.onImageSelected(imageFile);
        }
      },
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: _buildImageContent(),
      ),
    );
  }
  
  Widget _buildImageContent() {
    if (_selectedImage != null) {
      // Show selected image
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: Image.file(
          _selectedImage!,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      // Show image from URL
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: CachedNetworkImage(
          imageUrl: widget.initialImageUrl!,
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        ),
      );
    } else {
      // Show placeholder
      return _buildPlaceholder();
    }
  }
  
  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_a_photo,
            size: 40,
            color: Colors.grey,
          ),
          const SizedBox(height: 8),
          Text(
            widget.placeholder,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}