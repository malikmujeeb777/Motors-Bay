import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:async';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'controller/upload_controller.dart';
import 'package:flutter/cupertino.dart';
import 'view_360_images.dart';
import 'package:image/image.dart' as img;

class Capture360View extends StatefulWidget {
  final int? retakeIndex;
  
  const Capture360View({super.key, this.retakeIndex});

  @override
  State<Capture360View> createState() => _Capture360ViewState();
}

class _Capture360ViewState extends State<Capture360View> with SingleTickerProviderStateMixin {
  final UploadController controller = Get.find<UploadController>();
  bool _isInitialized = false;
  bool _isGenerating = false;
  double _generationProgress = 0.0;
  late AnimationController _shutterController;
  late Animation<double> _shutterAnimation;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _shutterController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _shutterAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _shutterController,
        curve: Curves.easeInOut,
      ),
    );
    controller.onShutterEffect = () {
      _shutterController.forward(from: 0.0);
      Future.delayed(const Duration(milliseconds: 300), () {
        _shutterController.reverse();
      });
    };
  }

  @override
  void dispose() {
    _shutterController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      await controller.initializeCamera();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize camera: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _captureWithShutter() async {
    if (!controller.isCapturing.value) {
      try {
        _shutterController.forward(from: 0.0);
        await controller.captureImage();
        await Future.delayed(const Duration(milliseconds: 300));
        _shutterController.reverse();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to capture image. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.only(top: 50),
        );
      }
    }
  }

  Future<void> _captureAndReturn() async {
    if (!controller.isCapturing.value) {
      try {
        _shutterController.forward(from: 0.0);
        final XFile image = await controller.cameraController.takePicture();
        await Future.delayed(const Duration(milliseconds: 300));
        _shutterController.reverse();
        Get.back(result: image.path);
      } catch (e) {
        Get.snackbar(
          'Error',
          'Failed to capture image. Please try again.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.only(top: 50),
        );
      }
    }
  }

  void _showModelGenerationDialog() {
    if (controller.imageCount.value < 36) {
      Get.snackbar(
        'Not Enough Images',
        'Please capture at least 36 images for 360° view',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('View Options'),
        content: const Text(
          'What would you like to do with the captured images?'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.to(() => const View360Images(), arguments: controller.capturedImages.map((path) => File(path)).toList());
            },
            child: const Text('View 360°'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateModel();
            },
            child: const Text('Generate 3D Model'),
          ),
        ],
      ),
    );
  }

  Future<void> _generateModel() async {
    if (controller.imageCount.value < 36) {
      Get.snackbar(
        'Error',
        'Please capture at least 36 images before generating the model',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.only(top: 50),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _generationProgress = 0.0;
    });

    try {
      // Simulate progress for better UX
      while (_generationProgress < 1.0) {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _generationProgress = (_generationProgress + 0.1).clamp(0.0, 1.0);
        });
      }

      Get.offNamed('/view360', arguments: controller.capturedImages.map((path) => File(path)).toList());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate model: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.only(top: 50),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await controller.disposeCamera();
        Get.back();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: !_isInitialized
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing camera...'),
                  ],
                ),
              )
            : Stack(
                children: [
                  // Camera preview
                  SizedBox.expand(
                    child: CameraPreview(controller.cameraController),
                  ),
                  // Shutter effect
                  AnimatedBuilder(
                    animation: _shutterAnimation,
                    builder: (context, child) {
                      return Container(
                        color: Colors.white.withOpacity(_shutterAnimation.value * 0.8),
                      );
                    },
                  ),
                  // Back button
                  Positioned(
                    top: 60,
                    child: BackButton(
                      onPressed: () async {
                        await controller.disposeCamera();
                        Get.back();
                      },
                      color: Colors.white,
                    ),
                  ),
                  // Hint message
                  Positioned(
                    top: 60,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.retakeIndex != null 
                              ? 'Retake image ${widget.retakeIndex! + 1}'
                              : 'Slightly rotate and capture',
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  // Photo count display
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Obx(() => Text(
                            'Photos Captured: ${controller.imageCount.value}/36',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          )),
                    ),
                  ),
                  // Flash toggle button
                  Positioned(
                    bottom: 260,
                    left: 30,
                    child: FloatingActionButton(
                      heroTag: 'flash',
                      backgroundColor: Colors.white,
                      onPressed: controller.toggleFlash,
                      child: Obx(() => Icon(
                            controller.flashOn.value
                                ? Icons.flash_on
                                : Icons.flash_off,
                            color: Colors.black,
                          )),
                    ),
                  ),
                  // View captured images button
                  Positioned(
                    bottom: 260,
                    right: 30,
                    child: FloatingActionButton(
                      heroTag: 'view',
                      backgroundColor: Colors.white,
                      onPressed: () async {
                        if (controller.flashOn.value) {
                          await controller.toggleFlash();
                        }
                        if (controller.imageCount.value > 0) {
                          Get.to(() => ImageReviewScreen(
                                imagePaths: controller.capturedImages,
                                onImagesFinalized: (images) {
                                  controller.capturedImages = images;
                                  controller.imageCount.value = images.length;
                                },
                              ));
                        } else {
                          Get.snackbar(
                            'No Images',
                            'Please capture some images first',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.eye, color: Colors.black),
                          const Text(
                            'Images',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

        // Capture buttons
        floatingActionButton: !_isInitialized
            ? null
            : Padding(
                padding: EdgeInsets.only(left: Get.width * 0.08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Video capture button
                    FloatingActionButton(
                      heroTag: 'video',
                      onPressed: controller.toggleVideoCapture,
                      child: Obx(() => Icon(
                            controller.isCapturing.value
                                ? Icons.stop
                                : Icons.videocam,
                            color: controller.isCapturing.value
                                ? Colors.red
                                : Colors.white,
                          )),
                    ),
                    const SizedBox(width: 20),
                    // Photo capture button
                    FloatingActionButton(
                      heroTag: 'capture',
                      onPressed: widget.retakeIndex != null 
                          ? _captureAndReturn
                          : _captureWithShutter,
                      child: const Icon(CupertinoIcons.camera),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class ImageReviewScreen extends StatefulWidget {
  final List<String> imagePaths;
  final Function(List<String>) onImagesFinalized;

  const ImageReviewScreen({
    Key? key,
    required this.imagePaths,
    required this.onImagesFinalized,
  }) : super(key: key);

  @override
  State<ImageReviewScreen> createState() => _ImageReviewScreenState();
}

class _ImageReviewScreenState extends State<ImageReviewScreen> {
  late List<String> _currentImagePaths;
  int _selectedImageIndex = 0;
  bool _isGenerating = false;
  double _generationProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _currentImagePaths = List.from(widget.imagePaths);
  }

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final item = _currentImagePaths.removeAt(oldIndex);
      _currentImagePaths.insert(newIndex, item);
      widget.onImagesFinalized(_currentImagePaths);
    });
  }

  Future<void> _retakeImage(int index) async {
    final result = await Get.to(() => Capture360View(retakeIndex: index));
    if (result != null && result is String) {
      setState(() {
        _currentImagePaths[index] = result;
        widget.onImagesFinalized(_currentImagePaths);
      });
    }
  }

  void _removeImage(int index) {
    if (_currentImagePaths.length <= 36) {
      Get.snackbar(
        'Cannot Delete',
        'Minimum 36 images required for 360° view',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _currentImagePaths.removeAt(index);
      if (_selectedImageIndex >= _currentImagePaths.length) {
        _selectedImageIndex = _currentImagePaths.length - 1;
      }
      widget.onImagesFinalized(_currentImagePaths);
    });
  }

  Future<void> _generateModel() async {
    if (_currentImagePaths.length < 36) {
      Get.snackbar(
        'Not Enough Images',
        'Please capture at least 36 images for 360° view',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        _isGenerating = false;
      });
      return;
    }

    try {
      // Simulate model generation process with progress
      for (int i = 0; i <= 100; i += 10) {
        if (!mounted) break;
        setState(() {
          _generationProgress = i / 100;
        });
        await Future.delayed(const Duration(milliseconds: 300));
      }
      
      // Navigate to View360Images
      Get.off(() => const View360Images(), 
        arguments: _currentImagePaths.map((path) => File(path)).toList()
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate model: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        _isGenerating = false;
        _generationProgress = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGenerating) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      value: _generationProgress,
                      strokeWidth: 12,
                    ),
                  ),
                  Text(
                    '${(_generationProgress * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _generateModel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Generate Model',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isGenerating = false;
                    _generationProgress = 0.0;
                  });
                },
                child: const Text(
                  'Take More Images',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Review Images'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _isGenerating = true;
              });
            },
            child: const Text(
              'DONE',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: ReorderableGridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _currentImagePaths.length,
        onReorder: _reorderImages,
        itemBuilder: (context, index) {
          return _buildImageItem(index);
        },
      ),
    );
  }

  Widget _buildImageItem(int index) {
    return Container(
      key: ValueKey(_currentImagePaths[index]),
      decoration: BoxDecoration(
        border: Border.all(
          color: _selectedImageIndex == index ? Colors.blue : Colors.transparent,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _showFullScreenImage(_currentImagePaths[index]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.file(
                File(_currentImagePaths[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: () => _removeImage(index),
                  iconSize: 20,
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => _retakeImage(index),
                  iconSize: 20,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenImage(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(imagePath: imagePath),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imagePath;

  const FullScreenImageViewer({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
} 