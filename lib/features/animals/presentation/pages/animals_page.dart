import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/animals/presentation/page_controllers/animals_page_controller.dart';
import 'package:costeira/features/animals/presentation/pages/animals/animal_list.dart';
import 'package:costeira/features/animals/presentation/pages/dados.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../theme/colors.dart';
import 'lotes/lotes_page.dart';

class AnimalsPage extends StatefulWidget {
  const AnimalsPage({super.key});

  @override
  State<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends State<AnimalsPage>
    with SingleTickerProviderStateMixin {
  final AnimalsPageController _pageController =
      Modular.get<AnimalsPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openAddAnimal() async {
    final result = await Modular.to.pushNamed<Map<String, dynamic>?>(
      AppRoutes.animalsAdd,
    );

    if (!mounted || result?['success'] != true) {
      return;
    }

    _pageController.handleAnimalCreated();
    AppSnackBar.show(
      context: context,
      message: result?['message']?.toString() ?? 'Animal salvo com sucesso.',
      isError: false,
    );
  }

  Future<void> _openAddLot() async {
    final result = await Modular.to.pushNamed<Map<String, dynamic>?>(
      AppRoutes.animalLotsAdd,
    );

    if (!mounted || result?['success'] != true) {
      return;
    }

    _pageController.handleLotCreated();
    AppSnackBar.show(
      context: context,
      message: result?['message']?.toString() ?? 'Lote salvo com sucesso.',
      isError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: _pageController.shouldShowFab
              ? FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(63),
                  ),
                  onPressed: _pageController.isAnimalsTab
                      ? _openAddAnimal
                      : _openAddLot,
                  child: const Icon(Icons.add_rounded, color: Colors.white),
                )
              : null,
          body: SafeArea(
            child: Column(
              children: [
                TabBar(
                  controller: _pageController.tabController,
                  tabs: const [
                    Tab(text: 'Dados'),
                    Tab(text: 'Animais'),
                    Tab(text: 'Lotes'),
                  ],
                  onTap: _pageController.setTabIndex,
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
                if (_pageController.tabIndex == 0)
                  const Expanded(child: DadosAnimais()),
                if (_pageController.tabIndex == 1)
                  Expanded(
                    child: AnimalList(
                      key: ValueKey(_pageController.animalsListVersion),
                    ),
                  ),
                if (_pageController.tabIndex == 2)
                  LotesPage(key: ValueKey(_pageController.lotsListVersion)),
              ],
            ),
          ),
        );
      },
    );
  }
}
