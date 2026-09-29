import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Data/AppData/app_preferences.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Auth/Login/login_on_board.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/HomePage/MyLibrary/my_library.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/profilePage/controller/editController.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Common/gear_loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:motorsbay1/SRC/Data/Resources/Colors/light_color_palate.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/3DModel/my_models_screen.dart';

import 'manageAccountPage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final EditProfileController controller = Get.put(EditProfileController());
  bool _isLoggingOut = false;
  
  // Local path to the default avatar
  final String defaultAvatarPath = 'assets/images/profile_placeholder.png';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    controller.fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Obx(() {
            if (controller.isNameLoading.value) {
              return const Center(child: GearLoading());
            } else {
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 40),
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: controller.photoUrl.value.isEmpty
                            ? AssetImage(defaultAvatarPath)
                            : NetworkImage(controller.photoUrl.value + "?t=${DateTime.now().millisecondsSinceEpoch}") as ImageProvider,
                        child: controller.isUploading.value
                            ? const GearLoading(size: 30)
                            : null,
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Text(
                        controller.name.value, // Display user name
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    buildSectionTitle(context, "Personal"),
                    buildListTile(context, Icons.person_outline, "Manage account", () {
                      Get.to(() => ManageAccountScreen());
                    }),
                    buildSectionTitle(context, "Products"),
                    buildListTile(context, Icons.directions_car, "Cars", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyLibrary()),
                      );
                    }),
                    buildListTile(
                      context,
                      Icons.view_in_ar,
                      "My Models",
                      () {
                        Get.to(() => const MyModelsScreen());
                      },
                    ),
                    buildListTile(context, Icons.settings, "Auto parts & accessories", () {}),
                    buildSectionTitle(context, "Support"),
                    buildListTile(context, Icons.help_outline, "Help & Support", () {}),
                    buildListTile(context, Icons.privacy_tip_outlined, "Privacy policy", () {}),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _onLogout(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        child: Text(
                          "Logout",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
          // Show loading indicator while logging out
          if (_isLoggingOut)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: GearLoading(),
              ),
            ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 5),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title section tapped")),
          );
        },
        child: Text(
          title,
          style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget buildListTile(BuildContext context, IconData icon, String text, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
          leading: Icon(icon, color: Colors.black54),
          title: Text(text),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          onTap: onTap
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
          leading: Icon(icon, color: Colors.black54),
          title: Text(title),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
          onTap: onTap
      ),
    );
  }

  Future<void> _onLogout(BuildContext context) async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      Data.app.isGoogle = false;

      // Clear login state from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isLoggedIn", false);
      SharedPrefs.setLoginToken('');
      SharedPrefs.clearUserData();

      // Navigate back to Login Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginOnBoard()),
      );
    } catch (e) {
      // Handle any errors that occur during logout
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error during logout: $e")),
      );
    } finally {
      setState(() {
        _isLoggingOut = false;
      });
    }
  }
}
