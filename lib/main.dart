import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tt9_chat_app_st/screens/chat_screen.dart';
import 'package:tt9_chat_app_st/screens/login_screen.dart';
import 'package:tt9_chat_app_st/screens/registration_screen.dart';
import 'package:tt9_chat_app_st/screens/welcome_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.subscribeToTopic("News");

  runApp(const FlashChat());
}

class FlashChat extends StatelessWidget {
  const FlashChat({super.key});

  void getFcm() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('fcmToken: $fcmToken');
  }

  @override
  Widget build(BuildContext context) {
    getFcm();
    return MaterialApp(
      home: const WelcomeScreen(),
      routes: {
        LoginScreen.id: (context) => const LoginScreen(),
        RegistrationScreen.id: (context) => const RegistrationScreen(),
        ChatScreen.id: (context) => const ChatScreen(),
      },
    );
  }
}
