import 'dart:async';

import 'package:flutter/material.dart';

import '../onboarding/onboarding.view.dart';








class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool isLoggedIn = false;

  Future<void> verificUser() async {
    // await Preferences.init();
    // isLoggedIn = await Preferences.getLogin();

    if (isLoggedIn) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => NavigationScreen(tipo: 1,)));
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
            Image.asset(
              'images/logosplash.png',
              height: 220,
              width: 312,

            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

