import 'package:flutter/material.dart';

class GraficosChuva extends StatefulWidget {
  const GraficosChuva({super.key});

  @override
  State<GraficosChuva> createState() => _GraficosChuvaState();
}

class _GraficosChuvaState extends State<GraficosChuva> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 91,
                  margin: EdgeInsets.only(
                    left: 20,
                    bottom: 16,
                    top: 16,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: const Color(0xFFE6E6E6),
                      ),
                      borderRadius: BorderRadius.circular(64),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Filtro',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: const Color(0xFF8C8C8C),
                          fontSize: 12,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF8C8C8C),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: const Color(0xFFEBEBEB),
                  ),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        'Chuva acumulada',
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
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 32,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Text(
                              '142 mm',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF313131),
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Janeiro',
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
                          transform: Matrix4.identity()
                            ..translate(0.0, 0.0)
                            ..rotateZ(1.57),
                          width: 32,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                strokeAlign:
                                    BorderSide.strokeAlignCenter,
                                color: const Color(0xFFEBEBEB),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Text(
                              '812 mm',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF313131),
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '2025',
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              width: MediaQuery.of(context).size.width - 40,
              padding: const EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: const Color(0xFFEBEBEB),
                  ),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      Text(
                        'Média histórica',
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 16,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text(
                            '130 mm',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF313131),
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Janeiro | 2015–2024',
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
                        transform: Matrix4.identity()
                          ..translate(0.0, 0.0)
                          ..rotateZ(1.57),
                        width: 32,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 1,
                              strokeAlign:
                                  BorderSide.strokeAlignCenter,
                              color: const Color(0xFFEBEBEB),
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text(
                            '720 mm',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF313131),
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Anual | 2015–2024',
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
                    ],
                  ),
                ],
              ),
            ),
            Image.asset(
              'images/chuvaacumulada.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Image.asset(
              'images/mmdd.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Image.asset(
              'images/comparativoentreanos.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
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
