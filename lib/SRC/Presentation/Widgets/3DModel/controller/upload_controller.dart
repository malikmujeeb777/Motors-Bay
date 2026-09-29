import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:typed_data';

class UploadController extends GetxController {
  late CameraController cameraController;
  final imageCount = 0.obs;
  final flashOn = false.obs;
  final isCapturing = false.obs;
  List<String> capturedImages = [];
  Timer? _captureTimer;
  bool _isProcessingCapture = false;
  Function? onShutterEffect;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      Get.snackbar(
        'Error',
        'No cameras found',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 50),
      );
      return;
    }

    cameraController = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await cameraController.initialize();
      if (cameraController.value.isInitialized) {
        await cameraController.setZoomLevel(1.0);
      }
      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initialize camera: $e',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 50),
      );
      rethrow;
    }
  }

  Future<void> toggleFlash() async {
    try {
      if (cameraController.value.isInitialized) {
        if (flashOn.value) {
          await cameraController.setFlashMode(FlashMode.off);
        } else {
          await cameraController.setFlashMode(FlashMode.torch);
        }
        flashOn.value = !flashOn.value;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to toggle flash: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> captureImage() async {
    if (!cameraController.value.isInitialized || _isProcessingCapture) {
      return;
    }

    try {
      _isProcessingCapture = true;
      
      // Trigger shutter effect
      onShutterEffect?.call();

      // Ensure we're at 1x zoom before capture
      await cameraController.setZoomLevel(1.0);
      
      final XFile image = await cameraController.takePicture();
      if (image.path.isNotEmpty) {
        capturedImages.add(image.path);
        imageCount.value = capturedImages.length;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to capture image: $e',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 50),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isProcessingCapture = false;
    }
  }

  void toggleVideoCapture() {
    if (isCapturing.value) {
      stopVideoCapture();
    } else {
      startVideoCapture();
    }
  }

  void startVideoCapture() {
    if (!cameraController.value.isInitialized) {
      Get.snackbar(
        'Error',
        'Camera not initialized',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.only(top: 50),
      );
      return;
    }

    isCapturing.value = true;
    _captureTimer?.cancel();
    _captureTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!_isProcessingCapture) {
        captureImage();
      }
    });
  }

  void stopVideoCapture() {
    _captureTimer?.cancel();
    _captureTimer = null;
    isCapturing.value = false;
    _isProcessingCapture = false;
  }

  Future<void> disposeCamera() async {
    stopVideoCapture();
    await cameraController.dispose();
  }

  @override
  void onClose() {
    disposeCamera();
    super.onClose();
  }
} 