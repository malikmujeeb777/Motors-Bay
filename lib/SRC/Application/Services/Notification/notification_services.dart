import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:motorsbay1/SRC/Presentation/Widgets/ChatScreen/chat_detail_page.dart';

// Stub classes to simulate flutter_local_notifications functionality
class StubLocalNotificationsPlugin {
  Future<void> initialize(StubInitializationSettings settings, {Function(dynamic)? onDidReceiveNotificationResponse}) async {
    debugPrint('Stub local notifications initialized');
  }

  Future<void> show(int id, String? title, String? body, StubNotificationDetails details) async {
    debugPrint('Would show notification: $title - $body');
  }
}

class StubInitializationSettings {
  final StubAndroidInitializationSettings? android;
  final StubIOSInitializationSettings? iOS;

  const StubInitializationSettings({this.android, this.iOS});
}

class StubAndroidInitializationSettings {
  final String? icon;
  const StubAndroidInitializationSettings(this.icon);
}

class StubIOSInitializationSettings {
  const StubIOSInitializationSettings();
}

class StubNotificationDetails {
  final StubAndroidNotificationDetails? android;
  final StubIOSNotificationDetails? iOS;

  const StubNotificationDetails({this.android, this.iOS});
}

class StubAndroidNotificationDetails {
  final String channelId;
  final String channelName;
  final String? channelDescription;
  final String? sound;

  StubAndroidNotificationDetails(
    this.channelId,
    this.channelName,
    {this.channelDescription, this.sound}
  );
}

class StubIOSNotificationDetails {
  final bool presentAlert;
  final bool presentBadge;
  final bool presentSound;

  const StubIOSNotificationDetails({
    this.presentAlert = true,
    this.presentBadge = true,
    this.presentSound = true,
  });
}

class StubAndroidNotificationChannel {
  final String id;
  final String name;
  final String? description;
  final String? sound;

  StubAndroidNotificationChannel(
    this.id,
    this.name,
    {this.description, this.sound}
  );
}

class NotificationServices {  //initialising firebase message plugin
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  //initialising stub notification plugin
  final StubLocalNotificationsPlugin _localNotificationsPlugin = StubLocalNotificationsPlugin();

  //function to initialise stub local notification plugin
  void initLocalNotifications(BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings = const StubAndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const StubIOSInitializationSettings();

    var initializationSetting = StubInitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings
    );

    await _localNotificationsPlugin.initialize(
        initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
          // handle interaction when app is active for android
          handleMessage(context, message);
        }
    );
  }

  Future<void> setupChatNotifications() async {
    // Stub implementation
  }
  
  // Handle incoming chat messages when the app is opened from a notification
  void handleChatNotification(RemoteMessage message, BuildContext context) {
    if (message.data['type'] == 'chat_message') {
      // Extract chat data
      final String? chatId = message.data['chatId'];
      final String? senderId = message.data['senderId'];
      
      if (chatId != null && senderId != null) {
        // Navigate to specific chat screen
      }
    }
  }

  void firebaseInit(BuildContext context) {
    // Set up chat notifications
    setupChatNotifications();
    
    FirebaseMessaging.onMessage.listen((message) {
      // Process notification data

      if (Platform.isIOS) {
        forgroundMessage();
      }

      if (Platform.isAndroid) {
        initLocalNotifications(context, message);
        showNotification(message);
      }
    });
  }
  void requestNotificationPermission() async {
    // Request permission without checking the result
    await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    
    // Authorization status is processed but not logging to console
  }

  // function to show visible notification when app is active (stub version)
  Future<void> showNotification(RemoteMessage message) async {
    // Create stub notification details
    StubAndroidNotificationDetails androidDetails = StubAndroidNotificationDetails(
      message.notification?.android?.channelId ?? 'default_channel',
      message.notification?.android?.channelId ?? 'Default Channel',
      channelDescription: 'your channel description',
    );

    const StubIOSNotificationDetails iosDetails = StubIOSNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );

    StubNotificationDetails notificationDetails = StubNotificationDetails(
      android: androidDetails,
      iOS: iosDetails
    );

    // Show stub notification
    await _localNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }

  //function to get device token on which we will send the notifications
  Future<String> getDeviceToken() async {
    String? token = await messaging.getToken();
    return token ?? '';
  }

  // Update device token in Firestore
  Future<void> updateDeviceToken(String userId, String token) async {
    if (token.isEmpty || userId.isEmpty) return;
    
    try {
      // Update for regular users
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'deviceToken': token,
      });
    } catch (e) {
      // If updating fails, try the dealers collection
      try {
        await FirebaseFirestore.instance.collection('dealers').doc(userId).update({
          'deviceToken': token,
        });
      } catch (error) {
        debugPrint('Error updating device token: $error');
      }
    }
  }

  void isTokenRefresh() async {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
      // Token refresh event handled
    });
  }

  //handle tap on notification when app is in background or terminated
  Future<void> setupInteractMessage(BuildContext context) async {
    // when app is terminated
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    //when app ins background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'chat_message') {
      // Extract required data from notification
      final String? chatId = message.data['chatId'];
      final String? senderId = message.data['senderId'];
      final String? senderName = message.data['senderName'];
      final String? senderPhoto = message.data['senderPhoto'];
      
      if (chatId != null && senderId != null) {
        // Navigate to the chat screen using the constructor pattern in ConversationScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              receiverId: senderId,
              receiverName: senderName ?? "User",
              receiverImage: senderPhoto ?? "",
            ),
          ),
        );
      }
    }
  }

  Future<void> forgroundMessage() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}
