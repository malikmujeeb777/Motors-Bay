import 'package:flutter/material.dart';

class CommonCircularProgressIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Makes the background transparent
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing the dialog by tapping outside
      builder: (context) => CommonCircularProgressIndicator(),
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}
