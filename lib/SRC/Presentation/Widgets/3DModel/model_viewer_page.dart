import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'my_models_screen.dart';
import 'services/model_service.dart';
import 'services/model_helper.dart';

class ModelViewerPage extends StatefulWidget {
  const ModelViewerPage({Key? key}) : super(key: key);

  @override
  State<ModelViewerPage> createState() => _ModelViewerPageState();
}

class _ModelViewerPageState extends State<ModelViewerPage> with WidgetsBindingObserver {
  String? filePath;
  bool _isSaving = false;
  bool _isPageVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handlePageVisible();
    prepareModel();
    print('ModelViewerPage: Initialized');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _handlePageInvisible();
    print('ModelViewerPage: Disposed');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('ModelViewerPage: App lifecycle state changed to $state');
    if (state == AppLifecycleState.paused) {
      _handlePageInvisible();
    } else if (state == AppLifecycleState.resumed) {
      _handlePageVisible();
    }
  }

  void _handlePageVisible() {
    if (!_isPageVisible) {
      setState(() {
        _isPageVisible = true;
      });
      print('ModelViewerPage: Page became visible');
    }
  }

  void _handlePageInvisible() {
    if (_isPageVisible) {
      setState(() {
        _isPageVisible = false;
      });
      print('ModelViewerPage: Page became invisible');
    }
  }

  Future<void> prepareModel() async {
    final sourcePath = (Get.arguments as File).path;
    if (!File(sourcePath).existsSync()) return;
    
    setState(() => filePath = sourcePath);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPageVisible) {
      print('ModelViewerPage: Building while invisible');
      return Container();
    }

    print('ModelViewerPage: Building while visible');
    return WillPopScope(
      onWillPop: () async {
        _handlePageInvisible();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('3D Model Viewer'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _handlePageInvisible();
              Get.back();
            },
          ),
          actions: [
            if (filePath != null)
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _isSaving ? null : _saveModel,
              ),
          ],
        ),
        body: filePath == null
            ? const Center(child: CircularProgressIndicator())
            : ModelViewer(
                src: "file://$filePath",
                alt: "3D Model",
                ar: false,
                autoRotate: true,
                cameraControls: true,
                disableZoom: true,
                disablePan: true,
                minCameraOrbit: "auto 70deg 70m",
                maxCameraOrbit: "auto 90deg 70m",
              ),
      ),
    );
  }

  Future<void> _saveModel() async {
    if (filePath == null) return;

    setState(() => _isSaving = true);

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${appDir.path}/models');
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }

      final fileName = path.basename(filePath!);
      final targetPath = '${modelsDir.path}/$fileName';

      // Copy file to app's models directory
      await File(filePath!).copy(targetPath);

      // Save model info to database
      await ModelHelper.getModelUrl(targetPath);

      Get.snackbar(
        'Success',
        'Model saved successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save model: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }
} 