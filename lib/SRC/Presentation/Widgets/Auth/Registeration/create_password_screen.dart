import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Data/AppData/app_preferences.dart';
import 'package:motorsbay1/exports.dart';
import 'Component/already_have_account.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({
    super.key,
    required this.whichTypeRegistration,
    required this.email,
    required this.phoneNumber,
  });

  final String whichTypeRegistration;
  final String email;
  final String phoneNumber;

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isAccountCreated = false;
  bool _isEmailVerified = false;
  User? _user;
  String deviceToken = '';
  NotificationServices notificationServices = NotificationServices();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.getDeviceToken().then((value){
      setState(() {
        deviceToken = value;
      });
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: Form(
        key: formKey,
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            12.y,
            AppText(
              "Create a Password",
              maxLine: 2,
              style: themeData.textTheme.headlineMedium,
            ),
            8.y,
            AppText(
              "Please Enter Your Password To Verify Your Identity And Enhance Security",
              maxLine: 3,
              style: themeData.textTheme.bodyLarge,
            ),
            100.y,
            AppTextField(
              isState: true,
              obscureText: true,
              prefixIcon: DynamicAppIconHandler.buildIcon(
                iconWidth: 24,
                context: context,
                svg: "assets/Icons/lockIcon.svg",
                iconColor: themeData.colorScheme.tertiary,
              ),
              controller: passwordController,
              textInputType: TextInputType.emailAddress,
              hintText: "Password",
              validator: Validate.password,
            ),
            24.y,
            AppTextField(
              isState: true,
              obscureText: true,
              prefixIcon: DynamicAppIconHandler.buildIcon(
                iconWidth: 24,
                context: context,
                svg: "assets/Icons/lockIcon.svg",
                iconColor: themeData.colorScheme.tertiary,
              ),
              controller: confirmPasswordController,
              textInputType: TextInputType.emailAddress,
              hintText: "Confirm Password",
              validator: (v) {
                return Validate.confirmPassword(v, passwordController.text);
              },
            ),
            24.y,
            if (!_isAccountCreated)
              CommonButton(
                horizontalMargin: 0,
                verticalMargin: 0,
                onTap: _createAccount,
                text: "Create Account",
              ),
            if (_isAccountCreated && !_isEmailVerified)
              CommonButton(
                horizontalMargin: 0,
                verticalMargin: 0,
                onTap: _verifyEmail,
                text: "Verify Email",
              ),
          ],
        ).padHorizontal(24),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: const AlreadyHaveAnAccount(),
      resizeToAvoidBottomInset: false,
    );
  }

  // Method to create user in Firebase Authentication
  Future<void> _createAccount() async {
    try {
      if (formKey.currentState!.validate() &&
          passwordController.text == confirmPasswordController.text) {
        CommonCircularProgressIndicator.show(context);

        // Create a user with email and password
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: widget.email,
          password: passwordController.text.toString(),
        );

        // Send email verification
        await userCredential.user!.sendEmailVerification();

        // Update state to show the "Verify" button
        setState(() {
          _isAccountCreated = true;
          _user = userCredential.user;
        });

        Navigator.pop(context);
        showCustomSnackBar(context, "Verification email sent. Please verify your email.");
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        showCustomSnackBar(context, "The password is too weak.");
      } else if (e.code == 'email-already-in-use') {
        showCustomSnackBar(context, "The email is already in use.");
      } else {
        showCustomSnackBar(context, e.message ?? "An error occurred. Please try again.");
      }
    } catch (e) {
      Navigator.pop(context);
      showCustomSnackBar(context, "An unexpected error occurred. Please try again.");
    }
  }

  // Method to verify email and store user data in Firestore
  Future<void> _verifyEmail() async {
    try {
      CommonCircularProgressIndicator.show(context);

      // Reload the user to check if the email is verified
      await _user!.reload();
      _user = _auth.currentUser;

      if (_user!.emailVerified) {
        // Store user data in Firestore
        await _firestore.collection('users').doc(_user!.uid).set({
          'displayName': _user!.displayName,
          'email': widget.email,
          'createdAt': DateTime.now(),
          'uid': _user!.uid,
          'dob': '',
          'gender': '',
          'phone': widget.phoneNumber,
          'photoUrl': '',
          'deviceToken' : deviceToken,
        });

        SharedPrefs.setLoginToken(_user!.uid.toString());
        SharedPrefs.setUserLoginData(userRawData: {
          "email": widget.email,
          'phone': widget.phoneNumber,
          "id": _user!.uid,
          'profilePic': _user!.photoURL,
          'name': _user!.displayName,
        });

        Navigator.pop(context);
        showCustomSnackBar(context, "Account verified and created successfully!");

        // Navigate to the home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => AppFrame()),
        );
      } else {
        Navigator.pop(context);
        showCustomSnackBar(context, "Email not verified. Please check your inbox.");
      }
    } catch (e) {
      Navigator.pop(context);
      showCustomSnackBar(context, "An error occurred. Please try again.");
    }
  }
}