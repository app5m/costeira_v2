import 'package:costeira/views/navigationscreen/animais/dados.dart';
import 'package:costeira/views/navigationscreen/animais/listanimais/addanimal/addanimal.dart';
import 'package:costeira/views/navigationscreen/animais/listanimais/listanimais.dart';
import 'package:costeira/views/navigationscreen/animais/lotes/addlote/addlote.dart';
import 'package:flutter/material.dart';

import '../../../theme/colors.dart';
import 'lotes/lotes.dart';

class Animais extends StatefulWidget {
  const Animais({super.key});

  @override
  State<Animais> createState() => _AnimaisState();
}

class _AnimaisState extends State<Animais> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      floatingActionButton: index == 1 || index == 2
          ? FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(63)
        ),
              onPressed: () {
          if(index == 1 ){
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddAnimal()));
          }else{
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddLote()));
          }


              },
              child: Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Dados"),
              Tab(text: "Animais"),
              Tab(text: "Lotes"),
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
          if (index == 0) Expanded(child: DadosAnimais()),
          if (index == 1) ListAnimais(),
          if (index == 2) Lotes(),
        ],
      ),
    );
  }
}
