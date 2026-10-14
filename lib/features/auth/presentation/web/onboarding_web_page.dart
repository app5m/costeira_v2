import 'dart:async';

import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_buttons.dart';
import 'package:costeira/core/services/location_service.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/auth/presentation/web/auth_web_frame.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OnboardingWebPage extends StatefulWidget {
  const OnboardingWebPage({super.key});

  @override
  State<OnboardingWebPage> createState() => _OnboardingWebPageState();
}

class _OnboardingWebPageState extends State<OnboardingWebPage> {
  late final LocationService _locationService;
  bool _isRequesting = false;
  String? _blockedMessage;

  @override
  void initState() {
    super.initState();
    _locationService = Modular.get<LocationService>();
  }

  @override
  Widget build(BuildContext context) {
    return AuthWebFrame(
      showBack: false,
      illustrationAsset: 'images/Onboarding1.png',
      illustrationAlignment: Alignment.topCenter,
      title: 'Permita a localização',
      subtitle:
          'Permita a localização para continuar. O navegador só solicita o acesso quando você confirmar.',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LocationTag(),
          const SizedBox(height: 20),
          const _LocationRow(
            icon: 'icon/hand-coins.svg',
            text: 'Reúna todos os dados operacionais, financeiros e de produção.',
          ),
          const SizedBox(height: 16),
          const _LocationRow(
            icon: 'icon/workflow.svg',
            text: 'Acompanhe o trabalho da sua equipe técnica e dos produtores.',
          ),
          if (_blockedMessage != null) ...[
            const SizedBox(height: 20),
            Text(
              _blockedMessage!,
              style: const TextStyle(
                color: Color(0xFF8C8C8C),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrimaryButton(
            label: _blockedMessage == null
                ? 'Permitir localização'
                : 'Tentar novamente',
            isLoading: _isRequesting,
            onPressed: _isRequesting ? null : _requestLocation,
          ),
          if (_blockedMessage != null) ...[
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Continuar',
              onPressed: _isRequesting ? null : _complete,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _requestLocation() async {
    setState(() {
      _isRequesting = true;
    });

    late final LocationRequestResult result;
    try {
      result = await _locationService
          .requestLocationAccess()
          .timeout(const Duration(seconds: 8));
    } on TimeoutException {
      result = LocationRequestResult.failed;
    }
    if (!mounted) {
      return;
    }

    if (result == LocationRequestResult.granted) {
      unawaited(
        _locationService.getCurrentCoordinates().timeout(
          const Duration(seconds: 5),
          onTimeout: () => null,
        ),
      );
      await _complete();
      return;
    }

    setState(() {
      _isRequesting = false;
      _blockedMessage = switch (result) {
        LocationRequestResult.unavailable =>
          'A localização não está disponível neste navegador.',
        LocationRequestResult.denied => 'Permita a localização para continuar.',
        LocationRequestResult.failed => 'Não foi possível obter a localização.',
        LocationRequestResult.granted => null,
      };
    });
  }

  Future<void> _complete() async {
    await SessionStorage.setOnboardingSeen(true);
    if (!mounted) {
      return;
    }
    Modular.to.navigate(AppRoutes.welcome);
  }
}

class _LocationTag extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        decoration: ShapeDecoration(
          color: const Color(0x1900823A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_outlined, size: 14, color: MyColors.colorPrimary),
            SizedBox(width: 4),
            Text(
              'Localização',
              style: TextStyle(
                color: Color(0xFF00823A),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SvgPicture.asset(icon, width: 20, height: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
