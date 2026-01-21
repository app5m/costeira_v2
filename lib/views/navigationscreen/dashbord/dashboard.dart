import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              buildContainer('icon/weight.svg', 'Quilos produzidos', '35.000 kg'),
              buildContainer('icon/weight.svg', 'Quilos produzidos', '35.000 kg'),
            ],),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildContainer('icon/banknote.svg', 'Estoque de rebanho', 'R\$1.725.000,00 '),
                buildContainer('icon/cow-light.svg', 'Total de animais', '3 cabeças'),
              ],),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildContainer('icon/weight.svg', 'Média da fazenda', '600 kg/ha '),
                buildContainer('icon/skull.svg', 'Mortalidade', '1,0%'),
              ],),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildContainer('icon/weight.svg', 'Ganho Médio Diário', '0,65 kg/dia'),
                buildContainer('icon/book-check.svg', 'Tarefas do mês', '3 - 15%'),
              ],),
            Image.asset('images/chartproduct.png', width: MediaQuery.of(context).size.width, fit: BoxFit.cover,),
            Image.asset('images/categoriachart.png', width: MediaQuery.of(context).size.width, fit: BoxFit.cover,),
            Image.asset('images/gmd.png', width: MediaQuery.of(context).size.width, fit: BoxFit.cover,),
            Image.asset('images/progressotarefas.png', width: MediaQuery.of(context).size.width, fit: BoxFit.cover,),
          ],
        ),
      ),
    );
  }

  Widget buildContainer(String icon, String title, String value) {
    return Container(
      width: MediaQuery.of(context).size.width / 2 - 40,
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Container(
          padding: const EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.50, -0.00),
              end: Alignment(0.50, 1.00),
              colors: [const Color(0xFF00823A), const Color(0xFF00B752)],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(42.67),
            ),
          ),
          child: SvgPicture.asset(icon, color: Colors.white,width: 16,height: 16,),
        ),
        SizedBox(height: 8,),
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
        SizedBox(height: 8,),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFF00431F),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        )
      ],),
    );
  }
}
