import 'package:costeira/views/navigationscreen/Menu/Modulos/porteiroscargaanimal/porteiros/listaporteiros/addporteiro/addporteiro.dart';
import 'package:costeira/views/navigationscreen/Menu/Modulos/porteiroscargaanimal/porteiros/listaporteiros/detailporteiro/detailporteiro.dart';
import 'package:costeira/views/navigationscreen/Menu/Modulos/porteiroscargaanimal/porteiros/listaporteiros/editaporteiro/editaporteiro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../theme/colors.dart';

class Potreiros extends StatefulWidget {
  const Potreiros({super.key});

  static const green = Color(0xFF0B8F3C);

  @override
  State<Potreiros> createState() => _PotreirosState();
}

class _PotreirosState extends State<Potreiros>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int index = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: index == 1
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.all(Radius.circular(64)),
              ),

              onPressed: () {
                // final index = DefaultTabController.of(tabContext).index; // 0,1,2
                //
                // if (index == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPorteiro()),
                );

                // } else if (index == 1) {
                //   Navigator.push(context,
                //       MaterialPageRoute(builder: (_) => const Addservice()));
                // } else if (index == 2) {
                //   Navigator.push(context,
                //       MaterialPageRoute(builder: (_) => const AddCategoria()));
                // }
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: Potreiros.green,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text('Potreiros', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Dados"),
              Tab(text: "Lista"),
            ],
            onTap: (int inde) {
              setState(() {
                index = inde;
              });
            },
            automaticIndicatorColorAdjustment: false,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              //   color: Colors.black,
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              // color: Colors.green,
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
            dividerColor: Colors.grey,
            labelColor: Colors.black,
            indicatorColor: MyColors.colorPrimary2,
          ),
          const SizedBox(height: 16),
          if (index == 0) Expanded(child: _DadosTab()),
          if (index == 1)
            Row(
              children: [
                Container(
                  width: 92,
                  margin: EdgeInsets.only(left: 20, bottom: 16),
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
          if (index == 1)
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DetailPorteiro(),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width - 40,
                      padding: const EdgeInsets.all(16),
                      margin: EdgeInsets.only(bottom: 8, left: 20, right: 20),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 16,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: const Color(0x198C8C8C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(42.67),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 5.33,
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: SvgPicture.asset(
                                        'icon/warehouse.svg',
                                        width: 16,
                                        height: 16,
                                        color: Color(0xFF8C8C8C),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  Text(
                                    'Potreiro Baixo • Novilha',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF313131),
                                      fontSize: 14,
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Text(
                                        'Área utilizável',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF8C8C8C),
                                          fontSize: 12,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '38 ha / 42 ha ',
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
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                      Text(
                                        'Presença de aguada:',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: const Color(0xFF8C8C8C),
                                          fontSize: 12,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Sim',
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
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                // mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 8,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _showModalBottomSheetExcluir(context);
                                    },
                                    child: SvgPicture.asset('icon/trash.svg'),
                                  ),
                                  SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const EditPorteiro(),
                                        ),
                                      );
                                    },
                                    child: SvgPicture.asset(
                                      'icon/square-pen.svg',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showModalBottomSheetExcluir(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext bc) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.only(top: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 8),
                    Opacity(
                      opacity: 0.70,
                      child: Container(
                        width: 72,
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              width: 2,
                              strokeAlign: BorderSide.strokeAlignCenter,
                              color: Color(0xFFE2E2E2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [Icon(Icons.close)],
                      ),
                    ),
                    SizedBox(height: 16),
                    SvgPicture.asset(
                      'icon/danger-linear.svg',
                      width: 80,
                      height: 80,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Excluir potreiro",
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xff000000),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Text(
                        "Tem certeza que deseja excluir esse\npotreiro permanentemente?",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: Color(0xFF8692A8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width - 40,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              //  desativeAccount(context);
                            },
                            child: Text(
                              "Excluir",
                              style: TextStyle(color: Colors.red),
                            ),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadiusGeometry.circular(8),
                              ),
                              side: BorderSide(color: Colors.red),
                              elevation: 0,
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                              fontSize: 16,
                              color: MyColors.colorOnPrimary,
                              decoration: TextDecoration.underline,
                              decorationColor: MyColors.colorOnPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                      ],
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DadosTab extends StatelessWidget {
  const _DadosTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        children: [
          _MonthSelector(),
          const SizedBox(height: 16),
          Container(
            width: MediaQuery.of(context).size.width - 40,
            child: _MapCard(),
          ),
          const SizedBox(height: 16),
          _InfoTable(),
          const SizedBox(height: 16),
          _QualityCard(),
          const SizedBox(height: 16),
          Image.asset(
            'icon/disponibiliadadeagua.png',
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.contain,
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
                color: const Color(0xFF313131),
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
        width: MediaQuery.of(context).size.width - 40,
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

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String a;
  final String b;
  final String c;

  const _DataRow(this.a, this.b, this.c);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(a), Text(b), Text(c)],
      ),
    );
  }
}

class _QualityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(
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
              SizedBox(width: 8),
              SvgPicture.asset('icon/download.svg'),
            ],
          ),
        ],
      ),
    );
  }
}
