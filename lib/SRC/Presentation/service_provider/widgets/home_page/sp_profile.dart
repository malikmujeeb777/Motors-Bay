import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Data/AppData/app_preferences.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Auth/Login/login_on_board.dart';

class SpProfilePage extends StatefulWidget {
  const SpProfilePage({super.key});

  @override
  SpProfilePageState createState() => SpProfilePageState();
}

class SpProfilePageState extends State<SpProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? user;
  bool isLoading = true;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController shopNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    if (user != null) {
      fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('dealers').doc(user!.uid).get();
      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc['name'] ?? '';
          emailController.text = userDoc['email'] ?? '';
          phoneController.text = userDoc['phone'] ?? '';
          addressController.text = userDoc['address'] ?? '';
          shopNameController.text = userDoc['shopName'] ?? '';
          isLoading = false;
        });
      } else {
        Get.snackbar("Error", "User not found in database",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch user data: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> updateUserData() async {
    try {
      await _firestore.collection('dealers').doc(user!.uid).update({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'shopName': shopNameController.text.trim(),
      });
      Get.snackbar("Success", "Profile updated successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    SharedPrefs.setUserData(userRawData: {});
    SharedPrefs.setLoginToken('');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginOnBoard()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: logout,
          )
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField("Name", nameController),
            buildTextField("Email", emailController, enabled: false),
            buildTextField("Phone", phoneController),
            buildTextField("Address", addressController),
            buildTextField("Shop Name", shopNameController),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: updateUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: Text("Update Profile", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        ),
      ),
    );
  }
}
