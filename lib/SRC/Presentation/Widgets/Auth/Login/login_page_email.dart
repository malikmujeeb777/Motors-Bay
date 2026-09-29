import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Data/AppData/app_preferences.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Auth/Registeration/register_email.dart';
import 'package:motorsbay1/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginEmail extends StatefulWidget {
  const LoginEmail({super.key});

  @override
  State<LoginEmail> createState() => _LoginEmailState();
}

class _LoginEmailState extends State<LoginEmail> {
  final _formLoginKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(),
      body: Form(
        key: _formLoginKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    48.y,
                    AppText(
                      'Login with Email',
                      style: themeData.textTheme.headlineLarge
                          ?.copyWith(color: themeData.colorScheme.onBackground),
                    ),
                    AppText(
                      maxLine: 2,
                      'Welcome back! Please enter your email address.',
                      style: themeData.textTheme.bodyMedium,
                    ),
                    30.y,
                    AppTextField(
                      controller: emailController,
                      textInputType: TextInputType.emailAddress,
                      hintText: 'Email',
                      validator: Validate.email,
                      prefixIcon: DynamicAppIconHandler.buildIcon(
                        iconWidth: 24,
                        context: context,
                        svg: "assets/Icons/emailoutlineIcon.svg",
                        iconColor: themeData.colorScheme.tertiary,
                      ),
                    ),
                    20.y,
                    AppTextField(
                      controller: passwordController,
                      textInputType: TextInputType.text,
                      hintText: 'Password',
                      validator: Validate.password,
                      prefixIcon: DynamicAppIconHandler.buildIcon(
                        iconWidth: 24,
                        context: context,
                        svg: "assets/Icons/lockIcon.svg",
                        iconColor: themeData.colorScheme.tertiary,
                      ),
                      isState: true,
                    ),
                    20.y,
                    Row(
                      children: [
                        AppText(
                          'Forgot Password?',
                          style: themeData.textTheme.bodyMedium,
                        ),
                        3.x,
                        AppText(
                          'Reset it',
                          style: themeData.textTheme.bodyMedium
                              ?.copyWith(color: themeData.colorScheme.primary),
                        ).onTapped(onTap: _onForget)
                      ],
                    ),
                    40.y,
                    CommonButton(
                      horizontalMargin: 0,
                      onTap: isLoading ? null : _onLogin,
                      text: isLoading ? 'Loading...' : 'Login',
                    ),
                  ],
                ).padHorizontal(24),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  'Don\'t have an account?',
                  style: themeData.textTheme.bodyLarge,
                ),
                7.x,
                AppText(
                  'Create Account',
                  style: themeData.textTheme.bodyLarge
                      ?.copyWith(color: themeData.colorScheme.primary),
                ).onTapped(onTap: _createOrLoginTap),
              ],
            ),
            (16 + 1.bottomBar).y,
          ],
        ),
      ),
    );
  }

  void _onLogin() async {
    if (_formLoginKey.currentState!.validate()) {
      setState(() => isLoading = true);

      String email = emailController.text.trim();
      String password = passwordController.text.trim();

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if(deviceToken.isEmpty || deviceToken == null || deviceToken == "null" || deviceToken == ""){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Device Token is empty Please Tri Again")),
          );
        }else{
          String uid = userCredential.user!.uid;
          DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(uid);
          DocumentSnapshot userDoc = await userRef.get();

          log("The User Id is ${userDoc.id}");
          String profilePic = userDoc.exists && userDoc['photoUrl'] != null ? userDoc['photoUrl'] : "";
          String name = userDoc.exists && userDoc['displayName'] != null ? userDoc['displayName'] : "User";

          log("The User Id is ${name}");

          await userRef.update({'deviceToken': deviceToken});

          SharedPrefs.setLoginToken(uid);
          SharedPrefs.setUserLoginData(userRawData: {
            'displayName': name,
            'email': email,
            'createdAt': DateTime.now(),
            'uid': uid,
            'dob': '',
            'gender': '',
            'phone': '',
            'photoUrl': profilePic,
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AppFrame()),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.toString()}")),
        );
      }

      setState(() => isLoading = false);
    }
  }

  void _onForget() {
    TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Reset Password"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Enter your email to receive a password reset link."),
              SizedBox(height: 10),
              TextField(
                controller: resetEmailController,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                String email = resetEmailController.text.trim();
                if (email.isNotEmpty) {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Password reset email sent!")),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please enter a valid email.")),
                  );
                }
              },
              child: Text("Send"),
            ),
          ],
        );
      },
    );
  }

  void _createOrLoginTap() {
    Get.to(() => RegisterEmail());
  }
}
