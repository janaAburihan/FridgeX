import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Notification channel setup
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'fridgex_alerts', // id
  'FridgeX Alerts', // name
  importance: Importance.high,
  description: 'Channel for fridge notifications',
);

Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> sendTokenToServer(String? token) async {
  if (token == null) return;
  try {
    final response = await http.post(
      Uri.parse("http://192.168.10.149:5000/register-device"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"fcm_token": token}),
    );
    print("Sent token to server: ${response.statusCode}");
  } catch (e) {
    print("Failed to send token: $e");
  }
}

Future<void> initializeNotifications() async {
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

  // Setup and initailaize local norifications
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      navigatorKey.currentState?.pushNamed('/door_control_screen');
    },
  );

  // Generate a token for the device and send it to the server
  final fcmToken = await FirebaseMessaging.instance.getToken();
  await sendTokenToServer(fcmToken);
  print("FCM Token: $fcmToken");

  // Request device's permission to recieve notifications
  final settings = await FirebaseMessaging.instance.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('✅ User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
    print('❌ User denied notification permission');
  } else {
    print('⚠️ Permission not determined');
  }

  /**
   * 1. First Case: Foreground State:
   * Used Firebase Messaging (onMessage) to listen for incoming messages, 
   * and flutter_local_notifications to manually display the notification 
   * since FCM does not show it automatically in the foreground.
   */
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('[Foreground] Message received: ${message.messageId}');
    final title = message.notification?.title ?? message.data['title'];
    final body = message.notification?.body ?? message.data['body'];

    if (title != null && body != null) {
      flutterLocalNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'fridgex_alerts',
            'FridgeX Alerts',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
        ),
      );
    } else {
      print('⚠️ No title/body found in message.');
    }
  });

  /**
   * 2. Second Case: Background State
   * Handled automatically by FCM (remote push notifications).
   * The system displays the notification,
   * and FirebaseMessaging.onMessageOpenedApp is triggered when the user taps it.
   */
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('[Background] Notification tapped');
    navigatorKey.currentState?.pushNamed('/door_control_screen');
  });

  /**
  * 3. Third Case: Terminated State
  * Handled automatically by FCM (remote push notifications).
  * When the app is completely closed, tapping the notification
  * launches the app, and FirebaseMessaging.instance.getInitialMessage()
  * returns the message that opened the app.
  */
  FirebaseMessaging.instance.getInitialMessage().then((message) {
    if (message != null) {
      print('[Launch] App launched via notification');
      navigatorKey.currentState?.pushNamed('/door_control_screen');
    }
  });
}
