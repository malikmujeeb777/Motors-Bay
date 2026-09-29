import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter/services.dart';

// Model data class to hold both asset path and file path
class ModelData {
  final String assetPath;
  final String? filePath;
  final String carMake;
  final String carModel;
  final bool isFirst;

  ModelData({
    required this.assetPath,
    this.filePath,
    required this.carMake,
    required this.carModel,
    required this.isFirst,
  });
}

class DualModelViewerPage extends StatefulWidget {
  final Map<String, String> car1;
  final Map<String, String> car2;

  const DualModelViewerPage({
    Key? key,
    required this.car1,
    required this.car2,
  }) : super(key: key);

  @override
  State<DualModelViewerPage> createState() => _DualModelViewerPageState();
}

class _DualModelViewerPageState extends State<DualModelViewerPage> {
  List<ModelData> _modelData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadComparisonModels();
  }

  Future<void> _refreshModels() async {
    setState(() {
      _isLoading = true;
    });
    await _loadComparisonModels();
  }

  Future<void> _loadComparisonModels() async {
    try {
      final List<ModelData> models = [];
      
      // Load first car model
      final model1 = await _getModelData(widget.car1['make']!, widget.car1['model']!, true);
      if (model1 != null) {
        models.add(model1);
      }
      
      // Load second car model
      final model2 = await _getModelData(widget.car2['make']!, widget.car2['model']!, false);
      if (model2 != null) {
        models.add(model2);
      }

      setState(() {
        _modelData = models;
        _isLoading = false;
      });
      
      // Debug print to verify models are loaded
      print('Loaded ${_modelData.length} comparison models:');
      for (var model in _modelData) {
        print('- ${model.carMake} ${model.carModel}: ${model.assetPath}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error loading comparison models: $e');
      Get.snackbar(
        'Error',
        'Failed to load comparison models: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<ModelData?> _getModelData(String make, String model, bool isFirst) async {
    try {
      // Always show Mercedes for first car and Ford GT for second car regardless of selection
      String assetPath;
      String displayMake;
      String displayModel;
      
      if (isFirst) {
        // First car always shows Mercedes
        assetPath = 'assets/models/mercedes_benz_190.glb';
        displayMake = 'Mercedes';
        displayModel = 'Benz 190';
      } else {
        // Second car always shows Ford GT (as Fortuner alternative)
        assetPath = 'assets/models/Ford_GT.glb';
        displayMake = 'Ford';
        displayModel = 'GT';
      }

      // Try to copy to temp file for better compatibility
      String? filePath;
      try {
        filePath = await _copyAssetToTemp(assetPath);
      } catch (e) {
        print('Could not copy asset to temp: $e');
        // Continue with asset path only
      }

      return ModelData(
        assetPath: assetPath,
        filePath: filePath,
        carMake: displayMake,
        carModel: displayModel,
        isFirst: isFirst,
      );
    } catch (e) {
      print('Error getting model data: $e');
      // Fallback to default models
      if (isFirst) {
        return ModelData(
          assetPath: 'assets/models/mercedes_benz_190.glb',
          filePath: null,
          carMake: 'Mercedes',
          carModel: 'Benz 190',
          isFirst: isFirst,
        );
      } else {
        return ModelData(
          assetPath: 'assets/models/Ford_GT.glb',
          filePath: null,
          carMake: 'Ford',
          carModel: 'GT',
          isFirst: isFirst,
        );
      }
    }
  }

  Future<String> _copyAssetToTemp(String assetPath) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = path.basename(assetPath);
    final tempFile = File('${tempDir.path}/$fileName');

    if (!await tempFile.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
    }

    return tempFile.path;
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
        title: const Text('3D Model Comparison'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshModels,
            tooltip: 'Refresh Models',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshModels,
        child: _modelData.isEmpty
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
                      'No Models Available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '3D models are not available for the selected cars',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: _modelData.map((modelData) {
                    return _buildModelCard(modelData);
                  }).toList(),
                ),
              ),
      ),
    );
  }

  Widget _buildModelCard(ModelData modelData) {
    final fileName = path.basename(modelData.assetPath);
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Car label header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: modelData.isFirst ? Colors.blue.shade50 : Colors.red.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: modelData.isFirst ? Colors.blue.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.directions_car,
                    size: 24,
                    color: modelData.isFirst ? Colors.blue : Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        modelData.carMake,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: modelData.isFirst ? Colors.blue.shade700 : Colors.red.shade700,
                        ),
                      ),
                      Text(
                        modelData.carModel,
                        style: TextStyle(
                          fontSize: 14,
                          color: modelData.isFirst ? Colors.blue.shade600 : Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // 3D Model Viewer (EXACT same implementation as MyModelsScreen)
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFFF5F5F5),
                  child: ModelViewer(
                    // Use file path if available, otherwise use asset path
                    src: modelData.filePath != null ? "file://${modelData.filePath}" : modelData.assetPath,
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
              ],
            ),
          ),
          
          // Model info (EXACT same implementation as MyModelsScreen)
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
  }
} 