import 'package:costeira/app/app_module.dart';
import 'package:costeira/app/app_widget.dart';
import 'package:costeira/core/offline/storage/local_storage_initializer.dart';
import 'package:costeira/core/services/push_token_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageInitializer.initialize();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await PushTokenService.instance.initialize();
  runApp(ModularApp(module: AppModule(), child: const MyApp()));
}

class MyApp extends AppWidget {
  const MyApp({super.key});
}
