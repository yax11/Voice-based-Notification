import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'navigation.dart';
import 'notification_handler.dart';
import 'variables.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void _handleNotificationAction(RemoteMessage message) {
  if (message.data.containsKey('action')) {
    String action = message.data['action'];
    print('Performing action: $action');
    if (action == 'navigate_to_screen') {
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print("Firebase initialized successfully.");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission();
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }

  await _createNotificationChannel();
  String? token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    print("FCM Token: $token");
  } else {
    print("FCM Token is null");
  }

  RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    print("App launched from notification: ${initialMessage.messageId}");
    _handleNotificationAction(initialMessage);
  }

  await Future.delayed(const Duration(seconds: 3));
  FlutterNativeSplash.remove();

  runApp(MyApp());
}

Future<void> _createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // ID
    'High Importance Notifications', // Title
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

class MyApp extends StatefulWidget {

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationHandler _notificationHandler = NotificationHandler();

  @override
  void initState() {
    super.initState();
    _notificationHandler.initialize();
  }

  void _showNotificationDialog(RemoteNotification notification) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(notification.title ?? 'Notification'),
        content: Text(notification.body ?? 'No content'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Audio Based Notification',
      theme: isDarkMode ? ThemeData.dark() : ThemeData(
        primarySwatch: Colors.yellow,
        brightness: Brightness.light,
      ),
      onGenerateRoute: Navigation.generateRoute,
      initialRoute: '/',
    );
  }
  }
