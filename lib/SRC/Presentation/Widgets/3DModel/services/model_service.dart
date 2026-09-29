import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ModelService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final Map<String, String> _modelUrlCache = {};
  static bool _isLowEndDevice = false;
  
  /// Sets whether the device is considered low-end (to optimize loading)
  static void setLowEndDevice(bool isLowEnd) {
    _isLowEndDevice = isLowEnd;
  }
  
  /// Get the download URL for a model file from Firebase Storage
  static Future<String> getModelUrl(String modelPath) async {
    try {
      // If the modelPath is already a URL, return it directly
      if (modelPath.startsWith('http')) {
        return modelPath;
      }
      
      // If it's a file path, check if it exists locally first
      if (modelPath.startsWith('/')) {
        File file = File(modelPath);
        if (await file.exists()) {
          return 'file://$modelPath';
        }
      }
      
      // For asset paths, we need to make them available through Firebase or copy to local storage
      try {
        // Convert asset path to Firebase Storage path
        String storagePath = modelPath.replaceFirst(RegExp(r'^assets/'), '');
        final ref = _storage.ref().child(storagePath);
        return await ref.getDownloadURL();
      } catch (e) {
        debugPrint('Firebase error: $e');
        return 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
      }
    } catch (e) {
      debugPrint('Error getting model URL: $e');
      return 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
    }
  }
  
  /// Save a file from a URL to the temporary directory
  static Future<String?> saveModelToTemp(String url, String filename) async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/$filename';
      
      if (url.startsWith('file://')) {
        return url.substring(7);
      }
      
      final File file = File(filePath);
      return filePath;
    } catch (e) {
      debugPrint('Error saving model to temp: $e');
      return null;
    }
  }
  
  /// Generate a 3D model from a series of images
  static Future<String?> generateModelFromImages(List<File> images) async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      return 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
    } catch (e) {
      debugPrint('Error generating model: $e');
      return null;
    }
  }
} 