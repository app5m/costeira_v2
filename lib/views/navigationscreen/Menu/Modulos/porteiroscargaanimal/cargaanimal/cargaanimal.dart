import 'package:flutter/material.dart';

import '../porteiros/postreiros.dart';

class CargaAnimal extends StatefulWidget {
  const CargaAnimal({super.key});

  @override
  State<CargaAnimal> createState() => _CargaAnimalState();
}

class _CargaAnimalState extends State<CargaAnimal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Potreiros.green,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Carga animal',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 92,
                  margin: EdgeInsets.only(left: 20, bottom: 16, top: 16),
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
            _MonthSelector(),
            SizedBox(height: 16),
            BuildContainer('UA/hectare por potreiro', '4,8 UA/ha'),
            SizedBox(height: 16),
            BuildContainer('Kg/hectare por potreiro', '2.160 kg/ha'),
            SizedBox(height: 16),
            BuildContainer('Carga média da fazenda', '1,42 UA/ha e 640 kg/ha'),
            Image.asset(
              'images/mapageraldosporteiros.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
            ),
            Image.asset(
              'images/uaha.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
            ),
            Image.asset(
              'images/uaha2.png',
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  Widget BuildContainer(String title, String value) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
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
