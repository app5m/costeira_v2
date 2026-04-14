import 'package:flutter/material.dart';

class GraficosExcucao extends StatefulWidget {
  const GraficosExcucao({super.key});

  @override
  State<GraficosExcucao> createState() => _GraficosExcucaoState();
}

class _GraficosExcucaoState extends State<GraficosExcucao> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _MonthSelector(),
            Image.asset(
              'images/execucao.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Image.asset(
              'images/linhatemposanitario.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Image.asset(
              'images/linhatemposanitario.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Image.asset(
              'images/produtosaplicadoscategoria.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Container(
              width: MediaQuery.of(context).size.width - 40,
              height: 154,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: const Color(0xFFEBEBEB),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                shadows: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 24,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 5.66,
                    top: 40.77,
                    child: Container(
                      width: 316.69,
                      height: 1.13,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F5),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 5.66,
                    top: 97.38,
                    child: Container(
                      width: 316.69,
                      height: 1.13,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F5),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 113.10,
                    top: 53.22,
                    child: Container(
                      width: 1.13,
                      height: 86.06,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F5),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 214.90,
                    top: 53.22,
                    child: Container(
                      width: 1.13,
                      height: 86.06,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F1F5),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 25.54,
                    top: 18.12,
                    child: Text(
                      'Responsável',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF313131),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 141,
                    top: 18.12,
                    child: Text(
                      'Manejo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF313131),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 254.48,
                    top: 18.12,
                    child: SizedBox(
                      width: 27.14,
                      height: 16.99,
                      child: Text(
                        'Qtd',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF313131),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 254.48,
                    top: 69.07,
                    child: SizedBox(
                      width: 28.28,
                      height: 16.99,
                      child: Text(
                        '80',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF8C8C8C),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 254.48,
                    top: 109.84,
                    child: SizedBox(
                      width: 28.28,
                      height: 16.99,
                      child: Text(
                        '120',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF8C8C8C),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 134.30,
                    top: 69.07,
                    child: Text(
                      'Descarna',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF8C8C8C),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 132.16,
                    top: 109.84,
                    child: Text(
                      'Vacinação',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF8C8C8C),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 42.13,
                    top: 69.07,
                    child: SizedBox(
                      width: 32.80,
                      height: 16.99,
                      child: Text(
                        'Clara',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF8C8C8C),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 41,
                    top: 109.84,
                    child: SizedBox(
                      width: 33.93,
                      height: 16.99,
                      child: Text(
                        'João',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF8C8C8C),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget buildContainer(
    String title,
    String valuePercentual,
    String value,
    Color colorText,
    Color colorContainer,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 40,
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: const Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(12),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xFF8C8C8C),
                        fontSize: 12,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: ShapeDecoration(
                    color: colorContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(64),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        valuePercentual,
                        style: TextStyle(
                          color: colorText,
                          fontSize: 10,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 8,
            children: [
              Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF313131),
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      padding: const EdgeInsets.all(16),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: const Color(0xFFEBEBEB)),
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 24,
            offset: Offset(0, 0),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.arrow_back_rounded),
          Text(
            'Junho 2025',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              height: 1.50,
            ),
          ),
          Icon(Icons.arrow_forward_rounded),
        ],
      ),
    );
  }
}
