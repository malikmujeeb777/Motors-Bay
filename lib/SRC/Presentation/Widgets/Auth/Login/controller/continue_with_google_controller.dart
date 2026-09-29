import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:motorsbay1/SRC/Data/AppData/app_preferences.dart';

import 'package:motorsbay1/exports.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContinueWithGoogleController {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> continueWithGoogle(BuildContext context) async {
    // Show loading indicator
    CommonCircularProgressIndicator.show(context);

    try {
      // Trigger Google sign-in
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print("Google sign-in was cancelled.");
        showCustomSnackBar(context, "Sign-in was cancelled", isSuccess: false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      // Create a Firebase credential using Google credentials
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      // Sign in to Firebase with the Google credentials
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Store user data in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'displayName': userCredential.user!.displayName,
        'email': userCredential.user?.email,
        'createdAt': DateTime.now(),
        'uid': userCredential.user!.uid,
        'dob': '',
        'gender': '',
        'phone': '',
        'photoUrl': userCredential.user?.photoURL,
      }).then((val) async {
        // Store user data in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('uid', userCredential.user!.uid);
        prefs.setString('displayName', userCredential.user!.displayName ?? '');
        prefs.setString('email', userCredential.user!.email ?? '');
        prefs.setString('photoUrl', userCredential.user!.photoURL ?? '');
        print("The New Login Token Is ${userCredential.user!.uid.toString()}");
        SharedPrefs.setLoginToken(userCredential.user!.uid.toString());
        SharedPrefs.setUserLoginData(userRawData: {
          "email": userCredential.user?.email,
          'phone': '',
          "id" : userCredential.user!.uid,
          'profilePic': userCredential.user!.photoURL,
          'name': userCredential.user!.displayName,
        });
        SharedPrefs.setLogInWithGoogle(true);

        showCustomSnackBar(context, "Account Created Successfully1100", isSuccess: true);
        CommonCircularProgressIndicator.hide(context);

        // Add a small delay before navigating
        await Future.delayed(Duration.zero);
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AppFrame()));
      });
    } catch (error) {
      Navigator.pop(context);
      print("Error during Google sign-in: $error");
      showCustomSnackBar(context, 'Error during Google sign-in: $error', isSuccess: false);
    }
  }

}
