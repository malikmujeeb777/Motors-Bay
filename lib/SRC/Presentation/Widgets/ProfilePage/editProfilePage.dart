import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/profilePage/controller/editController.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final EditProfileController controller = Get.put(EditProfileController());
  final TextEditingController dobController = TextEditingController();

  // Local path to the default avatar
  final String defaultAvatarPath = 'assets/images/profile_placeholder.png';
  
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              try {
                await controller.saveUserData();
                
                // Force refresh to ensure image updates are applied
                controller.fetchUserData();
                
                Get.snackbar("Profile Updated", "Your profile information has been updated.",
                    backgroundColor: Colors.blue, colorText: Colors.white);
                    
                // Add a slight delay to show feedback to user
                await Future.delayed(Duration(milliseconds: 500));
                
                // Return to previous screen
                Get.back();
              } catch (e) {
                Get.snackbar("Error", e.toString(), backgroundColor: Colors.red, colorText: Colors.white);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              "Save Changes",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
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
          "Edit Profile",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => controller.pickImage(),
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Obx(() => Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: ClipOval(
                        child: controller.isUploading.value
                          ? Center(child: CircularProgressIndicator())
                          : controller.photoUrl.value.isEmpty
                              ? Image.asset(
                                  defaultAvatarPath,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                )
                              : Image.network(
                                  // Add cache-busting query parameter
                                  controller.photoUrl.value + "?v=${DateTime.now().millisecondsSinceEpoch}",
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                  // Force no caching to always get the latest image
                                  cacheWidth: 200,
                                  key: ValueKey("profile_${DateTime.now().millisecondsSinceEpoch}"),
                                  errorBuilder: (context, error, stackTrace) {
                                    print("Error loading profile image: $error");
                                    // On network error, fallback to default image
                                    return Image.asset(
                                      defaultAvatarPath,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / 
                                              loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                      ),
                    )),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              buildEditableTextField(Icons.person_outline, "Name", controller.name),
              buildEditableTextField(Icons.phone, "Phone", controller.phone),
              buildEditableTextField(Icons.email_outlined, "Email", controller.email),
              buildDatePickerField(Icons.calendar_today, "Date of Birth", context),
              buildGenderDropdown(Icons.wc, "Gender"),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Editable Text Field
  Widget buildEditableTextField(IconData icon, String title, RxString value) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: TextEditingController(text: value.value)..selection = TextSelection.collapsed(offset: value.value.length),
                onChanged: (newValue) => value.value = newValue,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter $title",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Date Picker Field (Fixed)
  Widget buildDatePickerField(IconData icon, String title, BuildContext context) {
    return Obx(() {
      dobController.text = controller.dob.value; // Update controller text when value changes
      return Card(
        elevation: 0,
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: dobController,
                  readOnly: true,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: title,
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
                      controller.dob.value = formattedDate;
                      dobController.text = formattedDate; // Update text field
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // 🔹 Gender Dropdown
  Widget buildGenderDropdown(IconData icon, String title) {
    return Obx(() {
      return Card(
        elevation: 0,
        color: Colors.grey[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.gender.value.isNotEmpty ? controller.gender.value : null,
                    hint: Text("Select $title"),
                    isExpanded: true,
                    onChanged: (newValue) {
                      if (newValue != null) controller.gender.value = newValue;
                    },
                    items: ["Male", "Female", "Other"]
                        .map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
