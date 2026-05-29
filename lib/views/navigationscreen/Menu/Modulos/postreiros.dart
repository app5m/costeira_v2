import 'package:flutter/material.dart';

class Potreiros extends StatelessWidget {
  const Potreiros({super.key});

  static const green = Color(0xFF0B8F3C);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: green,
          elevation: 0,
          leading: const BackButton(color: Colors.white),
          title: const Text('Potreiros', style: TextStyle(color: Colors.white)),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.notifications_none, color: Colors.white),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Dados'),
              Tab(text: 'Lista'),
            ],
          ),
        ),
        body: const SafeArea(
          top: false,
          child: TabBarView(
            children: [
              _DadosTab(),
              Center(child: Text('Lista')),
            ],
          ),
        ),
      ),
    );
  }
}

class _DadosTab extends StatelessWidget {
  const _DadosTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _MonthSelector(),
          const SizedBox(height: 16),
          _MapCard(),
          const SizedBox(height: 16),
          _InfoTable(),
          const SizedBox(height: 16),
          _QualityCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 24,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Stack(),
                  ),
                  SizedBox(
                    width: 126,
                    child: Text(
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
                  ),
                  Container(
                    width: 16,
                    height: 16,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(),
                    child: Stack(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mapa geral dos potreiros',
              style: TextStyle(
                color: Color(0xFF313131),
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                letterSpacing: 0.10,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Image.asset(
                'images/mapageraldospotreiros.png', // coloque sua imagem aqui
                height: 120,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        width: double.infinity,
        height: 154,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: const Color(0xFFEBEBEB)),
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
              left: 5.65,
              top: 40.77,
              child: Container(
                width: 316.69,
                height: 1.13,
                decoration: BoxDecoration(color: const Color(0xFFF1F1F5)),
              ),
            ),
            Positioned(
              left: 5.65,
              top: 97.38,
              child: Container(
                width: 316.69,
                height: 1.13,
                decoration: BoxDecoration(color: const Color(0xFFF1F1F5)),
              ),
            ),
            Positioned(
              left: 113.10,
              top: 53.22,
              child: Container(
                width: 1.13,
                height: 86.06,
                decoration: BoxDecoration(color: const Color(0xFFF1F1F5)),
              ),
            ),
            Positioned(
              left: 214.90,
              top: 53.22,
              child: Container(
                width: 1.13,
                height: 86.06,
                decoration: BoxDecoration(color: const Color(0xFFF1F1F5)),
              ),
            ),
            Positioned(
              left: 30.54,
              top: 18.12,
              child: SizedBox(
                width: 67.86,
                height: 16.99,
                child: Text(
                  'Área total',
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
              left: 134.59,
              top: 18.12,
              child: SizedBox(
                width: 57.68,
                height: 16.99,
                child: Text(
                  'Área útil',
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
              top: 18.12,
              child: SizedBox(
                width: 27.14,
                height: 16.99,
                child: Text(
                  'Uso',
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
                  '85%',
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
                  '85%',
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
              left: 149.30,
              top: 69.07,
              child: SizedBox(
                width: 29.41,
                height: 16.99,
                child: Text(
                  '112,5',
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
              left: 148.17,
              top: 109.84,
              child: SizedBox(
                width: 31.67,
                height: 16.99,
                child: Text(
                  '127,5',
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
              left: 48.63,
              top: 69.07,
              child: SizedBox(
                width: 32.80,
                height: 16.99,
                child: Text(
                  '125,0',
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
              left: 47.50,
              top: 109.84,
              child: SizedBox(
                width: 33.93,
                height: 16.99,
                child: Text(
                  '150,0',
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
    );
  }
}

class _QualityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16,
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 16,
                children: [
                  Container(
                    width: 328,
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
                              'Relatório de qualidade das aguadas',
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
                            Text(
                              'Boa',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xFF313131),
                                fontSize: 14,
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Stack(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
