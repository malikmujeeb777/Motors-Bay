import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'model_viewer_page.dart';
import 'home_model.dart';
import 'services/model_service.dart';
import 'services/model_helper.dart';

class MyModelsScreen extends StatefulWidget {
  const MyModelsScreen({Key? key}) : super(key: key);

  @override
  State<MyModelsScreen> createState() => _MyModelsScreenState();
}

class _MyModelsScreenState extends State<MyModelsScreen> {
  List<FileSystemEntity> _savedModels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedModels();
  }

  Future<void> _refreshModels() async {
    setState(() {
      _isLoading = true;
    });
    await _loadSavedModels();
  }

  Future<void> _loadSavedModels() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory(path.join(appDir.path, 'models'));
      
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }

      final files = await modelsDir.list().toList();
      setState(() {
        _savedModels = files.where((file) {
          final ext = path.extension(file.path).toLowerCase();
          // Accept more 3D model file formats
          return ['.glb', '.gltf', '.obj', '.fbx', '.stl', '.3ds'].contains(ext);
        }).toList();
        
        // Sort models by creation time (newest first)
        _savedModels.sort((a, b) {
          final aStat = a.statSync();
          final bStat = b.statSync();
          return bStat.modified.compareTo(aStat.modified);
        });
        
        _isLoading = false;
      });
      
      // Debug print to verify models are loaded
      print('Loaded ${_savedModels.length} models:');
      for (var model in _savedModels) {
        print('- ${path.basename(model.path)}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading models: $e'); // Debug print
      Get.snackbar(
        'Error',
        'Failed to load models: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _deleteModel(FileSystemEntity model) async {
    try {
      await model.delete();
      await _loadSavedModels();
      Get.snackbar(
        'Success',
        'Model deleted successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete model: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _shareModel(FileSystemEntity model) async {
    try {
      await Share.shareXFiles([XFile(model.path)], text: 'Check out this 3D model!');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share model: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _renameModel(FileSystemEntity model) async {
    final TextEditingController nameController = TextEditingController(
      text: path.basenameWithoutExtension(model.path)
    );
    
    final result = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Rename Model'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'New Name',
                hintText: 'Enter new name for the model',
                helperText: 'Spaces are not allowed in the filename',
              ),
              autofocus: true,
              onChanged: (value) {
                // Remove spaces as user types
                if (value.contains(' ')) {
                  nameController.text = value.replaceAll(' ', '');
                  nameController.selection = TextSelection.fromPosition(
                    TextPosition(offset: nameController.text.length),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Filename cannot be empty',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              if (newName.contains(' ')) {
                Get.snackbar(
                  'Error',
                  'Spaces are not allowed in the filename',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }
              Get.back(result: newName);
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final newPath = path.join(
          path.dirname(model.path),
          '$result${path.extension(model.path)}'
        );
        await model.rename(newPath);
        await _loadSavedModels();
        Get.snackbar(
          'Success',
          'Model renamed successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to rename model: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Models'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshModels,
            tooltip: 'Refresh Models',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Get.to(() => const HomeModel());
          // Refresh the list when returning from adding a new model
          _refreshModels();
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('Model'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshModels,
        child: _savedModels.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.view_in_ar_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Models Saved',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Upload 3D models to view them here',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: _savedModels.map((model) {
                    final fileName = path.basename(model.path);
                    final fileInfo = model.statSync();
                    final modifiedDate = DateTime.fromMillisecondsSinceEpoch(
                      fileInfo.modified.millisecondsSinceEpoch
                    );
                    
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.4,
                            child: Stack(
                              children: [
                                Container(
                                  color: const Color(0xFFF5F5F5),
                                  child: ModelViewer(
                                    src: "file://${model.path}",
                                    alt: "3D Model Preview",
                                    ar: false,
                                    cameraControls: true,
                                    autoRotate: true,
                                    disableZoom: true,
                                    backgroundColor: const Color(0xFFF5F5F5),
                                    minCameraOrbit: "auto 70deg 150%",
                                    maxCameraOrbit: "auto 90deg 100m",
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        onPressed: () => _renameModel(model),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.share, color: Colors.blue),
                                        onPressed: () => _shareModel(model),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () => _deleteModel(model),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  fileName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Added: ${modifiedDate.toString().split('.')[0]}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'File Type: ${path.extension(fileName).toUpperCase()}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
      ),
    );
  }
} 