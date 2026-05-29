import 'dart:async';

import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<void> verificUser() async {
    final isLoggedIn = await SessionStorage.isLoggedIn();
    final hasSeenOnboarding = await SessionStorage.hasSeenOnboarding();

    if (!mounted) {
      return;
    }

    if (isLoggedIn) {
      Modular.to.navigate(AppRoutes.appShell);
    } else if (hasSeenOnboarding) {
      Modular.to.navigate(AppRoutes.welcome);
    } else {
      Modular.to.navigate(AppRoutes.onboarding);
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), verificUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/logosplash.png', height: 220, width: 312),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

typedef Splash = SplashPage;
