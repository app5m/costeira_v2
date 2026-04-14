import 'package:costeira/views/Cadastro/cadastrocliente.dart';
import 'package:flutter/material.dart';

import '../login/login.dart';

class Teladeinicio extends StatelessWidget {
  const Teladeinicio({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          // Fundo ocupando a tela toda
          Positioned.fill(
            child: Image.asset(
              "images/costeira_tela.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('images/logopelocanva.png', height: 220),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Conteúdo centralizado
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child:

            SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              child: Stack(
                children: [
                  Positioned(
                    bottom: 0,
                    left: 1,
                    right: 1,
                    child:
                    Container(
                      width: MediaQuery.of(context).size.width - 40,
                      height: 280,
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only( topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo do iChef
                          Container(
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
                                  'Desenvolvimento Pecuário',
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
                          SizedBox(height: 24),

                          // Botão
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Cadastro()),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              decoration: ShapeDecoration(
                                color: const Color(0xFF00823A), // fundo teal visível
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'Cadastrar',
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


                          SizedBox(height: 24),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const Login()),
                              );
                            },
                            child:
                            Container(
                              width: double.infinity,
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 13),
                              decoration: ShapeDecoration(
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: const Color(0xFF00823A),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Text(
                                    'Entrar',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF00823A),
                                      fontSize: 12,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w600,
                                      height: 1.50,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ),


                          SizedBox(height: 25),

                          // Login
                          SizedBox(
                            width: 328,
                            child: Text(
                              'Termos de Uso e Políticas de Privacidade',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF8C8C8C),
                                fontSize: 12,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w400,
                                height: 1.50,
                              ),
                            ),
                          ),                        ],
                      ),
                    ),

                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
