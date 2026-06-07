import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';

/// A circular avatar with a camera overlay that lets users pick/change
/// an employee profile photo from camera or gallery.
class EmployeeImagePicker extends StatelessWidget {
  const EmployeeImagePicker({
    super.key,
    this.currentImageUrl,
    this.localImagePath,
    required this.initials,
    required this.onImagePicked,
    this.radius = 48,
  });

  /// Network URL of the current profile image (from backend).
  final String? currentImageUrl;

  /// Local file path when user has picked a new image but not yet uploaded.
  final String? localImagePath;

  /// Fallback initials.
  final String initials;

  /// Called when user picks an image. Provides the local file path.
  final ValueChanged<String> onImagePicked;

  /// Radius of the avatar circle.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => _showPickerSheet(context),
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: _resolveImage(),
            child: _resolveImage() == null
                ? Text(
                    initials,
                    style: TextStyle(
                      fontSize: radius * 0.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: cs.primary,
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 2),
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: radius * 0.35,
                color: cs.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider? _resolveImage() {
    if (localImagePath != null) {
      return FileImage(File(localImagePath!));
    }
    if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      return NetworkImage(currentImageUrl!);
    }
    return null;
  }

  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Profile Photo',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE3F2FD),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F5E9),
                  child: Icon(Icons.photo_library, color: AppColors.success),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null) {
      onImagePicked(picked.path);
    }
  }
}
