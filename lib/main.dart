import 'package:costeira/theme/colors.dart';
import 'package:costeira/views/splsh/splash.dart';
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

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Localiza Pet',
      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme(
          primary: MyColors.colorPrimary,
          background: const Color(0xFFF1F3F4),
          brightness: Brightness.light,
          onPrimary: Colors.white,
          onBackground: const Color(0xFF313131),
          secondary: const Color(0xFFF1F3F4),
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: const Color(0xFFEBEBEB),
          onSurface: Colors.white,
        ),

        fontFamily: 'Montserrat',

        // 👇 AQUI ESTÁ O PADRÃO DOS TEXTFORMFIELD
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFEBEBEB),

          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 14),

          hintStyle: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
          ),

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
