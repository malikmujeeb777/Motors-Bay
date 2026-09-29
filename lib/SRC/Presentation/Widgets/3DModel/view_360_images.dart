import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'controller/upload_controller.dart';

class View360Images extends StatefulWidget {
  const View360Images({super.key});

  @override
  State<View360Images> createState() => _View360ImagesState();
}

class _View360ImagesState extends State<View360Images> {
  late List<File> images;
  int currentIndex = 0;
  double dragSensitivity = 10;
  double accumulatedDrag = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load360ImagesFromAssets();
  }

  Future<void> _load360ImagesFromAssets() async {
    try {
      setState(() => _isLoading = true);
      
      final List<File> loadedImages = [];
      
      // List of ALL 360 images from assets/images/3d_model folder
      final List<String> imageNames = [
        'IMG_20250626_094213.jpg',
        'IMG_20250626_094214.jpg',
        'IMG_20250626_094211.jpg',
        'IMG_20250626_094210.jpg',
        'IMG_20250626_094210_1.jpg',
        'IMG_20250626_094208.jpg',
        'IMG_20250626_094208_1.jpg',
        'IMG_20250626_094207.jpg',
        'IMG_20250626_094207_1.jpg',
        'IMG_20250626_094206.jpg',
        'IMG_20250626_094206_1.jpg',
        'IMG_20250626_094203.jpg',
        'IMG_20250626_094203_1.jpg',
        'IMG_20250626_094202_1.jpg',
        'IMG_20250626_094201.jpg',
        'IMG_20250626_094202.jpg',
        'IMG_20250626_094155.jpg',
        'IMG_20250626_094155_1.jpg',
        'IMG_20250626_094154_1.jpg',
        'IMG_20250626_094153.jpg',
        'IMG_20250626_094154.jpg',
        'IMG_20250626_094149_1.jpg',
        'IMG_20250626_094150.jpg',
        'IMG_20250626_094148_1.jpg',
        'IMG_20250626_094149.jpg',
        'IMG_20250626_094147.jpg',
        'IMG_20250626_094148.jpg',
        'IMG_20250626_094144_1.jpg',
        'IMG_20250626_094145.jpg',
        'IMG_20250626_094143.jpg',
        'IMG_20250626_094144.jpg',
        'IMG_20250626_094142.jpg',
        'IMG_20250626_094139.jpg',
        'IMG_20250626_094139_1.jpg',
        'IMG_20250626_094136.jpg',
        'IMG_20250626_094137.jpg',
        'IMG_20250626_094135.jpg',
        'IMG_20250626_094135_1.jpg',
        'IMG_20250626_094133.jpg',
        'IMG_20250626_094132.jpg',
        'IMG_20250626_094130.jpg',
        'IMG_20250626_094131.jpg',
        'IMG_20250626_094127.jpg',
        'IMG_20250626_094128.jpg',
        'IMG_20250626_094125.jpg',
        'IMG_20250626_094123.jpg',
        'IMG_20250626_094122.jpg',
        'IMG_20250626_094121.jpg',
        'IMG_20250626_094119.jpg',
        'IMG_20250626_094118.jpg',
        'IMG_20250626_094113.jpg',
        'IMG_20250626_094114.jpg',
        'IMG_20250626_094112.jpg',
        'IMG_20250626_094110.jpg',
        'IMG_20250626_094107.jpg',
        'IMG_20250626_094106.jpg',
        'IMG_20250626_094103.jpg',
        'IMG_20250626_094100.jpg',
        'IMG_20250626_094057.jpg',
        'IMG_20250626_094054.jpg',
        'IMG_20250626_094052.jpg',
        'IMG_20250626_094051.jpg',
        'IMG_20250626_094049.jpg',
        'IMG_20250626_094047.jpg',
        'IMG_20250626_094048.jpg',
        'IMG_20250626_094044.jpg',
        'IMG_20250626_094043.jpg',
        'IMG_20250626_094041.jpg',
        'IMG_20250626_094042.jpg',
        'IMG_20250626_094040.jpg',
        'IMG_20250626_094039.jpg',
        'IMG_20250626_094036.jpg',
        'IMG_20250626_094038.jpg',
      ];

      // Copy images from assets to temporary directory
      final tempDir = await getTemporaryDirectory();
      final modelDir = Directory('${tempDir.path}/360_model_temp');
      if (await modelDir.exists()) {
        await modelDir.delete(recursive: true);
      }
      await modelDir.create(recursive: true);

      // Load all images from assets
      for (int i = 0; i < imageNames.length; i++) {
        try {
          final imageName = imageNames[i];
          final assetPath = 'assets/images/3d_model/$imageName';
          
          // Load image from assets
          final byteData = await rootBundle.load(assetPath);
          final tempFile = File('${modelDir.path}/image_$i.jpg');
          await tempFile.writeAsBytes(byteData.buffer.asUint8List());
          
          loadedImages.add(tempFile);
        } catch (e) {
          print('Error loading image $i: $e');
          // Continue with other images even if one fails
        }
      }

      setState(() {
        images = loadedImages;
        currentIndex = 0;
        _isLoading = false;
      });

      print('Loaded ${images.length} 360 images from assets');
    } catch (e) {
      print('Error loading 360 images from assets: $e');
      setState(() {
        images = <File>[];
        _isLoading = false;
      });
    }
  }

  Future<void> _saveModel() async {
    bool? shouldSave = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Save Model"),
          content: const Text("Do you want to save this 360° model to your device?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (shouldSave ?? false) {
      try {
        // Create a directory for the model
        final directory = await getApplicationDocumentsDirectory();
        final modelDir = Directory('${directory.path}/360_models/${DateTime.now().millisecondsSinceEpoch}');
        await modelDir.create(recursive: true);

        // Copy all images to the model directory
        for (int i = 0; i < images.length; i++) {
          final image = images[i];
          final newPath = '${modelDir.path}/image_$i.jpg';
          await image.copy(newPath);
        }

        Get.snackbar(
          'Success',
          'Model saved successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.only(top: 50),
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to save model: $e',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.only(top: 50),
        );
      }
    }
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (images.isEmpty) return;
    
    accumulatedDrag += details.primaryDelta!;

    if (accumulatedDrag > dragSensitivity) {
      setState(() {
        currentIndex = (currentIndex - 1 + images.length) % images.length;
      });
      accumulatedDrag = 0;
    } else if (accumulatedDrag < -dragSensitivity) {
      setState(() {
        currentIndex = (currentIndex + 1) % images.length;
      });
      accumulatedDrag = 0;
    }
  }

  void _goBack() {
    // Simple back navigation - just go back to previous page
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('360° Vehicle View'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        actions: [
          if (images.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveModel,
              tooltip: 'Save Model',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Loading 360° Images...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            )
          : images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.view_in_ar_outlined,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No 360° Images Available',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '360° images are not available for this vehicle',
                        style: TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onHorizontalDragUpdate: _onHorizontalDragUpdate,
                        child: Center(
                          child: Container(
                            color: Colors.white,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: InteractiveViewer(
                                panEnabled: true,
                                minScale: 1.0,
                                maxScale: 4.0,
                                child: Image.file(
                                  images[currentIndex],
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        children: [
                          Text(
                            'Image ${currentIndex + 1} of ${images.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Drag left or right to rotate the vehicle',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
} 