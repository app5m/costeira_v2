import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
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
      routerConfig: Modular.routerConfig,
    );
  }
}
