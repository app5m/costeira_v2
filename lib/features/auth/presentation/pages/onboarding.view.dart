import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/services/location_service.dart';
import 'package:costeira/core/services/notification_permission_service.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../theme/colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController(initialPage: 0);
  final NotificationPermissionService _notificationPermissionService =
      NotificationPermissionService();
  final LocationService _locationService = LocationService();
  int _currentPage = 0;

  final onboardingPages = [
    _OnboardingData(
      image: 'images/Onboarding1.png',
      tag: 'Bem-vindo',
      title: 'Conheça o Costeira',
      subtitle: 'Reúna todos os dados operacionais,\n financeiros e de produção.',
      buttonText: 'Avançar',
      iconTitle: 'icon/circle-star.svg',
      tipo: 2,
      textOneRow: 'Reúna todos os dados operacionais,\n financeiros e de produção.',
      iconOneRow: 'icon/hand-coins.svg',
      textTwoRow: 'Acompanhe o trabalho da sua\n equipe técnica e dos produtores.',
      iconTwoRow: 'icon/workflow.svg',
      textThreeRow: 'Facilite a tomada de decisão com\n base em dados e análises\n inteligentes.',
      iconThreeRow: 'icon/chart-area.svg',
    ),
    _OnboardingData(
      image: 'images/Onboarding Screen2.png',
      tag: 'Não perca nada',
      title: 'Notificações',
      subtitle: 'Para garantir que você esteja sempre atualizado, permita as notificações.',
      buttonText: 'Avançar',
      iconTitle: '',
      tipo: 1,
    ),
  ];

  Future<void> _onNext() async {
    if (_currentPage < onboardingPages.length - 1) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    } else {
      await _notificationPermissionService.requestPermission();
      await _locationService.requestPermission();
      await SessionStorage.setOnboardingSeen(true);
      if (!mounted) {
        return;
      }
      Modular.to.navigate(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingPages.length,
            onPageChanged: (value) {
              setState(() {
                _currentPage = value;
              });
            },
            itemBuilder: (context, index) {
              return _OnboardingStep(data: onboardingPages[index], onNext: _onNext);
            },
          ),
        ],
      ),
    );
  }
}

class _OnboardingStep extends StatelessWidget {
  const _OnboardingStep({required this.data, required this.onNext});

  final _OnboardingData data;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: Image.asset(
                data.image,
                width: double.infinity,
                height:
                    MediaQuery.of(context).size.height - MediaQuery.of(context).size.height * 0.10,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: data.tipo != 2
                ? MediaQuery.of(context).size.height * 0.7
                : MediaQuery.of(context).size.height * 0.55,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: 360,
              height: 437,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  _buildTag(),
                  const SizedBox(height: 16),
                  Text(
                    data.title,
                    style: const TextStyle(
                      color: Color(0xFF313131),
                      fontSize: 24,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  data.tipo != 2 ? _buildSubtitle() : _buildFeatureList(),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 48,
                    width: MediaQuery.of(context).size.width - 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.colorPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
                      ),
                      onPressed: onNext,
                      child: Text(
                        data.buttonText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag() {
    final label = Text(
      data.tag,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF00823A),
        fontSize: 12,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w500,
        height: 1.50,
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: ShapeDecoration(
        color: const Color(0x1900823A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (data.tipo == 2 && data.iconTitle != null) ...[
            SvgPicture.asset(data.iconTitle!),
            const SizedBox(width: 4),
          ],
          label,
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      data.subtitle,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFF8C8C8C),
        fontSize: 14,
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.w400,
        height: 1.50,
        letterSpacing: 0.10,
      ),
    );
  }

  Widget _buildFeatureList() {
    return Column(
      children: [
        _buildFeatureRow(data.iconOneRow!, data.textOneRow!),
        const SizedBox(height: 20),
        _buildFeatureRow(data.iconTwoRow!, data.textTwoRow!),
        const SizedBox(height: 20),
        _buildFeatureRow(data.iconThreeRow!, data.textThreeRow!),
      ],
    );
  }

  Widget _buildFeatureRow(String icon, String text) {
    return Row(
      children: [
        SvgPicture.asset(icon),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              height: 1.43,
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingData {
  _OnboardingData({
    required this.image,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.tipo,
    this.iconTitle,
    this.iconOneRow,
    this.textOneRow,
    this.iconTwoRow,
    this.textTwoRow,
    this.iconThreeRow,
    this.textThreeRow,
  });

  final String image;
  final String tag;
  final String title;
  final String subtitle;
  final String buttonText;
  final int tipo;
  final String? iconTitle;
  final String? iconOneRow;
  final String? textOneRow;
  final String? iconTwoRow;
  final String? textTwoRow;
  final String? iconThreeRow;
  final String? textThreeRow;
}

typedef OnboardingScreen = OnboardingPage;
