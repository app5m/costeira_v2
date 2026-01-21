import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GraficosIndicadores extends StatefulWidget {
  const GraficosIndicadores({super.key});

  @override
  State<GraficosIndicadores> createState() => _GraficosIndicadoresState();
}

class _GraficosIndicadoresState extends State<GraficosIndicadores> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: 16),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset('icon/calendar.svg'),
                    SizedBox(width: 8),
                    Text(
                      '01 de nov - 30 de nov',
                      style: TextStyle(
                        color: const Color(0xFF313131),
                        fontSize: 13,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        height: 1.10,
                      ),
                    ),
                  ],
                ),
                SvgPicture.asset('icon/header.svg'),
              ],
            ),
          ),
          SizedBox(height: 16),
          Image.asset('images/produtividade.png', width: MediaQuery.of(context).size.width, fit: BoxFit.cover,),

          Image.asset('images/gmd.png', width: MediaQuery.of(context).size.width, fit: BoxFit.cover,),
          Image.asset('images/categoriachart.png', width: MediaQuery.of(context).size.width, fit: BoxFit.cover,),
          Image.asset('images/rankingeficiencia.png', width: MediaQuery.of(context).size.width, fit: BoxFit.cover,),
        ],),
      ),
    );
  }
}
