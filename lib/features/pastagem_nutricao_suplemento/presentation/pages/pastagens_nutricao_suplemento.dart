import 'package:costeira/features/pastagem_nutricao_suplemento/presentation/pages/suplementacao/suplementos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../../theme/colors.dart';
import '../../../../../features/auth/presentation/pages/welcome_page.dart';
import 'manejo/manejos.dart';

class PastagensNutricaoSuplemento extends StatefulWidget {
  const PastagensNutricaoSuplemento({super.key});

  @override
  State<PastagensNutricaoSuplemento> createState() => _PastagensNutricaoSuplementoState();
}

class _PastagensNutricaoSuplementoState extends State<PastagensNutricaoSuplemento> {
  void _showModalBottomSheetDesative(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext bc) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8),
                  Opacity(
                    opacity: 0.70,
                    child: Container(
                      width: 72,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFE2E2E2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Icon(Icons.close)],
                    ),
                  ),
                  SizedBox(height: 16),
                  SvgPicture.asset(
                    'icon/desativarvermenho.svg',
                    width: 80,
                    height: 80,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Desativar Conta?",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Text(
                      "Tem certeza que deseja\ndesativar sua conta?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF8692A8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            //  desativeAccount(context);
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text("Sair", style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                            fontSize: 16,
                            color: MyColors.colorOnPrimary,
                            decoration: TextDecoration.underline,
                            decorationColor: MyColors.colorOnPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showModalBottomSheetExit(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext bc) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8),
                  Opacity(
                    opacity: 0.70,
                    child: Container(
                      width: 72,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 2,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFE2E2E2),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [Icon(Icons.close)],
                    ),
                  ),
                  SizedBox(height: 16),
                  SvgPicture.asset('icon/Logout.svg', width: 80, height: 80, color: Colors.red),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Sair do Aplicativo?",
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Text(
                      "Tem certeza que deseja \nsair da sua conta?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Color(0xFF8692A8),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width - 40,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => Teladeinicio()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text("Sair", style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                            fontSize: 16,
                            color: MyColors.colorOnPrimary,
                            decoration: TextDecoration.underline,
                            decorationColor: MyColors.colorOnPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          'Pastagens, Nutrição e Suplem.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              SizedBox(height: 16),

              SizedBox(height: 16),

              Column(
                children: [
                  SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Suplementos()),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 60,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadows: const [
                          BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 0)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 8),
                              const Text(
                                'Suplementação e Consumo',
                                style: TextStyle(
                                  color: Color(0xFF313131),
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.10,
                                ),
                              ),
                            ],
                          ),
                          SvgPicture.asset('icon/Arrow.svg', width: 24, height: 24),
                        ],
                      ),
                    ),
                  ), //Potreiros e Carga Animal
                  // Container(
                  //   // margin: EdgeInsets.symmetric(horizontal: 20),
                  //   width: MediaQuery.of(context).size.width - 40,
                  //   height: 48,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       _showModalBottomSheetExit(context);
                  //     },
                  //     child: Text(
                  //       "Sair",
                  //       style: TextStyle(
                  //         color: MyColors.colorPrimary,
                  //         fontFamily: 'Montserrat',
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.transparent,
                  //       elevation: 0,
                  //       shape: RoundedRectangleBorder(
                  //         side: BorderSide(color: MyColors.colorPrimary),
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Container(
                  //   // margin: EdgeInsets.symmetric(horizontal: 20),
                  //   width: MediaQuery.of(context).size.width - 40,
                  //   height: 48,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       _showModalBottomSheetExit(context);
                  //     },
                  //     child: Text(
                  //       "Sair",
                  //       style: TextStyle(
                  //         color: MyColors.colorPrimary,
                  //         fontFamily: 'Montserrat',
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.transparent,
                  //       elevation: 0,
                  //       shape: RoundedRectangleBorder(
                  //         side: BorderSide(color: MyColors.colorPrimary),
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  // Container(
                  //   // margin: EdgeInsets.symmetric(horizontal: 20),
                  //   width: MediaQuery.of(context).size.width - 40,
                  //   height: 48,
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       _showModalBottomSheetExit(context);
                  //     },
                  //     child: Text(
                  //       "Sair",
                  //       style: TextStyle(
                  //         color: MyColors.colorPrimary,
                  //         fontFamily: 'Montserrat',
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.transparent,
                  //       elevation: 0,
                  //       shape: RoundedRectangleBorder(
                  //         side: BorderSide(color: MyColors.colorPrimary),
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Manejos()));
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 60,
                      padding: const EdgeInsets.all(16),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        shadows: const [
                          BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 0)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 8),
                              const Text(
                                'Manejo de Pastagens',
                                style: TextStyle(
                                  color: Color(0xFF313131),
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.10,
                                ),
                              ),
                            ],
                          ),
                          SvgPicture.asset('icon/Arrow.svg', width: 24, height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
    //  : Column(children: [Center(child: CircularProgressIndicator())],)
    ;
  }
}
