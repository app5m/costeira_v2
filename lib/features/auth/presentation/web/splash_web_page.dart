import 'dart:async';

import 'package:costeira/app/app_route_data.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class SplashWebPage extends StatefulWidget {
  const SplashWebPage({super.key});

  @override
  State<SplashWebPage> createState() => _SplashWebPageState();
}

class _SplashWebPageState extends State<SplashWebPage> {
  @override
  void initState() {
    super.initState();
    unawaited(_resolveInitialRoute());
  }

  Future<void> _resolveInitialRoute() async {
    final isLoggedIn = await SessionStorage.isLoggedIn();
    final pendingApproval = await SessionStorage.getWebPendingApproval();
    final hasSeenOnboarding = await SessionStorage.hasSeenOnboarding();

    if (!mounted) {
      return;
    }

    if (isLoggedIn) {
      Modular.to.navigate(AppRoutes.appShell);
      return;
    }
    if (pendingApproval != null) {
      Modular.to.navigate(
        AppRoutes.pendingApproval,
        arguments: PendingApprovalRouteData(
          message: pendingApproval['message'],
          email: pendingApproval['email'],
        ),
      );
      return;
    }
    Modular.to.navigate(
      hasSeenOnboarding ? AppRoutes.welcome : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('images/logosplash.png', width: 312, height: 220),
      ),
    );
  }
}
