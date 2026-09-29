import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

class ApplicationPermissions {
  static final ApplicationPermissions _permissions =
  ApplicationPermissions._internal();
  ApplicationPermissions get permissions => _permissions;

  ApplicationPermissions._internal();
  factory ApplicationPermissions() {
    return _permissions;
  }


  // Future<bool> getLocationPermission() async {
  //   // Check if location services are enabled
  //   bool locationEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!locationEnabled) {
  //     // Notify the user to enable location services
  //     return Future.error('Location services are disabled. Please enable them.');
  //   }
  //
  //   // Check for permissions
  //   LocationPermission permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     // Request permission
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return Future.error('Location permissions are denied.');
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     // Handle denied forever
  //     return Future.error(
  //         'Location permissions are permanently denied. Please enable them from app settings.');
  //   }
  //
  //   // Permissions are granted and location services are enabled
  //   return true;
  // }


  // Future<bool> getLocationPermission() async {
  //   bool locationEnabled;
  //   LocationPermission permission;
  //   locationEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!locationEnabled) {
  //     return Future.error('Location services are disabled.');
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       return false;
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     openAppSettings();
  //     return false;
  //   }
  //   return true;
  // }

  Future<bool> getGalleryPermission() async {
    final status = await Permission.storage.status;

    if (status.isDenied || status.isLimited) {
      final result = await Permission.storage.request();

      if (result.isGranted) {
        print("Gallery (Storage) permission granted.");
        return true;
      } else if (result.isPermanentlyDenied) {
        print("Gallery (Storage) permission permanently denied.");
        openAppSettings();
      } else {
        print("Gallery (Storage) permission denied.");
      }
    } else if (status.isGranted) {
      print("Gallery (Storage) permission already granted.");
      return true;
    }

    return false;
  }

  Future<bool> getCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isDenied || status.isLimited) {
      // Request permission if denied or limited
      final result = await Permission.camera.request();

      if (result.isGranted) {
        print("Camera permission granted.");
        return true;
      } else if (result.isPermanentlyDenied) {
        print("Camera permission permanently denied.");
        openAppSettings(); // Guide the user to the app settings
      } else {
        print("Camera permission denied.");
      }
    } else if (status.isGranted) {
      print("Camera permission already granted.");
      return true;
    }

    return false; // Permission not granted
  }

  Future<void> getNotificationPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User denied permission1234');
      // AppSettings.openAppSettings();
      // openAppSettings();
    }

    // var status = await Permission.notification.status;
    //
    // if (status.isDenied || status.isLimited) {
    //   status = await Permission.notification.request();
    //
    //   if (status.isGranted) {
    //     print("Notification permission granted.");
    //   } else if (status.isPermanentlyDenied) {
    //     print("Notification permission permanently denied.");
    //     openAppSettings();
    //   } else {
    //     print("Notification permission denied.");
    //   }
    // } else if (status.isGranted) {
    //   print("Notification permission already granted.");
    // }
  }


  Future<void> getStorageOrMediaPermission() async {
    var status = await Permission.storage.status;

    if (status.isDenied || status.isLimited) {
      status = await Permission.storage.request();

      if (status.isGranted) {
        print("Storage/Media permission granted.");
      } else if (status.isPermanentlyDenied) {
        print("Storage/Media permission permanently denied.");
        openAppSettings();
      } else {
        print("Storage/Media permission denied.");
      }
    } else if (status.isGranted) {
      print("Storage/Media permission already granted.");
    }
  }

}