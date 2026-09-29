import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motorsbay1/exports.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscureCurrent = true;
  bool _isObscureNew = true;
  bool _isObscureConfirm = true;
  bool _isLoading = false; // Loading state

  void _changePassword() async {
    if (_isLoading) return; // Prevent multiple clicks
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No user logged in! Please log in again.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true); // Show loading

    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();

    try {
      // Reauthenticate user before changing password
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password changed successfully!')),
      );

      // Optionally clear fields
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred";

      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = "Current password is incorrect. Please try again.";
      } else if (e.code == 'weak-password') {
        errorMessage = "New password is too weak. Please use a stronger password.";
      } else if (e.code == 'requires-recent-login') {
        errorMessage = "Session expired! Please log in again and retry.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() => _isLoading = false); // Hide loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Current Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildPasswordField(_currentPasswordController, "Enter current password", _isObscureCurrent, () {
                    setState(() => _isObscureCurrent = !_isObscureCurrent);
                  }),
                  SizedBox(height: 20),
                  Text("New Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildPasswordField(_newPasswordController, "Enter new password", _isObscureNew, () {
                    setState(() => _isObscureNew = !_isObscureNew);
                  }),
                  SizedBox(height: 20),
                  Text("Confirm Password", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildPasswordField(_confirmPasswordController, "Confirm new password", _isObscureConfirm, () {
                    setState(() => _isObscureConfirm = !_isObscureConfirm);
                  }),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blue,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white) // Show loader
                          : Text("Change Password", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hint, bool isObscure, VoidCallback toggleVisibility) {
    return TextFormField(
      controller: controller,
      obscureText: isObscure,
      validator: Validate.password,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(isObscure ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
