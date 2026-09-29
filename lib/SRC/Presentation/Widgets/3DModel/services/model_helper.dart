import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Helper class for loading and managing 3D model files
class ModelHelper {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final Map<String, String> _modelUrlCache = {};
  
  /// Gets the proper URL or asset path for a model for use with model_viewer_plus
  static String getModelViewerPath(String path) {
    if (path.startsWith('http') || path.startsWith('data:')) {
      return path;
    } else if (path.startsWith('assets/')) {
      return 'asset:$path';
    } else {
      return 'file://$path';
    }
  }
  
  /// Loads a model from assets to a temporary file for use with model_viewer_plus
  static Future<String> loadModelToFile(String assetPath) async {
    try {
      final fileName = assetPath.split('/').last;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      
      if (await file.exists()) {
        return file.path;
      }
      
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes);
      
      return file.path;
    } catch (e) {
      print('Error loading model to file: $e');
      return assetPath;
    }
  }
  
  /// Gets the URL for a 3D model from Firebase Storage
  static Future<String> getModelUrl(String assetPath) async {
    if (_modelUrlCache.containsKey(assetPath)) {
      return _modelUrlCache[assetPath]!;
    }

    final fileName = assetPath.split('/').last;
    
    try {
      final ref = _storage.ref('models/$fileName');
      
      try {
        final url = await ref.getDownloadURL();
        _modelUrlCache[assetPath] = url;
        return url;
      } catch (e) {
        return await _uploadModelToStorage(assetPath, ref);
      }
    } catch (e) {
      print('Error accessing Firebase Storage: $e');
      return 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
    }
  }

  /// Uploads a model from assets to Firebase Storage
  static Future<String> _uploadModelToStorage(String assetPath, Reference ref) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final List<int> bytes = data.buffer.asUint8List();
      
      await ref.putData(Uint8List.fromList(bytes));
      final url = await ref.getDownloadURL();
      
      _modelUrlCache[assetPath] = url;
      return url;
    } catch (e) {
      print('Error uploading model from assets: $e');
      return 'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
    }
  }
} 