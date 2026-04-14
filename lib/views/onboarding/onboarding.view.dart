import 'package:costeira/core/services/location_service.dart';
import 'package:costeira/core/services/notification_permission_service.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/colors.dart';
import '../teladeinicio/teladeinicio.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  final NotificationPermissionService _notificationPermissionService =
      NotificationPermissionService();
  final LocationService _locationService = LocationService();
  int _currentPage = 0;

  final onboardingPages = [
    _OnboardingData(
      image: 'images/Onboarding1.png',
      tag: 'Bem-vindo',
      title: 'Conheça o Costeira',
      subtitle:
          'Reúna todos os dados operacionais,\n financeiros e de produção.',
      buttonText: 'Avançar',
      iconTitle: 'icon/iaicone.svg',
      tipo: 2,
      textOneRow:
          'Reúna todos os dados operacionais,\n financeiros e de produção.',
      iconOneRow: 'icon/hand-coins.svg',
      textTwoRow:
          'Acompanhe o trabalho da sua\n equipe técnica e dos produtores.',
      iconTwoRow: 'icon/workflow.svg',
      textThreeRow:
          'Facilite a tomada de decisão com\n base em dados e análises\n inteligentes.',
      iconThreeRow: 'icon/chart-area.svg',
    ),

    _OnboardingData(
      image: 'images/Onboarding Screen2.png',
      tag: 'Não perca nada',
      title: 'Notificações',
      subtitle:
          'Para garantir que você esteja sempre atualizado, permita as notificações.',
      buttonText: 'Avançar',
      iconTitle: '',
      tipo: 1,
    ),
  ];

  Future<void> _onNext() async {
    if (_currentPage < onboardingPages.length - 1) {
      await _pageController.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    } else {
      await _notificationPermissionService.requestPermission();
      await _locationService.requestPermission();
      await SessionStorage.setOnboardingSeen(true);
      if (!mounted) {
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Teladeinicio()),
      );
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
              return _OnboardingPage(
                data: onboardingPages[index],
                onNext: _onNext,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  final VoidCallback onNext;

  const _OnboardingPage({required this.data, required this.onNext});

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
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).size.height * 0.10,
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
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 16),
                  data.tipo != 2
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(
                              0x1900823A,
                            ) /* pink-100 */,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            spacing: 4,
                            children: [
                              Text(
                                data.tag,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(
                                    0xFF00823A,
                                  ) /* pink-800 */,
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  height: 1.50,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(
                              0x1900823A,
                            ) /* pink-100 */,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            crossAxisAlignment:
                                CrossAxisAlignment.center,
                            spacing: 4,
                            children: [
                              SvgPicture.asset(data.iconTitle!),
                              Text(
                                data.tag,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF00823A),
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  height: 1.50,
                                ),
                              ),
                            ],
                          ),
                        ),
                  SizedBox(height: 16),
                  Text(
                    data.title,
                    style: TextStyle(
                      color: const Color(0xFF313131),
                      fontSize: 24,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      height: 1.50,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  data.tipo != 2
                      ? Text(
                          data.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF8C8C8C),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                            letterSpacing: 0.10,
                          ),
                        )
                      : Column(
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(data.iconOneRow!),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Text(
                                    data.textOneRow!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: const Color(0xFF8C8C8C),
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      height: 1.43,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                SvgPicture.asset(data.iconTwoRow!),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    data.textTwoRow!,
                                    style: TextStyle(
                                      color: const Color(0xFF8C8C8C),
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      height: 1.43,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                SvgPicture.asset(data.iconThreeRow!),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    data.textThreeRow!,
                                    style: TextStyle(
                                      color: const Color(0xFF8C8C8C),
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      height: 1.43,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  SizedBox(height: 28),
                  SizedBox(
                    height: 48,
                    width: MediaQuery.of(context).size.width - 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.colorPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 50,
                        ),
                      ),
                      onPressed: onNext,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            data.buttonText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              height: 1.50,
                            ),
                          ),
                        ],
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
}

class _OnboardingData {
  final String image;
  final String tag;
  final String title;
  final String subtitle;
  final String buttonText;
  int tipo;
  String? iconTitle;
  String? iconOneRow;
  String? textOneRow;
  String? iconTwoRow;
  String? textTwoRow;
  String? iconThreeRow;
  String? textThreeRow;

  _OnboardingData({
    required this.image,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.iconTitle,
    required this.tipo,
    this.iconOneRow,
    this.textOneRow,
    this.iconTwoRow,
    this.textTwoRow,
    this.iconThreeRow,
    this.textThreeRow,
  });
}
