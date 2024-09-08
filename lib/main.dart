import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'navigation.dart';

// Background message handler for Firebase Cloud Messaging
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Set up the background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request permission for iOS devices to receive notifications
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  // Get the FCM token for the device
  String? token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    print("FCM Token: $token");
  } else {
    print("FCM Token is null");
  }

  // Check if the app was launched from a notification
  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print("App launched from notification: ${initialMessage.messageId}");
  }

  // Simulate a splash screen delay
  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    // Listen for foreground messages (when the app is open and running)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a message while in the foreground:");
      print("Message data: ${message.data}");

      if (message.notification != null) {
        print("Notification: ${message.notification!.title} - ${message.notification!.body}");
      }
    });

    // Listen for messages when the app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("onMessageOpenedApp triggered: $message");
      // Handle app navigation or other actions based on the notification
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Based Notification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: Navigation.generateRoute,
      initialRoute: '/',
    );
  }
}
