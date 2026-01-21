//
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../views/teladeinicio/teladeinicio.dart';z
// class Onboarding extends StatefulWidget {
//   const Onboarding({super.key});
//
//   @override
//   State<Onboarding> createState() => _OnboardingState();
// }
//
// class _OnboardingState extends State<Onboarding> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
// backgroundColor:  Color(0xFF1B7A45),
//       body: Stack(
//         children: [
//           PageView.builder(
//             controller: _pageController,
//             itemCount: onboardingItems.length,
//             physics: NeverScrollableScrollPhysics(),
//             onPageChanged: (onPageChanged){
//               setState(() {
//                 _currentPage = onPageChanged;
//               });
//             },
//             itemBuilder: (context, index) {
//               return OnboardingPage(
//                 item: onboardingItems[index],
//                 isLastPage: index == onboardingItems.length - 1,
//               );
//             },
//           ),
//           Positioned(
//             bottom: 50,
//             left: 0,
//             right: 0,
//             child: Column(
//               children: [
//                 Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(3.0),
//                         color: Color(0xffe2e2e2),
//                       ),
//                       width: 68,
//                       child: DotsIndicator(
//                         position: _currentPage,
//                         decorator: DotsDecorator(
//                           activeSize: Size(34, 6),
//                           activeShape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(3.0)
//                           ),
//                           activeColor: MyColors.colorPrimary,
//                           size: Size(34, 6),
//                           shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(3.0)),
//                           spacing: EdgeInsets.all(0),
//                           color: Color(0xffe2e2e2),
//                         ),
//                         dotsCount: onboardingItems.length,
//                       ),
//                     ),
//                   ),
//                 ]),
//                 SizedBox(
//                   height: 16,
//                 ),
//                 Container(
//                   // margin: EdgeInsets.symmetric(horizontal: 20),
//                   width: MediaQuery.of(context).size.width - 40,
//                   height: 56,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       _navigateToNextPage(context, _pageController);
//                     },
//                     child: Text(
//                       _currentPage == 0 ? "Próximo" : "Próximo",
//                       style: TextStyle(color: Colors.white, fontFamily: 'Montserrat', fontWeight: FontWeight.w600,),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: MyColors.colorPrimary,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8), // <-- Radius
//                       ),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//   Future<void> requestNotificationPermissions() async {
//     // TODO: Reativar permissões de notificação futuramente
//     // final PermissionStatus status = await Permission.notification.request();
//     // print(status);
//
//     // Por enquanto, vai direto para a tela inicial
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const Teladeinicio()),
//     );
//   }
//
// }

import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:ichef/views/theme/colors.dart';

import '../../theme/colors.dart';
import '../teladeinicio/teladeinicio.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  final onboardingPages = [

    _OnboardingData(
      image: 'images/Onboarding1.png',
      tag: 'Bem-vindo',
      title: 'Conheça o Costeira',
      subtitle: 'Reúna todos os dados operacionais,\n financeiros e de produção.',
      buttonText: 'Avançar',
      iconTitle: 'icon/iaicone.svg',
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
      subtitle:
          'Para garantir que você esteja sempre atualizado, permita as notificações.',
      buttonText: 'Avançar',
      iconTitle: '',
      tipo: 1,
    ),


  ];

  void _onNext() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 400),
        curve: Curves.ease,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Teladeinicio()),
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
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).size.height * 0.10,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: data.tipo != 2
                ? MediaQuery.of(context).size.height * 0.6
                : MediaQuery.of(context).size.height * 0.55,
            left: 0,
            right: 0,
            bottom: 0,
            child:
            Container(
              width: 360,
              height: 437,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                            color: const Color(0x1900823A) /* pink-100 */,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 4,
                            children: [
                              Text(
                                data.tag,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF00823A) /* pink-800 */,
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
                            color: const Color(0x1900823A) /* pink-100 */,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 4,
                            children: [
                              SvgPicture.asset(data.iconTitle),
                              Text(
                                data.tag,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: const Color(0xFF00823A) /* pink-800 */,
                                  fontSize: 12,
                                  fontFamily: 'Inter',
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
                            fontSize: 18,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
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
                  Container(
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
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.white,
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
  String iconTitle;
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
    required this.iconTitle,
    required this.tipo,
    this.iconOneRow,
    this.textOneRow,
    this.iconTwoRow,
    this.textTwoRow,
    this.iconThreeRow,
    this.textThreeRow,
  });
}
