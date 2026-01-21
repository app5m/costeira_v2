import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

class RecoverPasswordPage extends StatefulWidget {
  const RecoverPasswordPage({super.key});

  @override
  State<RecoverPasswordPage> createState() => _RecoverPasswordPageState();
}

class _RecoverPasswordPageState extends State<RecoverPasswordPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Color primaryGreen = MyColors.colorPrimary; // ajuste se seu verde for outro

    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Card branco com bordas arredondadas no topo
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back + título
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.arrow_back_ios, size: 20),
                            ),

                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Recuperação de senha',
                          style: TextStyle(
                            color: const Color(0xFF313131),
                            fontSize: 24,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Enviaremos um link de redefinição de senha\npara o seu e-mail.',
                          style: TextStyle(
                            color: Color(0xFF77787C),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Label E-mail
                        const Text(
                          'E-mail',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF313131),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Campo E-mail
                        SizedBox(
                          height: 55,
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: Color(0xFF000000),
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'exemplo@email.com',
                              hintStyle: TextStyle(
                                color: Color(0xFFBDBDBD),
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                              filled: true,
                              fillColor: Color(0xFFF3F3F3),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFFF3F3F3),
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: MyColors.colorPrimary,
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Botão Enviar
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              // TODO: chamar sua função de envio de e-mail de recuperação
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Enviar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
      ),
    );
  }
}
