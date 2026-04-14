import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(64), // Corrigido
        ),
        onPressed: () {}, // Função vazia
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SvgPicture.asset(
            'icon/pata.svg',
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Container superior (header)
          Container(
            height: MediaQuery.of(context).size.height * 0.7,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(top: 16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(64),
                    ),
                    shadows: [
                      BoxShadow(
                        color: const Color(0x0A000000),
                        blurRadius: 24,
                        offset: const Offset(0, 0),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Container inferior (barra de período)
          Positioned(
            bottom: 100, // Posiciona acima do FAB
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Color(0xFFEBEBEB),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                shadows: [
                  BoxShadow(
                    color: const Color(0x0A000000),
                    blurRadius: 24,
                    offset: const Offset(0, 0),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Data inicial
                  Expanded(
                    child: Text(
                      '01 de nov - 30 de nov',
                      style: TextStyle(
                        color: const Color(0xFF313131),
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        height: 1.10,
                      ),
                    ),
                  ),
                  // Ícone de calendário rotacionado
                  Transform.rotate(
                    angle: -1.57, // Rotação em radianos
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
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
