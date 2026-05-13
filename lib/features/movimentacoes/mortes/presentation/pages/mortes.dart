import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_entity.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/movimentacao_date_filter_sheet.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/page_controllers/mortes_list_page_controller.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'add_morte.dart';
import 'detail_morte.dart';
import 'edita_morte.dart';
import 'graficosmorte.dart';

class Mortes extends StatefulWidget {
  const Mortes({super.key});

  @override
  State<Mortes> createState() => _MortesState();
}

class _MortesState extends State<Mortes> with SingleTickerProviderStateMixin {
  final MortesListPageController _listPageController = Modular.get<MortesListPageController>();

  late TabController _tabController;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final message = await _listPageController.loadInitialData();
      if (!mounted || message == null) {
        return;
      }
      AppSnackBar.show(context: context, message: message, isError: true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _listPageController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final message = await _listPageController.loadInitialData();
    if (!mounted || message == null) {
      return;
    }
    AppSnackBar.show(context: context, message: message, isError: true);
  }

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<MovimentacaoDateFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MovimentacaoDateFilterSheet(
        initialDataIn: _listPageController.currentDataInFilter,
        initialDataOut: _listPageController.currentDataOutFilter,
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    final message = await _listPageController.applyDateFilters(
      dataIn: result.shouldClear ? null : result.dataIn,
      dataOut: result.shouldClear ? null : result.dataOut,
    );
    if (!mounted) {
      return;
    }
    AppSnackBar.show(
      context: context,
      message:
          message ??
          (result.shouldClear
              ? 'Filtros removidos com sucesso.'
              : 'Filtros aplicados com sucesso.'),
      isError: message != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _listPageController,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: index == 0
              ? FloatingActionButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddMorte()),
                    ).then((_) => _reload());
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                )
              : null,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text(
              'Mortes',
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
                  Tab(text: 'Lista'),
                  Tab(text: 'Gráfico'),
                ],
                onTap: (value) {
                  setState(() {
                    index = value;
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
              const SizedBox(height: 16),
              if (index == 0) _buildListTab() else const GraficosMorte(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTab() {
    return Expanded(
      child: Column(
        children: [
          _buildFilterPill(),
          const SizedBox(height: 16),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilterPill() {
    final hasFilters = _listPageController.hasActiveFilters();
    return Row(
      children: [
        const SizedBox(width: 20),
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: _showFilterSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: hasFilters ? const Color(0x14128977) : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: hasFilters ? MyColors.colorPrimary : const Color(0xFFE6E6E6),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: hasFilters ? MyColors.colorPrimary : const Color(0xFF8C8C8C),
                ),
                const SizedBox(width: 6),
                Text(
                  hasFilters ? 'Filtros ativos' : 'Filtrar',
                  style: TextStyle(
                    color: hasFilters ? MyColors.colorPrimary : const Color(0xFF8C8C8C),
                    fontSize: 12,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    if (_listPageController.isLoading && _listPageController.mortes.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_listPageController.errorMessage != null && _listPageController.mortes.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(_listPageController.errorMessage!, textAlign: TextAlign.center),
          ),
        ],
      );
    }

    if (_listPageController.mortes.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Nenhuma morte cadastrada.')),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.builder(
        itemCount: _listPageController.mortes.length,
        itemBuilder: (context, index) {
          final morte = _listPageController.mortes[index];
          return _MorteCard(
            morte: morte,
            onOpen: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => DetailMorte(morte: morte)));
            },
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditMorte(morte: morte)),
              ).then((_) => _reload());
            },
            onDelete: () => _showModalBottomSheetExcluir(context, morte),
          );
        },
      ),
    );
  }

  void _showModalBottomSheetExcluir(BuildContext context, MorteEntity morte) {
    final pageContext = context;
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (BuildContext bc) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Opacity(
                    opacity: 0.70,
                    child: Container(
                      width: 72,
                      decoration: const ShapeDecoration(
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
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(false),
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SvgPicture.asset(
                    'icon/danger-linear.svg',
                    width: 80,
                    height: 80,
                    colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Excluir morte',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xff000000),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tem certeza que deseja excluir essa\nmorte permanentemente?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Color(0xFF8692A8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        final message = await _listPageController.deleteMorte(morte);
                        if (!mounted || !pageContext.mounted) {
                          return;
                        }
                        AppSnackBar.show(
                          context: pageContext,
                          message: message ?? 'Morte excluida com sucesso.',
                          isError: message != null,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        side: const BorderSide(color: Colors.red),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        fontSize: 16,
                        color: MyColors.colorOnPrimary,
                        decoration: TextDecoration.underline,
                        decorationColor: MyColors.colorOnPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MorteCard extends StatelessWidget {
  const _MorteCard({
    required this.morte,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final MorteEntity morte;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8, left: 20, right: 20),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [
            BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 0)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: ShapeDecoration(
                      color: const Color(0x198C8C8C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42.67)),
                    ),
                    child: SvgPicture.asset(
                      'icon/skull.svg',
                      width: 16,
                      height: 16,
                      colorFilter: const ColorFilter.mode(Color(0xFF8C8C8C), BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _title,
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          morte.obs?.trim().isNotEmpty == true
                              ? morte.obs!.trim()
                              : 'Causa nao informada',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          morte.data,
                          style: const TextStyle(
                            color: Color(0xFF8C8C8C),
                            fontSize: 12,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                GestureDetector(onTap: onDelete, child: SvgPicture.asset('icon/trash.svg')),
                const SizedBox(height: 12),
                GestureDetector(onTap: onEdit, child: SvgPicture.asset('icon/square-pen.svg')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _title {
    final categoria = morte.animais.isNotEmpty ? morte.animais.first.categoria?.nome.trim() : null;
    final label = categoria?.isNotEmpty == true ? ' - $categoria' : '';
    final count = morte.qtdAnimais == 1 ? '1 animal' : '${morte.qtdAnimais} animais';
    return '$count$label';
  }
}
