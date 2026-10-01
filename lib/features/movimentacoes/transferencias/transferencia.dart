import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/movimentacao_date_filter_sheet.dart';
import 'package:costeira/features/movimentacoes/transferencias/add_transferencia_fazenda.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_list_item.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/page_controllers/transferencias_fazenda_list_page_controller.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/page_controllers/transferencias_page_controller.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/pages/graficos_transferencia.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/pages/transferencia_fazenda_detail_page.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/widgets/transferencia_fazenda_card.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class Transferencia extends StatefulWidget {
  const Transferencia({super.key});

  @override
  State<Transferencia> createState() => _TransferenciaState();
}

class _TransferenciaState extends State<Transferencia>
    with SingleTickerProviderStateMixin {
  final TransferenciasPageController _pageController =
      Modular.get<TransferenciasPageController>();
  final TransferenciasFazendaListPageController _listPageController =
      Modular.get<TransferenciasFazendaListPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _listPageController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    final message = await _listPageController.applyDateFilters(
      dataIn: _listPageController.dataIn,
      dataOut: _listPageController.dataOut,
    );
    if (!mounted || message == null) {
      return;
    }
    AppSnackBar.show(context: context, message: message, isError: true);
  }

  Future<void> _openDetail(
    TransferenciaFazendaListItem item, {
    required bool canEdit,
  }) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => TransferenciaFazendaDetailPage(
          item: item,
          canEdit: canEdit,
        ),
      ),
    );
    if (changed == true) {
      await _reload();
    }
  }

  Future<void> _openAdd() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransferenciaFazenda()),
    );
    if (!mounted) {
      return;
    }
    await _reload();
  }

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<MovimentacaoDateFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MovimentacaoDateFilterSheet(
        initialDataIn: _listPageController.dataIn,
        initialDataOut: _listPageController.dataOut,
      ),
    );
    if (!mounted || result == null) {
      return;
    }
    final message = await _listPageController.applyDateFilters(
      dataIn: result.shouldClear ? null : result.dataIn,
      dataOut: result.shouldClear ? null : result.dataOut,
    );
    if (!mounted || message == null) {
      return;
    }
    AppSnackBar.show(context: context, message: message, isError: true);
  }

  Future<void> _decidir(int id, int status) async {
    final error = await _listPageController.decidir(
      id: id,
      statusTransferencia: status,
    );
    if (!mounted || error == null) {
      return;
    }
    AppSnackBar.show(context: context, message: error, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pageController, _listPageController]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: _pageController.shouldShowFab
              ? FloatingActionButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(64),
                  ),
                  onPressed: _openAdd,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
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
              'Transferências de campo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                TabBar(
                  controller: _pageController.tabController,
                  tabs: const [
                    Tab(text: 'Recebidas'),
                    Tab(text: 'Enviadas'),
                    Tab(text: 'Gráfico'),
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
                if (_pageController.tabIndex == 2)
                  const GraficosTransferencia()
                else
                  _buildListTab(
                    items: _pageController.tabIndex == 0
                        ? _listPageController.recebidas
                        : _listPageController.enviadas,
                    recebidas: _pageController.tabIndex == 0,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTab({
    required List<TransferenciaFazendaListItem> items,
    required bool recebidas,
  }) {
    final hasFilters = _listPageController.hasActiveFilters;
    return Expanded(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              const SizedBox(width: 20),
              InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: _showFilterSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: hasFilters
                        ? const Color(0x14128977)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: hasFilters
                          ? MyColors.colorPrimary
                          : const Color(0xFFE6E6E6),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: hasFilters
                            ? MyColors.colorPrimary
                            : const Color(0xFF8C8C8C),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        hasFilters ? 'Filtros ativos' : 'Filtrar',
                        style: TextStyle(
                          color: hasFilters
                              ? MyColors.colorPrimary
                              : const Color(0xFF8C8C8C),
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
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _listPageController.isLoading && items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _reload,
                    child: items.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Text(
                                  'Nenhuma transferência',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: Color(0xFF8A8A8A),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return TransferenciaFazendaCard(
                                item: item,
                                recebidas: recebidas,
                                onDecidir: _decidir,
                                onOpen: () => _openDetail(item, canEdit: !recebidas),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
