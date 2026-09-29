import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, {bool isSuccess = true}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
    ),
    backgroundColor: isSuccess ? Colors.green : Colors.red, // Green for success, Red for error
    duration: Duration(seconds: 2),
  );

  // Show the snackbar
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
