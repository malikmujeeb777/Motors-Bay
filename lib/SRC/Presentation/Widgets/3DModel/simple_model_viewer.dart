import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'home_model.dart';

class SimpleModelViewer extends StatelessWidget {
  const SimpleModelViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Ensures model viewer respects rounded corners
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 3D Model viewer
          SizedBox(
            height: 150,
            width: double.infinity,
            child: ModelViewer(
              src: "assets/models/Ford_GT.glb",
              alt: "3D Model",
              autoRotate: true,
              ar: false,
              autoRotateDelay: 0,
              rotationPerSecond: "40deg",
              cameraControls: true,
              disableZoom: true,
              disablePan: true, // Disable panning
              minCameraOrbit: "auto 70deg 70m",
              maxCameraOrbit: "auto 90deg 70m",
            ),
          ),
          
          // Explore button
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              onPressed: () {
                // Navigate to 3D models page with state management
                Get.offAll(() => const HomeModel(), 
                  opaque: false,
                  fullscreenDialog: true,
                );
              },
              icon: Icon(Icons.view_in_ar, size: 20),
              label: Text(
                'Explore 3D Models',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 