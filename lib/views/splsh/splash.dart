import 'dart:async';

import 'package:costeira/core/storage/session_storage.dart';
import 'package:flutter/material.dart';

import '../navigationscreen/navigationscreen.dart';
import '../onboarding/onboarding.view.dart';
import '../teladeinicio/teladeinicio.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Future<void> verificUser() async {
    final isLoggedIn = await SessionStorage.isLoggedIn();
    final hasSeenOnboarding = await SessionStorage.hasSeenOnboarding();

    if (!mounted) {
      return;
    }

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavigationScreen()),
      );
    } else if (hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Teladeinicio()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      verificUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('images/logosplash.png', height: 220, width: 312),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
