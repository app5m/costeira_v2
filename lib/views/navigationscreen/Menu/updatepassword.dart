import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';


// import 'package:provider/provider.dart';
//
// import '../../../../config/constants.dart';
// import '../../../../config/preferences.dart';
// import '../../../../config/requests.dart';
import '../../../theme/colors.dart';



class UpdatePassword extends StatefulWidget {
  const UpdatePassword({super.key});

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  TextEditingController? passwordController;
  TextEditingController? coPasswordController;
  String password = '';
  String passwordConfig = '';
  bool hasPasswordCoPassword = false;
  bool hasUppercase = false;
  bool hasMinLength = false;
  bool visibileOne = false;
  bool visibileTwo = false;
  bool isLoading = false;
  bool _obscureText = true;

  // final requestsWebServices = RequestsWebServices(WSConstantes.URLBASE);
  //
  // Future<String?> updatePassword(String password, BuildContext context) async {
  //   await Preferences.init();
  //   var _userId = await Preferences.getUserData()!.id;
  //   setState(() {
  //     isLoading = true;
  //   });
  //
  //
  //
  //   try {
  //     final body = {
  //       WSConstantes.ID: _userId,
  //       WSConstantes.PASSWORD: password,
  //       WSConstantes.TOKENID: WSConstantes.TOKEN
  //     };
  //
  //     final response = await requestsWebServices.sendPostRequest(
  //         WSConstantes.UPDATE_PASSWORD, body);
  //     final decodedResponse = jsonDecode(response);
  //     if (decodedResponse.isNotEmpty) {
  //       var msg = decodedResponse[0]['msg'];
  //       var status = decodedResponse[0]['status'];
  //
  //       if (status == '01') {
  //         setState(() {
  //           Fluttertoast.showToast(
  //             msg: msg,
  //             toastLength: Toast.LENGTH_SHORT,
  //             gravity: ToastGravity.BOTTOM,
  //           );
  //         });
  //
  //
  //         Navigator.pop(context);
  //
  //       } else {
  //         setState(() {
  //           Fluttertoast.showToast(
  //             msg: msg,
  //             toastLength: Toast.LENGTH_SHORT,
  //             gravity: ToastGravity.BOTTOM,
  //           );
  //         });
  //
  //
  //       }
  //
  //       setState(() {
  //         isLoading = false;
  //       });
  //
  //
  //     }
  //   } on Exception catch (e) {
  //     isLoading = false;
  //
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //
  //
  //   }
  // }

  @override
  Widget build(BuildContext context) {

    final double buttonWidth = MediaQuery.of(context).size.width - 40;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFF1B7A45),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);

            },
            color: Colors.white,
          ),
          title: Text(
            'Alterar Senha',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),

        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Column(
                children: [
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(children: [Text(
                      'Insira sua senha atual e a nova para\nefetuar a alteração',
                      style: TextStyle(
                        color: const Color(0xFF8C8C8C),
                        fontSize: 14,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                        letterSpacing: 0.10,
                      ),
                    ),],),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Senha',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                height:
                                MediaQuery.of(context).size.height < 630
                                    ? 50
                                    : 55,
                                child: TextFormField(
                                  style: TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      password = value;
                                      visibileOne = true;
                                      hasMinLength = password.length >= 8;
                                      hasUppercase =
                                          password.contains(RegExp(r'[A-Z]'));
                                      if (hasMinLength && hasUppercase) {
                                        visibileOne = false;
                                      }
                                    });
                                  },
                                  cursorColor: MyColors.colorPrimary,
                                  controller: passwordController,
                                  // controller: _textEditingController lembra de tirar const,
                                  keyboardType: TextInputType.emailAddress,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    //  focusColor: MyColors.colorborderFormClick,
                                      hintStyle: TextStyle(
                                        color: Color(0x31313131),
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      hintText: 'Digite a nova senha',
                                      filled: true,
                                      fillColor: Color(0xFFEBEBEB),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                          Colors.transparent, // Cor da borda em foco
                                        ),

                                        borderRadius: BorderRadius.all(Radius.circular(
                                            4.0)), // Raio de curvatura das bordas
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(
                                            4.0)), // Raio de curvatura das bordas
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          //   color: MyColors.colorborderForm,
                                          // Cor das bordas quando não está em foco
                                          width: 0.5, // Largura das bordas
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(
                                            4.0)), // Raio de curvatura das bordas
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                        icon: Icon(
                                          _obscureText
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.grey, // Cor do ícone
                                        ),
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Column(
                            children: [
                              Visibility(
                                visible: password.isNotEmpty,
                                child: Row(
                                  children: [
                                    Icon(
                                      hasMinLength
                                          ? Icons.check_circle
                                          : Icons.check_circle,
                                      color: hasMinLength
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    Text(
                                      'Deve ter no mínimo 8 carácteres',
                                      style: TextStyle(
                                          color: MyColors.colorPrimary2),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: password.isNotEmpty,
                                child: Row(
                                  children: [
                                    Icon(
                                      hasUppercase
                                          ? Icons.check_circle
                                          : Icons.check_circle,
                                      color: hasUppercase
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                    Text(
                                      'Deve ter uma letra maiúscula',
                                      style: TextStyle(
                                          color: MyColors.colorPrimary2),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Repita a senha',
                                    style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Container(
                                height:
                                MediaQuery.of(context).size.height < 630
                                    ? 50
                                    : 55,
                                child: TextFormField(
                                  style: TextStyle(
                                    color: Color(0xFF000000),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      visibileTwo = true;
                                      passwordConfig = value;
                                      hasPasswordCoPassword =
                                          passwordConfig == password;

                                      if (hasPasswordCoPassword) {
                                        visibileTwo = false;
                                      }
                                    });
                                  },
                                  cursorColor: MyColors.colorPrimary,
                                  obscureText: true,
                                  controller: coPasswordController,
                                  // controller: _textEditingController lembra de tirar const,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    //  focusColor: MyColors.colorborderFormClick,
                                      hintStyle: TextStyle(
                                        color: Color(0x31313131),
                                        fontSize: 14,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      hintText: 'Repita a nova senha',
                                      filled: true,
                                      fillColor: Color(0xFFEBEBEB),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color:
                                          Colors.transparent, // Cor da borda em foco
                                        ),

                                        borderRadius: BorderRadius.all(Radius.circular(
                                            4.0)), // Raio de curvatura das bordas
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.transparent,
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(
                                            4.0)), // Raio de curvatura das bordas
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                          //   color: MyColors.colorborderForm,
                                          // Cor das bordas quando não está em foco
                                          width: 0.5, // Largura das bordas
                                        ),
                                        borderRadius: BorderRadius.all(Radius.circular(
                                            4.0)), // Raio de curvatura das bordas
                                      ),
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscureText = !_obscureText;
                                          });
                                        },
                                        icon: Icon(
                                          _obscureText
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.grey, // Cor do ícone
                                        ),
                                      )),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Visibility(
                            visible: passwordConfig.isNotEmpty,
                            child: Row(
                              children: [
                                Icon(
                                  hasPasswordCoPassword
                                      ? Icons.check_circle
                                      : Icons.check_circle,
                                  color: hasPasswordCoPassword
                                      ? Colors.green
                                      : Colors.grey,
                                ),
                                Text(
                                  'As senhas fornecidas são idênticas',
                                  style:
                                  TextStyle(color: MyColors.colorPrimary2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          // Barra animada de progresso preenchendo o botão
                          AnimatedContainer(
                            duration: Duration(milliseconds: 500),
                            width: buttonWidth * progress,
                            height: 48,
                            decoration: BoxDecoration(
                              color: MyColors.colorPrimary2, // Amarelo estilo Mercado Livre
                              borderRadius: BorderRadius.circular(64),
                            ),
                          ),
                          SizedBox(
                            width: buttonWidth,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () async {

                                setState(() {
                                  isLoading = true;
                                });

                                // Simula progresso
                                await Future.delayed(Duration(milliseconds: 800));
                                setState(() => progress = 0.6);

                                await Future.delayed(Duration(milliseconds: 800));
                                setState(() => progress = 1.0);

                                if (hasPasswordCoPassword) {
                                  // await updatePassword(password, context);
                                }
                                else if (!hasPasswordCoPassword) {
                                  setState(() {
                                    // Fluttertoast.showToast(
                                    //   msg: "As senhas precisar ser igual",
                                    //   toastLength: Toast.LENGTH_SHORT,
                                    //   gravity: ToastGravity.BOTTOM,
                                    // );
                                  });
                                }
                                else {
                                  setState(() {
                                    // Fluttertoast.showToast(
                                    //   msg: "Senha não preenchida",
                                    //   toastLength: Toast.LENGTH_SHORT,
                                    //   gravity: ToastGravity.BOTTOM,
                                    // );
                                  });
                                }

                                setState(() {
                                  isLoading = false;
                                  progress = 0;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 6, // Mantém sombra de elevação
                                shadowColor: Colors.black,
                                backgroundColor: Colors.transparent, // fundo transparente para mostrar o gradiente
                                minimumSize: Size(double.infinity, 48),
                                padding: EdgeInsets.zero, // Gradiente cobre toda área
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(64),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF1B7A45), Color(0xFF1B7A45)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  height: 48,
                                  child: Text(
                                    'Enviar',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      height: 1.50,
                                    ),
                                  )
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  double progress = 0; // valor de 0 até 1

}
