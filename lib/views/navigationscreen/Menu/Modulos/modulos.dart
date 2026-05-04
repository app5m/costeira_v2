import 'package:costeira/views/navigationscreen/Menu/Modulos/pastagensnutricaosuplemento/pastagensnutricaosuplemento.dart';
import 'package:costeira/app/app_routes.dart';
import 'package:costeira/views/navigationscreen/Menu/Modulos/sanitarios/sanitarios.dart';
import 'package:costeira/features/tasks/presentation/pages/task_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../theme/colors.dart';
import 'estoquedeinsumos/estoqueinsumos.dart';

class ModulesPage extends StatefulWidget {
  const ModulesPage({super.key});

  @override
  State<ModulesPage> createState() => _ModulesPageState();
}

class _ModulesPageState extends State<ModulesPage> {
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
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          'Módulos',
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
                      Modular.to.pushNamed(AppRoutes.potreirosHub);
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
                                'Potreiros e Carga Animal',
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
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Sanitarios()),
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
                                'Sanitários ',
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
                  ), //Sanitários
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => Clima(),
                      //   ),
                      // );
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
                                'Reprodução ',
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
                  ), //Reprodução
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Modular.to.pushNamed(AppRoutes.climateRain);
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
                                'Clima e Chuvas ',
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
                  ), //Clima e Chuvas

                  SizedBox(height: 16),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => TaskPage()));
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
                                'Tarefas  ',
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
                  ), //Clima e Chuvas

                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Insumos()));
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
                                'Estoque de Insumos  ',
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
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PastagensNutricaoSuplemento()),
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
                                'Pasctagens, Nutrição e Suplem. ',
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
