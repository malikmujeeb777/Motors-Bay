import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:motorsbay1/SRC/Application/Services/Notification/notification_services.dart';
import 'package:motorsbay1/SRC/Data/AppData/app_preferences.dart';
import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/Auth/Register/create_account.dart';
import 'package:motorsbay1/SRC/Presentation/service_provider/widgets/home_page/main_frame_service_provider.dart';

class ServiceProviderLogin extends StatefulWidget {
  const ServiceProviderLogin({super.key});

  @override
  ServiceProviderLoginState createState() => ServiceProviderLoginState();
}

class ServiceProviderLoginState extends State<ServiceProviderLogin> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  NotificationServices notificationServices = NotificationServices();
  String deviceToken = '';

  @override
  void initState() {
    super.initState();
    notificationServices.getDeviceToken().then((value) {
      deviceToken = value;
    });
  }

  Future<void> login() async {
    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      String userId = userCredential.user!.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('dealers').doc(userId).get();

      if (userDoc.exists) {
        // ✅ Update the device token in Firestore
        await FirebaseFirestore.instance.collection('dealers').doc(userId).update({
          'deviceToken': deviceToken,
        });

        SharedPrefs.setLoginToken(userId);
        SharedPrefs.setServiceProvider(isServicePro: true);
        Get.offAll(() => MainFrameServiceProvider());
      } else {
        Get.snackbar("Error", "No dealer account found.",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Login Failed", e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Service Provider Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              ),
              SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "Password", border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Login", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text("Don't Have an Account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateAccountDealer()));
                    },
                    child: Text("Sign Up", style: TextStyle(color: Colors.blue)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
