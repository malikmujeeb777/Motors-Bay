import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  // Default avatar asset path
  static const String defaultAvatar = 'assets/images/profile_placeholder.png';
  
  var name = ''.obs;
  var phone = ''.obs;
  var email = ''.obs;
  var dob = ''.obs;
  var gender = ''.obs;
  var photoUrl = ''.obs;
  var isUploading = false.obs;
  var isNameLoading = true.obs;

  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      DocumentSnapshot userDoc = await userRef.get();

      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;

        // Use default name if data['displayName'] is null or empty
        name.value = data['displayName']?.isNotEmpty ?? false ? data['displayName'] : 'Default User';

        phone.value = data['phone'] ?? '';
        email.value = data['email'] ?? '';
        dob.value = data['dob'] ?? '';
        gender.value = data['gender'] ?? '';
        
        // Use the Firebase photoUrl if available and valid
        if (data['photoUrl'] != null && data['photoUrl'].toString().isNotEmpty) {
          photoUrl.value = data['photoUrl'];
        } else {
          // Use empty string to indicate we should use the default asset
          photoUrl.value = '';
        }
      } else {
        // Handle case if the document doesn't exist
        name.value = 'Default User';
        phone.value = '';
        email.value = '';
        dob.value = '';
        gender.value = '';
        photoUrl.value = '';
      }
    } catch (e) {
      // On error, use empty photoUrl to trigger default avatar in UI
      photoUrl.value = '';
      Get.snackbar("Error", "Failed to fetch user data: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isNameLoading.value = false; // Set loading to false after fetching
    }
  }

  Future<void> saveUserData() async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'displayName': name.value,
        'phone': phone.value,
        'email': email.value,
        'dob': dob.value,
        'gender': gender.value,
        'photoUrl': photoUrl.value,
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to save user data: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Higher quality for better visibility
        maxWidth: 1000,   // Better resolution for profile pictures
      );
      
      if (pickedFile != null) {
        isUploading.value = true; // Show loading indicator

        // Verify the file exists and is readable
        File imageFile = File(pickedFile.path);
        if (!await imageFile.exists()) {
          throw Exception("Selected image file doesn't exist");
        }

        final fileSize = await imageFile.length();
        print("Selected image size: ${fileSize / 1024} KB");

        String userId = FirebaseAuth.instance.currentUser!.uid;
        
        // Use timestamp to avoid cache issues
        String uniqueFileName = '$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';
        
        print("Creating storage reference for: $uniqueFileName");
        Reference ref = FirebaseStorage.instance.ref().child('profile_images').child(uniqueFileName);
        
        // Clear any existing profile images with similar names (optional cleanup)
        try {
          final existingImages = await FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .listAll();
              
          for (var item in existingImages.items) {
            if (item.name.startsWith(userId) && item.name != uniqueFileName) {
              print("Deleting old profile image: ${item.name}");
              await item.delete();
            }
          }
        } catch (e) {
          print("Error cleaning up old profile images: $e");
        }
        
        // Upload with metadata to indicate image type
        SettableMetadata metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'owner': userId, 'timestamp': DateTime.now().toString()},
        );
        
        // Start upload task
        print("Starting upload task...");
        UploadTask uploadTask = ref.putFile(imageFile, metadata);
        
        // Monitor upload progress
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          print("Upload progress: ${(progress * 100).toStringAsFixed(2)}%");
        });
        
        // Wait for upload to complete
        print("Awaiting upload completion...");
        TaskSnapshot snapshot = await uploadTask;
        
        // Get download URL only after upload is complete
        if (snapshot.state == TaskState.success) {
          print("Upload successful, getting download URL...");
          String downloadUrl = await snapshot.ref.getDownloadURL();
          
          print("Updating Firestore document...");
          // Update Firestore first
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'photoUrl': downloadUrl,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
          
          print("Updating local state...");
          // Then update local state only after Firestore update succeeds
          photoUrl.value = downloadUrl;
          
          // Update UI
          update();
          
          Get.snackbar(
            "Success", 
            "Profile picture updated successfully",
            backgroundColor: Colors.green, 
            colorText: Colors.white,
            duration: Duration(seconds: 2),
          );
        } else {
          throw Exception("Upload failed: ${snapshot.state}");
        }
      }
    } catch (e) {
      print("Error in image picker: $e");
      Get.snackbar(
        "Error", 
        "Failed to upload profile picture: $e", 
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isUploading.value = false; // Always hide loading indicator, even on error
    }
  }
}
