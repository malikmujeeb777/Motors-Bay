import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:motorsbay1/SRC/Data/AppData/data.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/3DModel/home_model.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Verification/provinces_list_screen.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/Verification/vehicle_verification_page.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/AppFrame/app_frame.dart';
import 'exports.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  developer.log('Handling background message: ${message.messageId}', name: 'Firebase');
  await Firebase.initializeApp();
}

void main() async {
  developer.log('Starting app initialization', name: 'App');
  WidgetsFlutterBinding.ensureInitialized();
  
  developer.log('Setting up Firebase Messaging', name: 'App');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  developer.log('Initializing app data', name: 'App');
  await Data.app.init();
  
  if (Firebase.apps.isNotEmpty) {
    developer.log('Firebase already initialized', name: 'App');
  } else {
    developer.log('Initializing Firebase', name: 'App');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('Firebase initialized successfully', name: 'App');
  }

  // Configure Firebase Auth settings
  developer.log('Configuring Firebase Auth settings', name: 'App');
  await FirebaseAuth.instance.setSettings(
    appVerificationDisabledForTesting: true,
    phoneNumber: null,
    smsCode: null,
  );
  developer.log('Firebase Auth settings configured', name: 'App');

  developer.log('Starting app', name: 'App');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    mediaQueryData = MediaQuery.of(context);
    
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Motors Bay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          // Show confirmation dialog when back button is pressed on Android
          if (didPop) return;
          
          final shouldPop = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Exit Motorsbay?'),
              content: Text('Are you sure you want to exit the app?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Exit'),
                ),
              ],
            ),
          ) ?? false;
          
          if (shouldPop) {
            Navigator.of(context).pop();
          }
        },
        child: AppFrame(),
      ),
      routes: {
        '/provinces_list': (context) => ProvincesListScreen(),
        '/vehicle_verification': (context) => VehicleVerificationPage(
          provinceCode: ModalRoute.of(context)!.settings.arguments as String,
          provinceName: ModalRoute.of(context)!.settings.arguments as String,
        ),
        '/home': (context) => AppFrame(),
      },
      // Add GetX routes
      getPages: [
        GetPage(name: '/3d_models', page: () => HomeModel()),
      ],
    );
  }
}
