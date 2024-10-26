import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Take a photo using the camera
  static Future<String?> takePhoto({
    double? maxWidth = 1800,
    double? maxHeight = 1800,
    int? imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        // Create a directory for storing images if it doesn't exist
        final directory = await getApplicationDocumentsDirectory();
        final imagesDirectory = Directory('${directory.path}/store_images');
        if (!await imagesDirectory.exists()) {
          await imagesDirectory.create(recursive: true);
        }

        // Generate a unique filename
        final filename = 'store_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File('${imagesDirectory.path}/$filename');

        // Copy the image to our app's directory
        await File(image.path).copy(savedImage.path);

        return savedImage.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error taking photo: $e');
      return null;
    }
  }

  /// Pick an image from the gallery
  static Future<String?> pickImage({
    double? maxWidth = 1800,
    double? maxHeight = 1800,
    int? imageQuality = 85,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        // Create a directory for storing images if it doesn't exist
        final directory = await getApplicationDocumentsDirectory();
        final imagesDirectory = Directory('${directory.path}/store_images');
        if (!await imagesDirectory.exists()) {
          await imagesDirectory.create(recursive: true);
        }

        // Generate a unique filename
        final filename = 'store_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final savedImage = File('${imagesDirectory.path}/$filename');

        // Copy the image to our app's directory
        await File(image.path).copy(savedImage.path);

        return savedImage.path;
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Delete an image file
  static Future<bool> deleteImage(String? imagePath) async {
    if (imagePath == null) return false;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Get image dimensions
  static Future<Map<String, int>?> getImageDimensions(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (!await imageFile.exists()) return null;

      final image = await decodeImageFromList(await imageFile.readAsBytes());
      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      debugPrint('Error getting image dimensions: $e');
      return null;
    }
  }

  /// Get file size in MB
  static Future<double?> getFileSize(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.length();
      return bytes / (1024 * 1024); // Convert to MB
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return null;
    }
  }

  /// Clean up old temporary images
  static Future<void> cleanupTempImages() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDirectory = Directory('${directory.path}/store_images');

      if (await imagesDirectory.exists()) {
        final entities = await imagesDirectory.list().toList();
        final now = DateTime.now();

        for (var entity in entities) {
          if (entity is File) {
            final fileStat = await entity.stat();
            final fileAge = now.difference(fileStat.modified);

            // Delete files older than 24 hours that aren't referenced
            if (fileAge.inHours > 24) {
              await entity.delete();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up temp images: $e');
    }
  }

  /// Show image picker dialog
  static Future<String?> showImagePickerDialog(BuildContext context) async {
    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await takePhoto();
                  if (imagePath != null) {
                    Navigator.of(context).pop(imagePath);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final imagePath = await pickImage();
                  if (imagePath != null) {
                    Navigator.of(context).pop(imagePath);
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Display image preview dialog
  static Future<void> showImagePreview(BuildContext context, String imagePath) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Image Preview'),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Validate image file
  static Future<bool> isValidImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) return false;

      final bytes = await file.readAsBytes();
      await decodeImageFromList(bytes);
      return true;
    } catch (e) {
      debugPrint('Error validating image: $e');
      return false;
    }
  }
}