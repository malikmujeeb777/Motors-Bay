import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Data/AppData/app_preferences.dart';
import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/Auth/Login/login_page.dart';
import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/home_page/home_page.dart';
import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/home_page/main_frame_service_provider.dart';
import 'package:motorsbay1/exports.dart';

class CreateAccountDealer extends StatefulWidget {
  const CreateAccountDealer({super.key});

  @override
  State<CreateAccountDealer> createState() => _CreateAccountDealerState();
}

class _CreateAccountDealerState extends State<CreateAccountDealer> {
  final _formKey = GlobalKey<FormState>();
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

  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController shopNameController = TextEditingController();

  bool isLoading = false;
  bool emailSent = false;
  User? currentUser;

  Future<void> signUpAndSendVerification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      currentUser = userCredential.user;

      if (currentUser != null) {
        // Send email verification
        await currentUser!.sendEmailVerification();

        // Show message to check email
        Get.snackbar(
          "Verify Email",
          "A verification link has been sent to your email. Please verify to continue.",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );

        setState(() {
          emailSent = true; // Show the "Verify Email" button
        });
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Something went wrong",
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> checkEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser; // Fetch latest user instance

    if (user == null) {
      Get.snackbar("Error", "User not found. Please log in again.",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    await user.reload(); // Force refresh user data
    user = FirebaseAuth.instance.currentUser; // Get updated user data

    if (user!.emailVerified) {
      await saveUserData(user.uid);
      Get.snackbar("Success", "Email verified! Account created successfully.",
          backgroundColor: Colors.green, colorText: Colors.white);
      SharedPrefs.setLoginToken(user.uid);
      SharedPrefs.setServiceProvider(isServicePro: true);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MainFrameServiceProvider()));
    } else {
      Get.snackbar("Error", "Email not verified yet. Please check your inbox.",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> saveUserData(String userId) async {
    await FirebaseFirestore.instance.collection('dealers').doc(userId).set({
      'email': emailController.text.trim(),
      'phone': phoneController.text.trim(),
      'name': nameController.text.trim(),
      'address': addressController.text.trim(),
      'shopName': shopNameController.text.trim(),
      'uid': userId,
      'deviceToken' : deviceToken,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dealer Sign Up"), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? "Enter a valid email" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => value!.length < 6 ? "Password must be at least 6 characters" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Name", border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? "Enter your name" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: "Phone Number", border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                  validator: (value) => value!.length < 10 ? "Enter a valid phone number" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: addressController,
                  decoration: InputDecoration(labelText: "Address", border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? "Enter your address" : null,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: shopNameController,
                  decoration: InputDecoration(labelText: "Shop Name", border: OutlineInputBorder()),
                  validator: (value) => value!.isEmpty ? "Enter your shop name" : null,
                ),
                SizedBox(height: 20),

                // Sign Up Button
                if (!emailSent)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : signUpAndSendVerification,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),

                // Verify Email Button
                if (emailSent)
                  Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        "Check your email for a verification link. Click below once verified.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: checkEmailVerification,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text("Verify Email", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                40.y,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an Account"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ServiceProviderLogin()));
                      },
                      child: Text("Login"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
