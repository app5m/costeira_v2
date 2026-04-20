import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/presentation/pages/animals/add_animal.dart';
import 'package:costeira/features/animals/presentation/pages/animals/listanimais.dart';
import 'package:costeira/features/animals/presentation/pages/dados.dart';
import 'package:costeira/features/animals/presentation/pages/lotes/add_lote.dart';
import 'package:flutter/material.dart';

import '../../../../theme/colors.dart';
import 'lotes/lotes_page.dart';

class AnimalsPage extends StatefulWidget {
  const AnimalsPage({super.key});

  @override
  State<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends State<AnimalsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _animalsListVersion = 0;
  int _lotesListVersion = 0;
  int index = 0;

  @override
  void initState() {
    super.initState();
    AppLogger.info('ANIMAIS PAGE: INICIALIZANDO TABS');
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    AppLogger.info('ANIMAIS PAGE: DISPONDO TABS');
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: index == 1 || index == 2
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(63)),
              onPressed: () {
                if (index == 1) {
                  AppLogger.info('ANIMAIS PAGE: ABRINDO TELA DE ADICIONAR ANIMAL');
                  Navigator.push<Map<String, dynamic>?>(
                    context,
                    MaterialPageRoute(builder: (_) => const AddAnimal()),
                  ).then((result) {
                    AppLogger.info('ANIMAIS PAGE: RETORNO DA TELA DE ADD ANIMAL');
                    if (result?['success'] != true || !mounted) return;
                    setState(() {
                      _animalsListVersion++;
                      index = 1;
                      _tabController.index = 1;
                    });
                    AppSnackBar.show(
                      context: this.context,
                      message: result?['message']?.toString() ?? 'Animal salvo com sucesso.',
                      isError: false,
                    );
                  });
                } else {
                  AppLogger.info('ANIMAIS PAGE: ABRINDO TELA DE ADICIONAR LOTE');
                  Navigator.push<Map<String, dynamic>?>(
                    context,
                    MaterialPageRoute(builder: (_) => const AddLote()),
                  ).then((result) {
                    AppLogger.info('ANIMAIS PAGE: RETORNO DA TELA DE ADD LOTE');
                    if (result?['success'] != true || !mounted) return;
                    setState(() {
                      _lotesListVersion++;
                      index = 2;
                      _tabController.index = 2;
                    });
                    AppSnackBar.show(
                      context: this.context,
                      message: result?['message']?.toString() ?? 'Lote salvo com sucesso.',
                      isError: false,
                    );
                  });
                }
              },
              child: const Icon(Icons.add_rounded, color: Colors.white),
            )
          : null,
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Dados'),
              Tab(text: 'Animais'),
              Tab(text: 'Lotes'),
            ],
            onTap: (tabIndex) {
              AppLogger.debug('ANIMAIS PAGE: ALTERANDO ABA PARA INDEX=$tabIndex');
              setState(() {
                index = tabIndex;
              });
            },
            automaticIndicatorColorAdjustment: false,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
            ),
            dividerColor: Colors.grey,
            labelColor: Colors.black,
            indicatorColor: MyColors.colorPrimary2,
          ),
          if (index == 0) Expanded(child: DadosAnimais()),
          if (index == 1) Expanded(child: ListAnimais(key: ValueKey(_animalsListVersion))),
          if (index == 2) LotesPage(key: ValueKey(_lotesListVersion)),
        ],
      ),
    );
  }
}
