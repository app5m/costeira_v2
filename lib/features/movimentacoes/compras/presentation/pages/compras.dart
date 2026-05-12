import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/page_controllers/compras_list_page_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/page_controllers/compras_page_controller.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'add_compra.dart';
import 'detail_compra.dart';
import 'edit_compra.dart';
import 'graficos_compras.dart';

class Compras extends StatefulWidget {
  const Compras({super.key});

  @override
  State<Compras> createState() => _ComprasState();
}

class _ComprasState extends State<Compras> with SingleTickerProviderStateMixin {
  final ComprasPageController _pageController =
      Modular.get<ComprasPageController>();
  final ComprasListPageController _listPageController =
      Modular.get<ComprasListPageController>();

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
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCompra()),
    );
    if (!mounted) {
      return;
    }
    await _listPageController.loadInitialData();
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
              'Compras',
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
                  Tab(text: 'Grafico'),
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
              const SizedBox(height: 16),
              if (_pageController.tabIndex == 0)
                Expanded(child: _buildList())
              else
                const GraficosCompras(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList() {
    if (_listPageController.isLoading && _listPageController.compras.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_listPageController.errorMessage != null &&
        _listPageController.compras.isEmpty) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _listPageController.errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    if (_listPageController.compras.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Nenhuma compra cadastrada.')),
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
        itemCount: _listPageController.compras.length,
        itemBuilder: (context, index) {
          final compra = _listPageController.compras[index];
          return _CompraCard(
            compra: compra,
            onOpen: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailCompra(compra: compra)),
              );
            },
            onEdit: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditCompra(compra: compra)),
              ).then((_) => _listPageController.loadInitialData());
            },
            onDelete: () => _showModalBottomSheetExcluir(context, compra),
          );
        },
      ),
    );
  }

  void _showModalBottomSheetExcluir(BuildContext context, CompraEntity compra) {
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
                    colorFilter: const ColorFilter.mode(
                      Colors.red,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Excluir compra',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xff000000),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tem certeza que deseja excluir essa\ncompra permanentemente?',
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
                        final message = await _listPageController.deleteCompra(
                          compra,
                        );
                        if (!mounted || !pageContext.mounted) {
                          return;
                        }
                        AppSnackBar.show(
                          context: pageContext,
                          message: message ?? 'Compra excluida com sucesso.',
                          isError: message != null,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: const BorderSide(color: Colors.red),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
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

class _CompraCard extends StatelessWidget {
  const _CompraCard({
    required this.compra,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
  });

  final CompraEntity compra;
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
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 24,
              offset: Offset(0, 0),
            ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(42.67),
                      ),
                    ),
                    child: SvgPicture.asset(
                      'icon/arrow-left-right.svg',
                      width: 16,
                      height: 16,
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
                          compra.valorTotal?.trim().isNotEmpty == true
                              ? compra.valorTotal!.trim()
                              : 'Valor nao informado',
                          style: const TextStyle(
                            color: Color(0xFF313131),
                            fontSize: 14,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _location,
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
                          compra.data,
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
                GestureDetector(
                  onTap: onDelete,
                  child: SvgPicture.asset('icon/trash.svg'),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onEdit,
                  child: SvgPicture.asset('icon/square-pen.svg'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String get _title {
    final categoria = compra.animais.isNotEmpty
        ? compra.animais.first.categoria?.nome.trim()
        : null;
    final label = categoria?.isNotEmpty == true ? ' - $categoria' : '';
    return '${compra.qtdAnimais} animais$label';
  }

  String get _location {
    final parts = [
      compra.fornecedor,
      compra.municipio,
      compra.potreiro?.nome,
      compra.lote?.nome,
    ].where((item) => item?.trim().isNotEmpty == true).map((item) => item!);

    if (parts.isEmpty) {
      return 'Origem nao informada';
    }
    return parts.join(' - ');
  }
}
