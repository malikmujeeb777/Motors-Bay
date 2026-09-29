import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Data/AppData/app_preferences.dart';
import 'package:motorsbay1/SRC/Presentation/Common/pin_code_widget.dart';
import 'package:motorsbay1/exports.dart';

class VerifyPhoneOrEmail extends StatefulWidget {
  const VerifyPhoneOrEmail({
    super.key,
    required this.whichTypeVerification,
    this.onComplete,
    this.phone,
    this.email,
  });

  final Function()? onComplete;
  final String whichTypeVerification;
  final String? phone;
  final String? email;

  @override
  State<VerifyPhoneOrEmail> createState() => _VerifyPhoneOrEmailState();
}

class _VerifyPhoneOrEmailState extends State<VerifyPhoneOrEmail> {
  TextEditingController pinCodeController = TextEditingController();
  late String verificationId;
  late FirebaseAuth _auth;
  late PhoneAuthCredential phoneAuthCredential;
  bool isLoading = false;
  int countdown = 60; // Timer countdown value (in seconds)
  Timer? countdownTimer;
  String deviceToken = '';
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    if (widget.whichTypeVerification == 'phonenumber' && widget.phone != null) {
      // Start the phone number verification process
      _sendOtpToPhone();
    }
    notificationServices.getDeviceToken().then((value) {
      setState(() {
        deviceToken = value;
      });
    });
    startCountdown();
  }

  // Start countdown timer
  void startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        countdownTimer?.cancel();
      }
    });
  }

  // Function to send OTP to the phone number
  void _sendOtpToPhone() {
    _auth.verifyPhoneNumber(
      phoneNumber: "+92${widget.phone!}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification or instant verification, automatically sign the user in
        await _auth.signInWithCredential(credential);
        log("Phone verified and user signed in");

          showCustomSnackBar(context, "Account verified and created successfully!");

          // Navigate to the home screen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AppFrame()),
          );

      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle error in verification process
        log("Verification failed: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Phone verification failed: ${e.message}")),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        this.verificationId = verificationId;
        log("OTP sent to ${widget.phone}");
        setState(() {});
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        log("Auto retrieval timeout");

      },
    );
  }

  // Verify OTP
  Future<void> _verifyOtp() async {
    CommonCircularProgressIndicator.show(context);

    try {
      if (pinCodeController.text.isNotEmpty) {
        phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: pinCodeController.text.trim(),
        );

        UserCredential userCredential = await _auth.signInWithCredential(phoneAuthCredential);

        log("User signed in successfully: ${userCredential.user?.uid}");

        // Store user data in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
          'displayName': userCredential.user?.displayName,
          'email': widget.email,
          'phone': widget.phone,
          'createdAt': Timestamp.now(),
          'uid': userCredential.user?.uid,
          'dob': '',
          'gender': '',
          'photoUrl': '',
          'deviceToken': deviceToken,
        });
        SharedPrefs.setLoginToken(userCredential.user!.uid.toString()??'');
        SharedPrefs.setUserLoginData(userRawData: {
          "email": widget.email,
          'phone': widget.phone,
          "id": userCredential.user!.uid,
          'profilePic': userCredential.user!.photoURL,
          'name': userCredential.user!.displayName,
        });
        Navigator.pop(context);
        showCustomSnackBar(context, "Account verified and created successfully!");

        // Navigate to the home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AppFrame()),
        );
        // Call the onComplete callback

      } else {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter the OTP")),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      log("OTP verification failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP verification failed")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    pinCodeController.dispose();
    countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          12.y,
          AppText(
            widget.whichTypeVerification == 'phonenumber'
                ? "Verify Phone"
                : "Verify Email",
            maxLine: 2,
            style: themeData.textTheme.headlineMedium,
          ),
          8.y,
          AppText(
            widget.whichTypeVerification == 'phonenumber'
                ? "Check your phone and input verification code to verify your phone"
                : "Check your email and input verification code to verify your email",
            maxLine: 3,
            style: themeData.textTheme.bodyLarge,
          ),
          100.y,
          PinCodeWidget(controller: pinCodeController),
          40.y,
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  "Did Not Receive",
                  style: themeData.textTheme.bodyLarge,
                ),
                6.x,
                AppText(
                  onTap: countdown == 0 ? () => _sendOtpToPhone() : null,
                  "Resend Code",
                  style: themeData.textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primary),
                ),
                6.x,
                AppText(
                  countdown > 0 ? '00:$countdown' : '00:00',
                  style: themeData.textTheme.bodyLarge!
                      .copyWith(color: themeData.colorScheme.error),
                ),
              ],
            ),
          ),
          36.y,
          CommonButton(
            horizontalMargin: 0,
            onTap: () {
              log("Verifying ${widget.whichTypeVerification}");
              if (widget.whichTypeVerification == 'phonenumber') {
                _verifyOtp(); // Verify OTP for phone number
              }
            },
            text: "Verify",
          ),
        ],
      ).padHorizontal(24),
    );
  }
}
