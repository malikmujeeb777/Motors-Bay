import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Application/Utils/Extensions/extensions.dart';
import 'package:motorsbay1/SRC/Presentation/Common/app_text.dart';
import 'package:motorsbay1/exports.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final bool isNewUser;

  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    required this.isNewUser,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String deviceToken = '';
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    notificationServices.getDeviceToken().then((value) {
      setState(() {
        deviceToken = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              "Enter OTP",
              style: themeData.textTheme.headlineLarge,
            ),
            24.y,
            AppTextField(
              controller: otpController,
              textInputType: TextInputType.number,
              hintText: "Enter OTP",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'OTP is required';
                }
                return null;
              },
            ),
            40.y,
            CommonButton(
              horizontalMargin: 0,
              onTap: _verifyOtp,
              text: "Verify OTP",
            ),
            isLoading ? CircularProgressIndicator() : SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    setState(() {
      isLoading = true;
    });
    String otp = otpController.text.trim();

    if (otp.isEmpty || otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid OTP")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      // Sign in the user with the credential
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("OTP Verified Successfully!")),
        );

        // Handle user creation and Firestore setup if it's a new user
        if (widget.isNewUser) {
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).update({
            'phone': widget.phoneNumber,
            'uid': userCredential.user!.uid,
            'createdAt': DateTime.now(),
            'deviceToken': deviceToken,
          });
        }

        // Navigate to the home screen or dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AppFrame()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
