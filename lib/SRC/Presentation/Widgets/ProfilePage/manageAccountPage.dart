import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Data/AppData/app_preferences.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/ProfilePage/change_password.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/profilePage/controller/editController.dart';

import 'editProfilePage.dart';

class ManageAccountScreen extends StatelessWidget {
  final bool isGoogleLogin = SharedPrefs.getLogInWithGoogle() ?? false;

  @override
  Widget build(BuildContext context) {
    log("Continue with Google ${isGoogleLogin}");
    log("Continue with Google ${Data.app.isGoogle}");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Manage account",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildListTile(Icons.edit, "Edit profile", (){
              Get.to(()=>EditProfileScreen())?.then((_) {
                // Refresh the controller data when returning from edit profile
                if (Get.isRegistered<EditProfileController>()) {
                  final controller = Get.find<EditProfileController>();
                  controller.fetchUserData();
                }
              });
            }),
            Data.app.isGoogle != true ?buildListTile(Icons.lock_outline, "Change password", (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> ChangePasswordScreen()));
            }) : SizedBox.shrink(),
            Data.app.isGoogle != true ?buildListTile(Icons.delete_outline, "Delete account", () => deleteAccount(context))
                : SizedBox.shrink(),
            
          ],
        ),
      ),
    );
  }

  Widget buildListTile(IconData icon, String text, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(text),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
        onTap: onTap,
      ),
    );
  }

  void deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in!')),
      );
      return;
    }

    // Show confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Account"),
        content: Text("Are you sure you want to permanently delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (!confirmDelete) return;

    try {
      await user.delete(); // Delete user account from Firebase

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Account deleted successfully!')),
      );

      // Navigate to login screen or home page after deletion
      Navigator.pushReplacementNamed(context, '/login'); // Update route as needed

    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred while deleting account";

      if (e.code == 'requires-recent-login') {
        errorMessage = "For security, please log in again before deleting your account.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }


}
}
