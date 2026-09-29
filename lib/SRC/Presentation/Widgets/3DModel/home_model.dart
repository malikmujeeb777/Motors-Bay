import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Presentation/Common/common_button.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Comparison/car_comparison_selection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'capture360_view.dart';
import 'model_viewer_page.dart';
import 'my_models_screen.dart';
import 'controller/upload_controller.dart';

class HomeModel extends StatefulWidget {
  const HomeModel({Key? key}) : super(key: key);

  @override
  State<HomeModel> createState() => _HomeModelState();
}

class _HomeModelState extends State<HomeModel> with WidgetsBindingObserver {
  bool _isPageVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _handlePageVisible(); // Ensure the page starts in visible state
    print('HomeModel: Initialized');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _handlePageInvisible(); // Ensure cleanup when leaving
    print('HomeModel: Disposed');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('HomeModel: App lifecycle state changed to $state');
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
      print('HomeModel: Page became visible');
    }
  }

  void _handlePageInvisible() {
    if (_isPageVisible) {
      setState(() {
        _isPageVisible = false;
      });
      print('HomeModel: Page became invisible');
    }
  }

  // Helper method to handle navigation with state management
  void _navigateWithStateManagement(BuildContext context, Widget page) {
    _handlePageInvisible();
    Navigator.push(context, MaterialPageRoute(builder: (context) => page))
      .then((_) => _handlePageVisible());
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPageVisible) {
      print('HomeModel: Building while invisible');
      return Container();
    }

    print('HomeModel: Building while visible');
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return WillPopScope(
      onWillPop: () async {
        _handlePageInvisible(); // Ensure cleanup before leaving
        Get.offAllNamed('/home');
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('3D Models'),
          backgroundColor: LightColorsPalate.backgroundColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _handlePageInvisible(); // Ensure cleanup before leaving
              Get.offAllNamed('/home');
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 12.0 : 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    '3D Models & Car Comparison',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload 3D model files, create your own by capturing 360° photos, or compare cars side by side in 3D.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: LightColorsPalate.tertiaryColor,
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Main feature cards
                  GridView.count(
                    crossAxisCount: screenSize.width > 600 ? 3 : 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildFeatureCard(
                        title: 'Upload 3D File',
                        icon: Icons.file_upload,
                        color: Colors.blue,
                        onTap: () => pick3DModelFile(),
                        context: context,
                      ),
                      _buildFeatureCard(
                        title: 'Capture 360°',
                        icon: Icons.camera_alt,
                        color: Colors.green,
                        onTap: () => startCapture360(),
                        context: context,
                      ),
                      _buildFeatureCard(
                        title: 'My Models',
                        icon: Icons.view_in_ar,
                        color: Colors.orange,
                        onTap: () => _navigateWithStateManagement(context, const MyModelsScreen()),
                        context: context,
                      ),
                      _buildFeatureCard(
                        title: 'Car Comparison',
                        icon: Icons.compare_arrows,
                        color: Colors.red,
                        onTap: () => _navigateWithStateManagement(context, const CarComparisonSelection()),
                        context: context,
                      ),
                      _buildFeatureCard(
                        title: 'AR Viewer',
                        icon: Icons.view_in_ar_outlined,
                        color: Colors.purple,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('AR Viewer feature coming soon'),
                            ),
                          );
                        },
                        context: context,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Info section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need Help?',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Learn how to create stunning 3D models with our step-by-step guide.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pick3DModelFile() async {
    PermissionStatus storageStatus = await Permission.storage.request();
    PermissionStatus manageStatus = await Permission.manageExternalStorage.request();

    if (storageStatus.isGranted || manageStatus.isGranted) {
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          Get.to(() => const ModelViewerPage(), arguments: file)?.then((_) {
            _handlePageVisible();
          });
        } else {
          Get.snackbar('No File', 'You didn\'t pick any file.');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to pick file: $e');
      }
    } else if (storageStatus.isDenied || manageStatus.isDenied) {
      Get.snackbar('Permission Denied', 'Storage permission is required.');
    } else if (storageStatus.isPermanentlyDenied || manageStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> startCapture360() async {
    PermissionStatus cameraStatus = await Permission.camera.request();
    
    if (cameraStatus.isGranted) {
      Get.put(UploadController());
      _navigateWithStateManagement(context, const Capture360View());
    } else if (cameraStatus.isDenied) {
      Get.snackbar(
        'Permission Denied',
        'Camera permission is required for 360° capture.',
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    } else if (cameraStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 