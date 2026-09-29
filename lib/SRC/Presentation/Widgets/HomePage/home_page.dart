import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/AIChat/ai_chat_screen.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/favourite_screen.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/home_page_widgets/searchBar.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/search.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Verification/provinces_list_screen.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/3DModel/simple_model_viewer.dart';
import 'dart:io';
import 'home_page_widgets/auto_partsList.dart';
import 'home_page_widgets/carBrandList.dart';
import 'home_page_widgets/section_title.dart';

class LandingHomePage extends StatefulWidget {
  @override
  State<LandingHomePage> createState() => _LandingHomePageState();
}

class _LandingHomePageState extends State<LandingHomePage> with WidgetsBindingObserver {
  final RxString selectedCategory = "Cars".obs;
  bool _isPageVisible = true;

  // Helper method to handle navigation with state management
  void _navigateWithStateManagement(BuildContext context, Widget page) {
    _handlePageInvisible();
    Navigator.push(context, MaterialPageRoute(builder: (context) => page))
      .then((_) => _handlePageVisible());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('HomePage: Initialized');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print('HomePage: Disposed');
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('HomePage: App lifecycle state changed to $state');
    if (state == AppLifecycleState.paused) {
      _handlePageInvisible();
    } else if (state == AppLifecycleState.resumed) {
      _handlePageVisible();
    }
  }

  void _handlePageVisible() {
    if (!_isPageVisible) {
      print('HomePage: Becoming visible');
      setState(() {
        _isPageVisible = true;
      });
      _initializePageState();
    }
  }

  void _handlePageInvisible() {
    if (_isPageVisible) {
      print('HomePage: Becoming invisible');
      setState(() {
        _isPageVisible = false;
      });
      _cleanupPageState();
    }
  }

  void _initializePageState() {
    print('HomePage: Initializing page state');
    // Add any initialization logic here
  }

  void _cleanupPageState() {
    print('HomePage: Cleaning up page state');
    // Add any cleanup logic here
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              exit(0); // This will close the app
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPageVisible) {
      print('HomePage: Building while invisible');
      return Container();
    }

    print('HomePage: Building while visible');
    final screenSize = MediaQuery.of(context).size;
    final bool isSmallScreen = screenSize.width < 360;
    final double horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: horizontalPadding, 
              right: horizontalPadding, 
              bottom: 16, 
              top: 15
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                SearchBarSection(
                  onTap: () => _navigateWithStateManagement(context, SearchAdsScreen()),
                ),
                SizedBox(height: 20),
                
                // Quick action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      context: context,
                      icon: Icons.favorite,
                      iconColor: Colors.white,
                      label: 'Favorites',
                      backgroundColor: Colors.red.shade400,
                      width: screenSize.width * 0.42,
                      onTap: () => _navigateWithStateManagement(context, FavoriteListScreen()),
                    ),
                    SizedBox(width: 16),
                    _buildActionButton(
                      context: context,
                      icon: Icons.chat,
                      iconColor: Colors.white,
                      label: 'Ask AI',
                      backgroundColor: Colors.blue.shade400,
                      width: screenSize.width * 0.42,
                      onTap: () => _navigateWithStateManagement(context, const AiChatScreen()),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                
                // Simple Model Viewer
                GestureDetector(
                  onTap: () => _navigateWithStateManagement(context, SimpleModelViewer()),
                  child: SimpleModelViewer(),
                ),
                SizedBox(height: 20),
                
                // Verification container
                GestureDetector(
                  onTap: () => _navigateWithStateManagement(context, ProvincesListScreen()),
                  child: Container(
                    width: double.infinity,
                    height: 150,
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
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/verification.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                SizedBox(height: 24),
                
                // Featured cars section
                _buildSectionHeading(
                  context, 
                  "Featured Cars", 
                  onSeeAllTap: () => _navigateWithStateManagement(context, SearchAdsScreen()),
                ),
                GestureDetector(
                  onTap: () => _navigateWithStateManagement(context, SearchAdsScreen()),
                  child: CarBrandList(),
                ),
                SizedBox(height: 16),
                
                // Service providers section
                _buildSectionHeading(
                  context, 
                  "Service Providers", 
                  onSeeAllTap: () {
                    _handlePageInvisible();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("See all service providers"))
                    ).closed.then((_) => _handlePageVisible());
                  }
                ),
                GestureDetector(
                  onTap: () => _navigateWithStateManagement(context, SearchAdsScreen()),
                  child: ServiceProviders(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to build a consistent section heading
  Widget _buildSectionHeading(BuildContext context, String title, {VoidCallback? onSeeAllTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: LightColorsPalate.primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (onSeeAllTap != null)
            TextButton(
              onPressed: onSeeAllTap,
              child: Text(
                "See All",
                style: TextStyle(
                  color: LightColorsPalate.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  // Helper method to build consistent action buttons
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color backgroundColor,
    required double width,
    required VoidCallback onTap,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: width,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 20),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}















