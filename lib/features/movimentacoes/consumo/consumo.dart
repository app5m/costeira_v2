import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/movimentacoes/consumo/addconsumo/addconsumo.dart';
import 'package:costeira/features/movimentacoes/consumo/detailconsumo/detailconsumo.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/editaconsumo/editaconsumo.dart';
import 'package:costeira/features/movimentacoes/consumo/presentation/page_controllers/consumos_list_page_controller.dart';
import 'package:costeira/features/movimentacoes/consumo/presentation/page_controllers/consumos_page_controller.dart';
import 'package:costeira/features/movimentacoes/consumo/presentation/pages/graficos_consumo.dart';
import 'package:costeira/features/movimentacoes/domain/entities/consumo_entity.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/movimentacao_date_filter_sheet.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Consumo extends StatefulWidget {
  const Consumo({super.key});

  @override
  State<Consumo> createState() => _ConsumoState();
}

class _ConsumoState extends State<Consumo> with SingleTickerProviderStateMixin {
  final ConsumosPageController _pageController = Modular.get<ConsumosPageController>();
  final ConsumosListPageController _listPageController = Modular.get<ConsumosListPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(this);
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
    _pageController.dispose();
    _listPageController.dispose();
    super.dispose();
  }

  Future<void> _openAdd() async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddConsumo()));
    if (!mounted) {
      return;
    }
    await _listPageController.loadInitialData();
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
      animation: Listenable.merge([_pageController, _listPageController]),
      builder: (context, _) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: _pageController.shouldShowFab
              ? FloatingActionButton(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)),
                  onPressed: _openAdd,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text(
              'Consumo',
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
                controller: _pageController.tabController,
                tabs: const [
                  Tab(text: 'Lista'),
                  Tab(text: 'Gráfico'),
                ],
                onTap: _pageController.setTabIndex,
                automaticIndicatorColorAdjustment: false,
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.black,
                indicatorColor: MyColors.colorPrimary2,
              ),
              const SizedBox(height: 16),
              if (_pageController.tabIndex == 0) _buildListTab() else const GraficosConsumo(),
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
    if (_listPageController.isLoading && _listPageController.consumos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_listPageController.errorMessage != null && _listPageController.consumos.isEmpty) {
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

    if (_listPageController.consumos.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Nenhum consumo cadastrado.')),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        final message = await _listPageController.loadInitialData();
        if (!mounted || message == null) {
          return;
        }
        AppSnackBar.show(context: context, message: message, isError: true);
      },
      child: ListView.builder(
        itemCount: _listPageController.consumos.length,
        itemBuilder: (context, index) {
          final consumo = _listPageController.consumos[index];
          return _ConsumoCard(
            consumo: consumo,
            onOpen: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailConsumo(consumo: consumo)),
              );
            },
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditConsumo(consumo: _toUpsert(consumo))),
              ).then((_) => _listPageController.loadInitialData());
            },
            onDelete: () => _showModalBottomSheetExcluir(context, consumo),
          );
        },
      ),
    );
  }

  ConsumoUpsertEntity _toUpsert(ConsumoEntity consumo) {
    return ConsumoUpsertEntity(id: consumo.id, data: consumo.data, obs: consumo.obs);
  }

  void _showModalBottomSheetExcluir(BuildContext context, ConsumoEntity consumo) {
    final pageContext = context;
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'icon/danger-linear.svg',
                  width: 80,
                  height: 80,
                  colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Excluir consumo',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tem certeza que deseja excluir esse\nconsumo permanentemente?',
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
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      final message = await _listPageController.deleteConsumo(consumo);
                      if (!mounted || !pageContext.mounted) {
                        return;
                      }
                      AppSnackBar.show(
                        context: pageContext,
                        message: message ?? 'Consumo excluido com sucesso.',
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ConsumoCard extends StatelessWidget {
  const _ConsumoCard({
    required this.consumo,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final ConsumoEntity consumo;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8, left: 20, right: 20),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFFEBEBEB)),
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24)],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                color: const Color(0x198C8C8C),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(42.67)),
              ),
              child: SvgPicture.asset('icon/arrow-left-right.svg', width: 16, height: 16),
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
                    consumo.obs?.trim().isNotEmpty == true ? consumo.obs!.trim() : _pesoLabel,
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
                    consumo.data,
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
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(onTap: onEdit, child: SvgPicture.asset('icon/square-pen.svg')),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onDelete,
                  child: SvgPicture.asset(
                    'icon/trash.svg',
                    width: 20,
                    height: 20,
                    colorFilter: const ColorFilter.mode(Colors.red, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _title {
    final count = consumo.qtdAnimais;
    return count == 1 ? '1 animal' : '$count animais';
  }

  String get _pesoLabel {
    final pesoTotal = consumo.pesoTotal;
    final pesoMedio = consumo.pesoMedio;
    if (pesoTotal == null && pesoMedio == null) {
      return 'Sem observações';
    }
    if (pesoTotal != null && pesoMedio != null) {
      return '${pesoTotal.toStringAsFixed(2)} kg total | ${pesoMedio.toStringAsFixed(2)} kg medio';
    }
    return '${(pesoTotal ?? pesoMedio)!.toStringAsFixed(2)} kg';
  }
}
