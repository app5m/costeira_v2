import 'package:costeira/views/navigationscreen/Menu/Modulos/postreiros.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../theme/colors.dart';
import '../../../teladeinicio/teladeinicio.dart';
import '../meusdados.dart';

class protetoresecarga extends StatefulWidget {
  const protetoresecarga({super.key});

  @override
  State<protetoresecarga> createState() => _protetoresecargaState();
}

class _protetoresecargaState extends State<protetoresecarga> {
  //  final requestsWebServices = RequestsWebServices(WSConstantes.URLBASE);

  // Future<String?> desativeAccount(BuildContext context) async {
  //   await Preferences.init();
  //   var _userId = await Preferences.getUserData()!.id;
  //   final user = UserModel();
  //
  //   final body = {
  //     WSConstantes.ID: _userId,
  //     WSConstantes.TOKENID: WSConstantes.TOKEN
  //   };
  //
  //   final response = await requestsWebServices.sendPostRequest(
  //       WSConstantes.DESATIVE_ACCOUNT, body);
  //   final decodedResponse = jsonDecode(response);
  //   if (decodedResponse.isNotEmpty) {
  //     user.status = decodedResponse[0]['status'];
  //     user.msg = decodedResponse[0]['msg'];
  //
  //     if (user.status == "01") {
  //       Fluttertoast.showToast(
  //         msg: user.msg!,
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //       );
  //       await Preferences.clearUserData();
  //
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => TelaDeInicio()),
  //             (Route<
  //             dynamic> route) => false, // Remove todas as hotel anteriores
  //       );
  //     } else {
  //       Fluttertoast.showToast(
  //         msg: user.msg!,
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //       );
  //     }
  //     print('Status ${user.status}, Mensagem: ${user.msg}');
  //   }
  // }
  //
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
        return Container(
          child: Column(
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
                              strokeAlign:
                                  BorderSide.strokeAlignCenter,
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
                          width:
                              MediaQuery.of(context).size.width - 40,
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
                            child: Text(
                              "Sair",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop(false),
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                              fontSize: 16,
                              color: MyColors.colorOnPrimary,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  MyColors.colorOnPrimary,
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
          ),
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
                  SvgPicture.asset(
                    'icon/Logout.svg',
                    width: 80,
                    height: 80,
                    color: Colors.red,
                  ),
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
                            // await Preferences.init();
                            // Preferences.clearUserData();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Teladeinicio(),
                              ),
                              (Route<dynamic> route) =>
                                  false, // Remove todas as telas anteriores
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.red),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            "Sair",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(false),
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

  // UserPerfilCliente? userPerfilCliente;
  // bool not1 = false;
  // bool not2 = false;
  //
  // Future<String?> getUserData(BuildContext context) async {
  //   await Preferences.init();
  //   var _userId = await Preferences.getUserData()!.id;
  //
  //   final body = {
  //     WSConstantes.ID_USER: _userId,
  //     WSConstantes.TOKENID: WSConstantes.TOKEN
  //   };
  //
  //   final response = await requestsWebServices.sendPostRequest(
  //       WSConstantes.PERFIL_USER, body);
  //   final decodedResponse = jsonDecode(response);
  //
  //   if (decodedResponse.isNotEmpty) {
  //
  //     setState(() {
  //       userPerfilCliente = UserPerfilCliente.fromJson(decodedResponse);
  //     });
  //
  //     setState(() {
  //       not1 = userPerfilCliente!.notificacoesConfig![0].chamados == 1;
  //       not2 = userPerfilCliente!.notificacoesConfig![0].novidades == 1;
  //     });
  //
  //
  //   }
  // }

  @override
  void initState() {
    // getUserData(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return // userPerfilCliente != null ?
    Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: 16),

              SizedBox(height: 16),
              // Container(
              //   width: MediaQuery.of(context).size.width - 40,
              //   padding: EdgeInsets.all(16),
              //   decoration: BoxDecoration(
              //     color: Colors.white,
              //     borderRadius: BorderRadius.circular(12),
              //     border: Border.all(
              //       width: 1,
              //       color: const Color(0xFFEBEBEB),
              //     ),
              //   ),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         children: [
              //           Text(
              //             'Premium',
              //             style: TextStyle(
              //               color: const Color(0xFF313131),
              //               fontSize: 16,
              //               fontFamily: 'Poppins',
              //               fontWeight: FontWeight.w600,
              //             ),
              //           ),
              //           Spacer(),
              //           Container(
              //             padding:
              //                 EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              //             decoration: ShapeDecoration(
              //               color: const Color(0x331B7A45),
              //               shape: RoundedRectangleBorder(
              //                 borderRadius: BorderRadius.circular(6.75),
              //               ),),
              //             child: Text(
              //               'Ativo',
              //               style: TextStyle(
              //                 color: const Color(0xFF1B7A45),
              //                 fontSize: 12,
              //                 fontFamily: 'Poppins',
              //                 fontWeight: FontWeight.w600,
              //                 height: 1.17,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 8),
              //       Text(
              //         'R\$14,90/mês',
              //         style: TextStyle(
              //           color: Colors.grey[600],
              //           fontWeight: FontWeight.w600,
              //           fontSize: 16,
              //         ),
              //       ),
              //       SizedBox(height: 12),
              //       Stack(
              //         children: [
              //           Container(
              //             height: 8,
              //             decoration: BoxDecoration(
              //               color: Colors.grey[300],
              //               borderRadius: BorderRadius.circular(4),
              //             ),
              //           ),
              //           Container(
              //             height: 8,
              //             width: 200, // ajuste conforme o progresso
              //             decoration: BoxDecoration(
              //               color: const Color(0xFF1B7A45),
              //               borderRadius: BorderRadius.circular(4),
              //             ),
              //           ),
              //         ],
              //       ),
              //       SizedBox(height: 12),
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text.rich(
              //             TextSpan(
              //               children: [
              //                 TextSpan(
              //                   text: 'Restam',
              //                   style: TextStyle(
              //                     color: const Color(0xFF525252),
              //                     fontSize: 10,
              //                     fontFamily: 'Poppins',
              //                     fontWeight: FontWeight.w600,
              //                   ),
              //                 ),
              //                 TextSpan(
              //                   text: ' ',
              //                   style: TextStyle(
              //                     color: const Color(0xFF525252),
              //                     fontSize: 10,
              //                     fontFamily: 'Poppins',
              //                     fontWeight: FontWeight.w500,
              //                   ),
              //                 ),
              //                 TextSpan(
              //                   text: '27 dias',
              //                   style: TextStyle(
              //                     color: const Color(0xFF8C8C8C),
              //                     fontSize: 10,
              //                     fontFamily: 'Poppins',
              //                     fontWeight: FontWeight.w500,
              //                   ),
              //                 ),
              //               ],
              //             ),
              //             textAlign: TextAlign.right,
              //           ),
              //           Text(
              //             'Válido até 29/10/2025',
              //             style: TextStyle(
              //               color: const Color(0xFF8C8C8C),
              //               fontSize: 10,
              //               fontWeight: FontWeight.w600,
              //               fontFamily: 'Poppins',
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(
              //   height: 16,
              // ),
              Column(
                children: [
                  SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Potreiros(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Container(
                          width: 328,
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFEBEBEB),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 24,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Potreiros',
                                    style: TextStyle(
                                      color: const Color(0xFF313131),
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.10,
                                    ),
                                  ),
                                ],
                              ),
                              SvgPicture.asset(
                                'icon/Arrow.svg',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ),
                      ],
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
                    // onTap: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => MeusDados(),
                    //     ),
                    //   );
                    // },
                    child: Row(
                      children: [
                        SizedBox(width: 8),
                        Container(
                          width: 328,
                          padding: const EdgeInsets.all(16),
                          decoration: ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
                                width: 1,
                                color: Color(0xFFEBEBEB),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            shadows: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 24,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Carga Animal ',
                                    style: TextStyle(
                                      color: const Color(0xFF313131),
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.10,
                                    ),
                                  ),
                                ],
                              ),
                              SvgPicture.asset(
                                'icon/Arrow.svg',
                                width: 24,
                                height: 24,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ), //Clima e Chuvas
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
