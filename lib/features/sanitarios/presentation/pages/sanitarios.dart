import 'package:costeira/features/sanitarios/presentation/controllers/list_sanitarios_controller.dart';
import 'package:costeira/features/sanitarios/presentation/pages/add_planejamento.dart';
import 'package:costeira/features/sanitarios/presentation/pages/execucao.dart';
import 'package:costeira/features/sanitarios/presentation/pages/graficos_execucoes.dart';
import 'package:costeira/features/sanitarios/presentation/pages/planejamento.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class Sanitarios extends StatefulWidget {
  const Sanitarios({super.key});

  @override
  State<Sanitarios> createState() => _SanitariosState();
}

class _SanitariosState extends State<Sanitarios> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final ListSanitariosController _controller;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = Modular.get<ListSanitariosController>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: index == 0
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)),
              onPressed: () {
                Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPlanejamento()),
                ).then((saved) {
                  if (saved == true) {
                    _controller.reload();
                  }
                });
              },
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
      appBar: AppBar(
        backgroundColor: MyColors.colorPrimary,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: const Text(
          'Sanitários',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Planejamentos'),
              Tab(text: 'Execuções'),
              Tab(text: 'Gráficos'),
            ],
            onTap: (value) => setState(() => index = value),
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
          if (index == 0) Expanded(child: SanitariosPlanejamentoList(controller: _controller)),
          if (index == 1) Expanded(child: SanitariosExecucoesList(controller: _controller)),
          if (index == 2) const GraficosExcucao(),
        ],
      ),
    );
  }
}
