import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/colors.dart';
import 'Cadastrothree.dart' show Cadastrotree;

class Cadastrotwo extends StatelessWidget {
  const Cadastrotwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00823A),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // Topo verde fixo de fundo
            Container(
              height: 80,
              width: double.infinity,
              color: const Color(0xFF00823A),
            ),

            // Conteúdo principal
            Column(
              children: [
                // Espaço para o topo verde
                const SizedBox(height: 20),

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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
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
                                'Cadastrar',
                                style: TextStyle(
                                  color: Color(0xFF313131),
                                  fontSize: 24,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Preencha os campos abaixo.',
                                style: TextStyle(
                                  color: const Color(0xFF8C8C8C),
                                  fontSize: 14,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w400,
                                  height: 1.50,
                                  letterSpacing: 0.10,
                                ),
                              ),
                              const SizedBox(height: 24),


                              // Foto
                              Center(
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 44,
                                      backgroundColor: const Color(0xFFEBEBEB),
                                      child: SvgPicture.asset('icon/user-round.svg',
                                        width: 44,
                                        height: 44,

                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: CircleAvatar(
                                        radius: 16,
                                        backgroundColor: const Color(0xFFEBEBEB),
                                        child: SvgPicture.asset('icon/edit-rounded.svg',
                                          width: 16,
                                          height: 16,

                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 36),

                              _label("Nome completo"),
                              _textField("Insira seu nome"),

                              const SizedBox(height: 18),

                              _label("WhatsApp"),
                              _textField("(00) 00000-0000"),

                              const SizedBox(height: 18),

                              _label("CPF"),
                              _textField("000.000.000-00"),

                              const SizedBox(height: 32),

                              // Botão sempre no final do conteúdo

                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(children: [
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00823A),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Cadastrotree(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Avançar',
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

                            const SizedBox(height: 32),
                          ],),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF313131),
          fontSize: 14,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.10,
        ),
      ),
    );
  }

  Widget _textField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF8C8C8C),
          fontSize: 14,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0.10,
        ),
        filled: true,
        fillColor: const Color(0xFFEBEBEB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
