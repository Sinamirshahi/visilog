import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';  // Fixed import
import 'dart:math';  // Add this for log and pow functions

class StorageHelper {
  static const String _prefsKey = 'store_data';
  static const String _photosDir = 'store_photos';
  static const String _documentsDir = 'store_documents';

  /// Get the application documents directory path
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Get or create a subdirectory in the app's documents directory
  static Future<Directory> _getDirectory(String subDir) async {
    final String localPath = await _localPath;
    final Directory directory = Directory('$localPath/$subDir');

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return directory;
  }

  /// Save a file and return its path
  static Future<String> saveFile(File file, {String? customName, String? subdirectory}) async {
    try {
      final String fileName = customName ??
          'file_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}';

      final Directory directory = await _getDirectory(subdirectory ?? _documentsDir);
      final String filePath = '${directory.path}/$fileName';

      // Copy file to app directory
      final File savedFile = await file.copy(filePath);
      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving file: $e');
      rethrow;
    }
  }

  /// Save a photo and return its path
  static Future<String> savePhoto(File photo, {String? customName}) async {
    try {
      final String fileName = customName ??
          'photo_${DateTime.now().millisecondsSinceEpoch}${path.extension(photo.path)}';

      final Directory directory = await _getDirectory(_photosDir);
      final String filePath = '${directory.path}/$fileName';

      // Copy photo to app directory
      final File savedFile = await photo.copy(filePath);
      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving photo: $e');
      rethrow;
    }
  }

  /// Delete a file
  static Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  /// Save data to SharedPreferences
  static Future<bool> saveData(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (data is String) {
        return await prefs.setString(key, data);
      } else if (data is int) {
        return await prefs.setInt(key, data);
      } else if (data is double) {
        return await prefs.setDouble(key, data);
      } else if (data is bool) {
        return await prefs.setBool(key, data);
      } else if (data is List<String>) {
        return await prefs.setStringList(key, data);
      } else {
        return await prefs.setString(key, json.encode(data));
      }
    } catch (e) {
      debugPrint('Error saving data: $e');
      return false;
    }
  }

  /// Load data from SharedPreferences
  static Future<dynamic> loadData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.get(key);
    } catch (e) {
      debugPrint('Error loading data: $e');
      return null;
    }
  }

  /// Clear all stored data
  static Future<bool> clearAllData() async {
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Clear files
      final String localPath = await _localPath;
      final Directory baseDir = Directory(localPath);

      if (await baseDir.exists()) {
        await baseDir.delete(recursive: true);
        await baseDir.create();
      }

      return true;
    } catch (e) {
      debugPrint('Error clearing data: $e');
      return false;
    }
  }

  /// Get storage statistics
  static Future<Map<String, dynamic>> getStorageStats() async {
    try {
      int totalSize = 0;
      int photoCount = 0;
      int documentCount = 0;

      // Calculate photos size and count
      final photosDir = await _getDirectory(_photosDir);
      await for (var entity in photosDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
          photoCount++;
        }
      }

      // Calculate documents size and count
      final documentsDir = await _getDirectory(_documentsDir);
      await for (var entity in documentsDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
          documentCount++;
        }
      }

      return {
        'totalSize': totalSize,
        'photoCount': photoCount,
        'documentCount': documentCount,
        'formattedSize': _formatBytes(totalSize),
      };
    } catch (e) {
      debugPrint('Error getting storage stats: $e');
      return {
        'totalSize': 0,
        'photoCount': 0,
        'documentCount': 0,
        'formattedSize': '0 B',
      };
    }
  }

  /// Clean up unused files
  static Future<void> cleanupUnusedFiles(List<String> usedFilePaths) async {
    try {
      final photosDir = await _getDirectory(_photosDir);
      final documentsDir = await _getDirectory(_documentsDir);

      // Clean photos directory
      await for (var entity in photosDir.list()) {
        if (entity is File && !usedFilePaths.contains(entity.path)) {
          await entity.delete();
        }
      }

      // Clean documents directory
      await for (var entity in documentsDir.list()) {
        if (entity is File && !usedFilePaths.contains(entity.path)) {
          await entity.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up files: $e');
    }
  }

  /// Export all data to a backup file
  static Future<File?> exportData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allData = prefs.getKeys().map((key) => {
        'key': key,
        'value': prefs.get(key),
      }).toList();

      final backupData = {
        'timestamp': DateTime.now().toIso8601String(),
        'data': allData,
      };

      final directory = await _getDirectory('backups');
      final file = File(
          '${directory.path}/backup_${DateTime.now().millisecondsSinceEpoch}.json'
      );

      await file.writeAsString(json.encode(backupData));
      return file;
    } catch (e) {
      debugPrint('Error exporting data: $e');
      return null;
    }
  }

  /// Import data from a backup file
  static Future<bool> importData(File backupFile) async {
    try {
      final content = await backupFile.readAsString();
      final backupData = json.decode(content);

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      for (var item in (backupData['data'] as List)) {
        final key = item['key'];
        final value = item['value'];
        await saveData(key, value);
      }

      return true;
    } catch (e) {
      debugPrint('Error importing data: $e');
      return false;
    }
  }

  /// Format bytes to human readable string
  static String _formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(2)} ${suffixes[i]}';
  }

  /// Check if a file exists
  static Future<bool> fileExists(String filePath) async {
    try {
      return await File(filePath).exists();
    } catch (e) {
      debugPrint('Error checking file existence: $e');
      return false;
    }
  }

  /// Get file size
  static Future<int?> getFileSize(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return null;
    }
  }

  /// Copy file to external storage
  static Future<String?> copyToExternalStorage(String filePath, String destination) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final newPath = path.join(destination, path.basename(filePath));
        await file.copy(newPath);
        return newPath;
      }
      return null;
    } catch (e) {
      debugPrint('Error copying file to external storage: $e');
      return null;
    }
  }
}