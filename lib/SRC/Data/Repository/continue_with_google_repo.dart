// import 'dart:developer';
//
// class ContinueWithGoogleRepo {
//   final GoogleSignIn _googleSignIn = GoogleSignIn();
//
//   Future<Map<String, dynamic>> signInWithGoogle() async {
//     final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//     signOut();
//     try {
//       final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
//       log("The Google Log Response is ${googleUser}");
//       if (googleUser == null) {
//         return {
//           "success": false,
//           "error": "Google sign-in canceled by user.",
//         };
//       }
//
//       final GoogleSignInAuthentication googleAuth =
//       await googleUser.authentication;
//
//
//
//       // log("The Google Auth AccessToke of this application is ${googleAuth.idToken}");
//
//       log("The Response of Google Auth is ${googleAuth.toString()}");
//
//       final AuthCredential credential = await GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       log("The Response of Google Credenditials is ${credential}");
//
//       final UserCredential userCredential =
//       await _firebaseAuth.signInWithCredential(credential);
//       final User? user = userCredential.user;
//       log("The Response of Google user Credentials is ${user}");
//
//       if (user != null) {
//         // ProfileModel? profileModel;
//         // profileModel!.copyWith(
//         //   id: int.parse(user.uid),
//         //   name: user.displayName,
//         //   email: user.email,
//         //   profilePic: user.photoURL,
//         //   token: googleAuth.accessToken??"",
//         // );
//         // Data.app.user = profileModel;
//         SharedPrefs.setLoginToken(googleAuth.accessToken.toString());
//         SharedPrefs.setLogInWithGoogle(true);
//         final data = UserModel(
//           id: user.uid ?? "",
//           name: user.displayName ?? '',
//           email: user.email ?? '',
//           profilePicture: user.photoURL ?? '',
//         );
//         return {
//           "success": true,
//           "usermodel": data,
//         };
//       } else {
//         return {"success": false, "error": "User information is unavailable."};
//       }
//     } catch (e) {
//       log("The Response of this project is ${e.toString()}");
//       return {
//         "success": false,
//         "error": e.toString(),
//       };
//     }
//
//
//   }
//
//   Future<void> signOut() async {
//     final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//     Future.wait([
//       _googleSignIn.signOut(),
//       _firebaseAuth.signOut(),
//       SharedPrefs.clearUserData(),
//     ]);
//
//   }
// }
//
//
//
//
