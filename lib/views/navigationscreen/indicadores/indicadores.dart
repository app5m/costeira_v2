import 'package:costeira/views/navigationscreen/indicadores/graficosindicadores.dart';
import 'package:costeira/views/navigationscreen/indicadores/indicadoresdados.dart';
import 'package:flutter/material.dart';

import '../../../theme/colors.dart';

class Indicadores extends StatefulWidget {
  const Indicadores({super.key});

  @override
  State<Indicadores> createState() => _IndicadoresState();
}

class _IndicadoresState extends State<Indicadores>  with SingleTickerProviderStateMixin {
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
      body: Column(children: [

        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Dados"),
            Tab(text: "Gráficos"),
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
        if(index == 0)
          Expanded(child: indicadoresDados()),
        if(index == 1)
          Expanded(child: GraficosIndicadores())
      ],),
    );
  }
}
