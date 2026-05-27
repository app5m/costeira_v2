import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/movimentacoes/abigeatos/add_abigeato.dart';
import 'package:costeira/features/movimentacoes/abigeatos/detail_abigeato.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/edit_abigeato.dart';
import 'package:costeira/features/movimentacoes/abigeatos/presentation/page_controllers/abigeatos_list_page_controller.dart';
import 'package:costeira/features/movimentacoes/abigeatos/presentation/page_controllers/abigeatos_page_controller.dart';
import 'package:costeira/features/movimentacoes/abigeatos/presentation/pages/graficos_abigeato.dart';
import 'package:costeira/features/movimentacoes/domain/entities/abigeato_entity.dart';
import 'package:costeira/features/movimentacoes/presentation/widgets/movimentacao_date_filter_sheet.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Abigeatos extends StatefulWidget {
  const Abigeatos({super.key});

  @override
  State<Abigeatos> createState() => _AbigeatosState();
}

class _AbigeatosState extends State<Abigeatos> with SingleTickerProviderStateMixin {
  final AbigeatosPageController _pageController = Modular.get<AbigeatosPageController>();
  final AbigeatosListPageController _listPageController =
      Modular.get<AbigeatosListPageController>();

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
    await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddAbigeato()));
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
              'Abigeatos',
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
              if (_pageController.tabIndex == 0) _buildListTab() else const GraficosAbigeato(),
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
    if (_listPageController.isLoading && _listPageController.abigeatos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_listPageController.errorMessage != null && _listPageController.abigeatos.isEmpty) {
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

    if (_listPageController.abigeatos.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Nenhum abigeato cadastrado.')),
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
        itemCount: _listPageController.abigeatos.length,
        itemBuilder: (context, index) {
          final abigeato = _listPageController.abigeatos[index];
          return _AbigeatoCard(
            abigeato: abigeato,
            onOpen: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailAbigeato(abigeato: abigeato)),
              );
            },
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditAbigeato(abigeato: _toUpsert(abigeato))),
              ).then((_) => _listPageController.loadInitialData());
            },
            onDelete: () => _showModalBottomSheetExcluir(context, abigeato),
          );
        },
      ),
    );
  }

  void _showModalBottomSheetExcluir(BuildContext context, AbigeatoEntity abigeato) {
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
                  'Excluir abigeato',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tem certeza que deseja excluir esse\nabigeato permanentemente?',
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
                      final message = await _listPageController.deleteAbigeato(abigeato);
                      if (!mounted || !pageContext.mounted) {
                        return;
                      }
                      AppSnackBar.show(
                        context: pageContext,
                        message: message ?? 'Abigeato excluido com sucesso.',
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

  AbigeatoUpsertEntity _toUpsert(AbigeatoEntity abigeato) {
    return AbigeatoUpsertEntity(id: abigeato.id, data: abigeato.data, obs: abigeato.obs);
  }
}

class _AbigeatoCard extends StatelessWidget {
  const _AbigeatoCard({
    required this.abigeato,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final AbigeatoEntity abigeato;
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
              child: SvgPicture.asset('icon/heart-minus.svg', width: 16, height: 16),
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
                    abigeato.obs?.trim().isNotEmpty == true
                        ? abigeato.obs!.trim()
                        : 'Sem observações',
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
                    abigeato.data,
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
    final count = abigeato.qtdAnimais;
    return count == 1 ? '1 animal' : '$count animais';
  }
}
