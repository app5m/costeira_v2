import 'package:costeira/core/services/push_token_service.dart';
import 'package:costeira/theme/colors.dart';
import 'package:costeira/views/splsh/splash.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

// class ThemeModel extends ChangeNotifier {
//   ThemeMode _themeMode = ThemeMode.system;
//
//   ThemeMode get themeMode => _themeMode;
//
//   void toggleTheme() {
//     if (_themeMode == ThemeMode.dark) {
//       _themeMode = ThemeMode.light;
//     } else {
//       _themeMode = ThemeMode.dark;
//     }
//     notifyListeners();
//   }
// }

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await PushTokenService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Costeira',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme(
          primary: MyColors.colorPrimary,
          brightness: Brightness.light,
          onPrimary: Colors.white,
          secondary: const Color(0xFFF1F3F4),
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: const Color(0xFFF1F3F4),
          onSurface: const Color(0xFF313131),
        ),

        fontFamily: 'Montserrat',

        // 👇 AQUI ESTÁ O PADRÃO DOS TEXTFORMFIELD
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFEBEBEB),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),

          hintStyle: const TextStyle(color: Color(0xFF313131), fontSize: 14),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFEBEBEB)),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: MyColors.colorPrimary),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
      ),
      home: const Splash(),
    );
  }
}
