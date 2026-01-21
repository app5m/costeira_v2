import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';

//
// import '../../componentesDialog/dialog_alert_error.dart';
// import '../../componentesDialog/fonte_size.dart';
import '../../theme/colors.dart';
import '../navigationscreen/navigationscreen.dart';


// import '../../config/constants.dart';
// import '../../config/preferences.dart';
// import '../../config/requests.dart';
// import '../../model/user.dart';
// import '../../theme/colors.dart';
// import '../navigation/navigation.screen.dart';

// import '../componentesDialog/dialog_alert_error.dart';
// import '../componentesDialog/fonte_size.dart';
// import '../config/constants.dart';
// import '../config/preferences.dart';
// import '../config/requests.dart';
// import '../model/user.dart';
// import '../theme/colors.dart';
// import '../views/navigation/navigation.screen.dart';


class ValidationCode extends StatefulWidget {
  final String email;
  final String password;
  final String lat;
  final String long;
  final int tipo;

  ValidationCode({
    super.key,
    required this.email,
    required this.password,
    required this.lat,
    required this.long,
    required this.tipo,
  });

  @override
  State<ValidationCode> createState() => _ValidationCodeState();
}

class _ValidationCodeState extends State<ValidationCode> {
  List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  // Botão com Progress
  bool isLoadingLogin = false;
  bool isLoadingRegistre = false;

  // Future<String?> getFCM(String id) async {
  //   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  //   await Preferences.init();
  //   bool logg = await Preferences.getLogin();
  //
  //
  //
  //
  //   String? savedFcmToken = await Preferences.getInstanceTokenFcm();
  //   //nameUser = (await Preferences.getUserData()!.name)!;
  //   String? currentFcmToken = await _firebaseMessaging.getToken();
  //   if (savedFcmToken != null && savedFcmToken == currentFcmToken) {
  //     print('FCM: não salvou');
  //     return savedFcmToken;
  //   }
  //   var _type = '';
  //   if (Platform.isAndroid) {
  //     _type = WSConstantes.FCM_TYPE_ANDROID;
  //   } else if (Platform.isIOS) {
  //     _type = WSConstantes.FCM_TYPE_IOS;
  //   }
  //   final body = {
  //     WSConstantes.ID_USER: id,
  //     WSConstantes.TYPE: _type,
  //     WSConstantes.REGIST_ID: currentFcmToken,
  //     WSConstantes.TOKENID: WSConstantes.TOKEN
  //   };
  //   final response = await requestsWebServices.sendPostRequest(
  //       WSConstantes.SAVE_FCM, body);
  //
  //   print('FCM: $currentFcmToken');
  //   print('RESPOSTA: $response');
  //
  //   // Salvamos o FCM atual nas preferências.
  //   await Preferences.saveInstanceTokenFcm("token", currentFcmToken!);
  //
  //   return currentFcmToken;
  //
  // }
  String codefull = '';
  // final requestsWebServices = RequestsWebServices(WSConstantes.URLBASE);
  //
  // Future<void> sendCode(
  //     String email, String password, String latitude, String longitude) async {
  //   Preferences.init();
  //   if (validatonLogin(email, password)) {
  //     try {
  //       final body = {
  //         WSConstantes.EMAIL: email,
  //         WSConstantes.PASSWORD: password,
  //         WSConstantes.LATITUDE: latitude,
  //         WSConstantes.LONGITUDE: longitude,
  //         WSConstantes.TOKENID: WSConstantes.TOKEN
  //       };
  //
  //       final response = await requestsWebServices.sendPostRequest(
  //           WSConstantes.DOIS_FATORES, body);
  //
  //       final decodedResponse = jsonDecode(response);
  //
  //       if (decodedResponse is List && decodedResponse.isNotEmpty) {
  //         final userResponse = decodedResponse[0];
  //         final status = userResponse['status'];
  //         final message = userResponse['msg'];
  //
  //         if (status == '01') {
  //           setState(() {
  //             Fluttertoast.showToast(
  //               msg: message,
  //               toastLength: Toast.LENGTH_SHORT,
  //               gravity: ToastGravity.BOTTOM,
  //             );
  //           });
  //         } else if (status == '02') {
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return DialogError(
  //                 title: "Atenção!",
  //                 content: message,
  //                 btnConfirm: TextButton(
  //                     style: TextButton.styleFrom(
  //                         foregroundColor: MyColors.colorPrimary),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text(
  //                       'Voltar',
  //                       style: TextStyle(
  //                         fontSize: FontSizes.subTitulo,
  //                         fontWeight: FontWeight.w600,
  //                         fontFamily: 'Poppins',
  //                       ),
  //                     )),
  //               );
  //             },
  //           );
  //         } else if (status == '03') {
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return DialogError(
  //                 title: "Atenção!",
  //                 content: message,
  //                 btnConfirm: TextButton(
  //                     style: TextButton.styleFrom(
  //                         foregroundColor: MyColors.colorPrimary),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text(
  //                       'Voltar',
  //                       style: TextStyle(
  //                         fontSize: FontSizes.subTitulo,
  //                         fontWeight: FontWeight.w600,
  //                         fontFamily: 'Poppins',
  //                       ),
  //                     )),
  //               );
  //             },
  //           );
  //         } else {
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return DialogError(
  //                 title: "Atenção!",
  //                 content: "Ocorreu um erro durante o login.",
  //                 btnConfirm: TextButton(
  //                     style: TextButton.styleFrom(
  //                         foregroundColor: MyColors.colorPrimary),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text(
  //                       'Voltar',
  //                       style: TextStyle(
  //                         fontSize: FontSizes.subTitulo,
  //                         fontWeight: FontWeight.w600,
  //                         fontFamily: 'Poppins',
  //                       ),
  //                     )),
  //               );
  //             },
  //           );
  //         }
  //       } else {
  //         showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return DialogError(
  //               title: "Atenção!",
  //               content: "Ocorreu um erro durante o login.",
  //               btnConfirm: TextButton(
  //                   style: TextButton.styleFrom(
  //                       foregroundColor: MyColors.colorPrimary),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: Text(
  //                     'Voltar',
  //                     style: TextStyle(
  //                       fontSize: FontSizes.subTitulo,
  //                       fontWeight: FontWeight.w600,
  //                       fontFamily: 'Poppins',
  //                     ),
  //                   )),
  //             );
  //           },
  //         );
  //       }
  //     } catch (e) {
  //       print('Erro durante a requisição: $e');
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return DialogError(
  //             title: "Atenção!",
  //             content: "Erro durante a requisição: $e",
  //             btnConfirm: TextButton(
  //                 style: TextButton.styleFrom(
  //                     foregroundColor: MyColors.colorPrimary),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text(
  //                   'Voltar',
  //                   style: TextStyle(
  //                     fontSize: FontSizes.subTitulo,
  //                     fontWeight: FontWeight.w600,
  //                     fontFamily: 'Poppins',
  //                   ),
  //                 )),
  //           );
  //         },
  //       );
  //     } finally {
  //       setState(() {
  //         isLoadingLogin = false;
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       isLoadingRegistre = false;
  //     });
  //   }
  // }
  //
  // Future<void> loginCode(String email, String password, String codigo) async {
  //   Preferences.init();
  //   if (validatonLogin(email, password)) {
  //     try {
  //       final body = {
  //         WSConstantes.EMAIL: email,
  //         WSConstantes.PASSWORD: password,
  //         WSConstantes.CODE: codigo,
  //         WSConstantes.TOKENID: WSConstantes.TOKEN
  //       };
  //
  //       final response =
  //       await requestsWebServices.sendPostRequest(WSConstantes.LOGIN, body);
  //
  //       final decodedResponse = jsonDecode(response);
  //
  //       if (decodedResponse is List && decodedResponse.isNotEmpty) {
  //         final userResponse = decodedResponse[0];
  //         final status = userResponse['status'];
  //         final message = userResponse['msg'];
  //         //  int userId = userResponse['id'];
  //
  //         if (status == '01') {
  //           int userId = userResponse['id'];
  //           final name = userResponse['nome'];
  //           final apelido = userResponse['apelido'];
  //           final documento = userResponse['documento'];
  //           final email = userResponse['email'];
  //           final phone = userResponse['celular'];
  //
  //           final user = UserModel(
  //               id: userId,
  //               name: name,
  //               email: email,
  //               cellphone: phone,
  //               apelido: apelido,
  //               cpf: documento,
  //               tipo: widget.tipo.toString());
  //
  //           await Preferences.setUserData(user);
  //           await Preferences.setLogin(true);
  //           Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (context) => NavigationScreen(
  //                   )));
  //         } else if (status == '02') {
  //           //
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return DialogError(
  //                 title: "Atenção!",
  //                 content: message,
  //                 btnConfirm: TextButton(
  //                     style: TextButton.styleFrom(
  //                         foregroundColor: MyColors.colorPrimary),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text(
  //                       'Voltar',
  //                       style: TextStyle(
  //                         fontSize: FontSizes.subTitulo,
  //                         fontWeight: FontWeight.w600,
  //                         fontFamily: 'Poppins',
  //                       ),
  //                     )),
  //               );
  //             },
  //           );
  //           // getFCM(userId.toString());
  //
  //         } else if (status == '03') {
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return DialogError(
  //                 title: "Atenção!",
  //                 content: message,
  //                 btnConfirm: TextButton(
  //                     style: TextButton.styleFrom(
  //                         foregroundColor: MyColors.colorPrimary),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text(
  //                       'Voltar',
  //                       style: TextStyle(
  //                         fontSize: FontSizes.subTitulo,
  //                         fontWeight: FontWeight.w600,
  //                         fontFamily: 'Poppins',
  //                       ),
  //                     )),
  //               );
  //             },
  //           );
  //         } else {
  //           showDialog(
  //             context: context,
  //             builder: (BuildContext context) {
  //               return DialogError(
  //                 title: "Atenção!",
  //                 content: "Ocorreu um erro durante o login.",
  //                 btnConfirm: TextButton(
  //                     style: TextButton.styleFrom(
  //                         foregroundColor: MyColors.colorPrimary),
  //                     onPressed: () {
  //                       Navigator.of(context).pop();
  //                     },
  //                     child: Text(
  //                       'Voltar',
  //                       style: TextStyle(
  //                         fontSize: FontSizes.subTitulo,
  //                         fontWeight: FontWeight.w600,
  //                         fontFamily: 'Poppins',
  //                       ),
  //                     )),
  //               );
  //             },
  //           );
  //         }
  //       } else {
  //         showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return DialogError(
  //               title: "Atenção!",
  //               content: "Ocorreu um erro durante o login.",
  //               btnConfirm: TextButton(
  //                   style: TextButton.styleFrom(
  //                       foregroundColor: MyColors.colorPrimary),
  //                   onPressed: () {
  //                     Navigator.of(context).pop();
  //                   },
  //                   child: Text(
  //                     'Voltar',
  //                     style: TextStyle(
  //                       fontSize: FontSizes.subTitulo,
  //                       fontWeight: FontWeight.w600,
  //                       fontFamily: 'Poppins',
  //                     ),
  //                   )),
  //             );
  //           },
  //         );
  //       }
  //     } catch (e) {
  //       print('Erro durante a requisição: $e');
  //       showDialog(
  //         context: context,
  //         builder: (BuildContext context) {
  //           return DialogError(
  //             title: "Atenção!",
  //             content: "Erro durante a requisição: $e",
  //             btnConfirm: TextButton(
  //                 style: TextButton.styleFrom(
  //                     foregroundColor: MyColors.colorPrimary),
  //                 onPressed: () {
  //                   Navigator.of(context).pop();
  //                 },
  //                 child: Text(
  //                   'Voltar',
  //                   style: TextStyle(
  //                     fontSize: FontSizes.subTitulo,
  //                     fontWeight: FontWeight.w600,
  //                     fontFamily: 'Poppins',
  //                   ),
  //                 )),
  //           );
  //         },
  //       );
  //     } finally {
  //       setState(() {
  //         isLoadingLogin = false;
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       isLoadingRegistre = false;
  //     });
  //   }
  // }
  //
  // bool validatonLogin(String email, String password) {
  //   bool validation = false;
  //   if (!validationEmail(email)) {
  //     setState(() {
  //       Fluttertoast.showToast(
  //         msg: WSConstantes.MSG_EMAIL_INVALIDO,
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //       );
  //       isLoadingLogin = false;
  //       validation = false;
  //     });
  //   } else if (password.isEmpty || password.length < 6) {
  //     setState(() {
  //       Fluttertoast.showToast(
  //         msg: WSConstantes.MSG_PASSWORD_INVALIDO,
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //       );
  //       isLoadingLogin = false;
  //       validation = false;
  //     });
  //   } else {
  //     validation = true;
  //   }
  //
  //   return validation;
  // }
  //
  // bool validationEmail(String email) {
  //   final regex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  //   return regex.hasMatch(email);
  // }
  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  String getCodeFromControllers(List<TextEditingController> controllers) {
    String code = '';
    for (var controller in controllers) {
      code += controller.text;
    }
    return code;
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Colors.grey;
    const fillColor = Colors.white;
    const borderColor = Colors.grey;
    final double buttonWidth = MediaQuery.of(context).size.width - 40;
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );
    var widthFull = MediaQuery.of(context).size.width;
    var heightFull = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          Positioned.fill(
            child:Container(height: heightFull, color: MyColors.colorPrimary,),
          ),
          SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              reverse: true, // para subir quando teclado abrir
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: heightFull,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: widthFull,
                        // Usar flexível em height para evitar overflow com teclado
                        constraints: BoxConstraints(
                          maxHeight: heightFull * 0.93,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 32),
                                Row(
                                  children: [
                                    GestureDetector(
                                        onTap: (){
                                          Navigator.pop(context);
                                        },
                                        child: Icon(Icons.arrow_back_ios, color: Colors.black)),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Column(

                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Autenticação',
                                      style: TextStyle(
                                        color: const Color(0xFF313131),
                                        fontSize: 24,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Digite o código enviado para o seu email \n${widget.email}',
                                        style: TextStyle(
                                          color: Color(0xFF8691A8),
                                          fontSize: 16,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                          height: 1.50,
                                        ),
                                      ),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Form(
                                      key: formKey,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Directionality(
                                            // Specify direction if desired
                                            textDirection: TextDirection.ltr,
                                            child: Pinput(
                                              controller: pinController,
                                              focusNode: focusNode,
                                              // androidSmsAutofillMethod:
                                              // AndroidSmsAutofillMethod.smsUserConsentApi,
                                              // listenForMultipleSmsOnAndroid: true,
                                              defaultPinTheme: defaultPinTheme,
                                              separatorBuilder: (index) => const SizedBox(width: 8),
                                              validator: (value) {
                                                return value == '2222' ? null : null;
                                              },
                                              // onClipboardFound: (value) {
                                              //   debugPrint('onClipboardFound: $value');
                                              //   pinController.setText(value);
                                              // },
                                              hapticFeedbackType: HapticFeedbackType.lightImpact,
                                              onCompleted: (pin) {
                                                debugPrint('onCompleted: $pin');
                                                setState(() {
                                                  codefull = pin;
                                                });
                                              },
                                              onChanged: (value) {
                                                debugPrint('onChanged: $value');
                                              },
                                              cursor: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets.only(bottom: 9),
                                                    width: 22,
                                                    height: 1,
                                                    color: focusedBorderColor,
                                                  ),
                                                ],
                                              ),
                                              focusedPinTheme: defaultPinTheme.copyWith(
                                                decoration: defaultPinTheme.decoration!.copyWith(
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: focusedBorderColor),
                                                ),
                                              ),
                                              submittedPinTheme: defaultPinTheme.copyWith(
                                                decoration: defaultPinTheme.decoration!.copyWith(
                                                  color: fillColor,
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: focusedBorderColor),
                                                ),
                                              ),
                                              errorPinTheme: defaultPinTheme.copyBorderWith(
                                                border: Border.all(color: Colors.redAccent),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                Text('Não recebeu o código?',
                                  style: TextStyle(
                                    color: Color(0xFF8A8A8A),
                                    fontSize: 14,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),),
                                InkWell(
                                  onTap: () {
                                    // sendCode(widget.email, widget.password, widget.lat,
                                    //     widget.long);
                                  },
                                  child: Text(
                                    'Reenviar código',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: MyColors.colorPrimary,
                                      decoration: TextDecoration.underline,
                                      decorationColor: MyColors.colorPrimary,
                                      decorationThickness: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [

                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => NavigationScreen(),
                                      ),
                                    );

                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 6,
                                    shadowColor: Colors.black,
                                    backgroundColor: MyColors.colorPrimary,
                                    minimumSize: Size(double.infinity, 48),
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Avançar',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                      height: 1.50,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 32),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  double progress = 0; // valor de 0 até 1
  bool isLoading = false;

}

