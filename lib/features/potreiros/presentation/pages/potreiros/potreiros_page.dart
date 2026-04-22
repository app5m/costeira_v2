import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/page_controllers/potreiros_page_controller.dart';
import 'package:costeira/features/potreiros/presentation/pages/potreiros/dados_potreiros.dart';
import 'package:costeira/features/potreiros/presentation/widgets/potreiro_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../theme/colors.dart';
import '../../page_controllers/potreiro_list_page_controller.dart';

class Potreiros extends StatefulWidget {
  const Potreiros({super.key});

  static const green = Color(0xFF0B8F3C);

  @override
  State<Potreiros> createState() => _PotreirosState();
}

class _PotreirosState extends State<Potreiros> with SingleTickerProviderStateMixin {
  final PotreirosPageController _pageController = Modular.get<PotreirosPageController>();
  final PotreiroListPageController _listPageController = Modular.get<PotreiroListPageController>();

  @override
  void initState() {
    super.initState();
    _pageController.init(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await _listPageController.loadInitialData();
      if (!mounted || result == null) {
        return;
      }
      _showMessage(result.message, isError: !result.isSuccess);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _listPageController.dispose();
    super.dispose();
  }

  Future<void> _openAdd() async {
    final result = await Modular.to.pushNamed<Map<String, dynamic>?>(AppRoutes.potreirosAdd);

    if (!mounted || result?['success'] != true) {
      return;
    }

    _pageController.handleCreatedOrUpdated();
    await _listPageController.loadInitialData();
    if (!mounted) {
      return;
    }
    _showMessage(result?['message']?.toString() ?? 'Potreiro salvo com sucesso.', isError: false);
  }

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<PotreiroFilterSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          PotreiroFilterSheet(initialStatusAtual: _listPageController.currentStatusFilter),
    );

    if (!mounted || result == null) {
      return;
    }

    final action = await _listPageController.applyFilters(result);
    if (!mounted) {
      return;
    }
    _showMessage(action.message, isError: !action.isSuccess);
  }

  Future<void> _openEdit(PotreiroEntity potreiro) async {
    final result = await Modular.to.pushNamed<Map<String, dynamic>?>(
      AppRoutes.potreirosEdit,
      arguments: potreiro,
    );

    if (!mounted) {
      return;
    }

    final action = await _listPageController.handleEditResult(result);
    if (!mounted || action == null) {
      return;
    }

    _showMessage(action.message, isError: !action.isSuccess);
  }

  Future<void> _openDetail(PotreiroEntity potreiro) async {
    await Modular.to.pushNamed(AppRoutes.potreirosDetail, arguments: potreiro);
  }

  Future<void> _confirmDelete(PotreiroEntity potreiro) async {
    await showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (modalContext) {
        return AnimatedBuilder(
          animation: _listPageController,
          builder: (context, __) {
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
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(
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
                              onTap: () => Modular.to.pop(),
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
                        'Excluir potreiro',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tem certeza que deseja excluir ${potreiro.nome} permanentemente?',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
                          onPressed: _listPageController.isDeleting
                              ? null
                              : () async {
                                  final action = await _listPageController.deletePotreiro(potreiro);
                                  if (!mounted || !modalContext.mounted) {
                                    return;
                                  }

                                  if (action.isSuccess) {
                                    Modular.to.pop();
                                  }
                                  _showMessage(action.message, isError: !action.isSuccess);
                                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            side: const BorderSide(color: Colors.red),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            _listPageController.isDeleting ? 'Excluindo...' : 'Excluir',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Modular.to.pop(),
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
      },
    );
  }

  void _showMessage(String message, {bool isError = true}) {
    AppSnackBar.show(context: context, message: message, isError: isError);
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
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                )
              : null,
          appBar: AppBar(
            backgroundColor: Potreiros.green,
            elevation: 0,
            leading: const BackButton(color: Colors.white),
            title: const Text('Potreiros', style: TextStyle(color: Colors.white)),
          ),
          body: Column(
            children: [
              TabBar(
                controller: _pageController.tabController,
                tabs: const [
                  Tab(text: 'Dados'),
                  Tab(text: 'Lista'),
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
              if (_pageController.tabIndex == 0) const Expanded(child: DadosPotreiros()),
              if (_pageController.tabIndex == 1) ...[
                Row(
                  children: [
                    const SizedBox(width: 20),
                    _buildTopPill(
                      label: _listPageController.hasActiveFilters() ? 'Filtros ativos' : 'Filtrar',
                      icon: Icon(
                        Icons.tune_rounded,
                        size: 16,
                        color: _listPageController.hasActiveFilters()
                            ? MyColors.colorPrimary
                            : const Color(0xFF8C8C8C),
                      ),
                      borderColor: _listPageController.hasActiveFilters()
                          ? MyColors.colorPrimary
                          : const Color(0xFFE6E6E6),
                      backgroundColor: _listPageController.hasActiveFilters()
                          ? const Color(0x14128977)
                          : Colors.transparent,
                      textColor: _listPageController.hasActiveFilters()
                          ? MyColors.colorPrimary
                          : const Color(0xFF8C8C8C),
                      onTap: _showFilterSheet,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final result = await _listPageController.loadInitialData();
                      if (!mounted || result == null) {
                        return;
                      }
                      _showMessage(result.message, isError: !result.isSuccess);
                    },
                    child: Builder(
                      builder: (context) {
                        if (_listPageController.isLoading &&
                            _listPageController.potreiros.isEmpty) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (_listPageController.errorMessage != null &&
                            _listPageController.potreiros.isEmpty) {
                          return ListView(
                            children: [
                              const SizedBox(height: 120),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Text(
                                    _listPageController.errorMessage!,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        if (_listPageController.potreiros.isEmpty) {
                          return ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(child: Text('Nenhum potreiro cadastrado até agora.')),
                            ],
                          );
                        }

                        return ListView.builder(
                          itemCount: _listPageController.potreiros.length,
                          itemBuilder: (context, index) {
                            final potreiro = _listPageController.potreiros[index];
                            return GestureDetector(
                              onTap: () => _openDetail(potreiro),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            clipBehavior: Clip.antiAlias,
                                            decoration: ShapeDecoration(
                                              color: const Color(0x198C8C8C),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(42.67),
                                              ),
                                            ),
                                            child: SvgPicture.asset(
                                              'icon/warehouse.svg',
                                              width: 16,
                                              height: 16,
                                              colorFilter: const ColorFilter.mode(
                                                Color(0xFF8C8C8C),
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _potreiroTitle(potreiro),
                                                  style: const TextStyle(
                                                    color: Color(0xFF313131),
                                                    fontSize: 14,
                                                    fontFamily: 'Montserrat',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                _infoRow(
                                                  'Área útil',
                                                  '${_decimal(potreiro.areaUtil)} ha / ${_decimal(potreiro.areaTotal)} ha',
                                                ),
                                                const SizedBox(height: 6),
                                                _infoRow(
                                                  'Acesso água',
                                                  _displayOrDash(potreiro.acessoAgua),
                                                ),
                                                const SizedBox(height: 6),
                                                _infoRow(
                                                  'Status',
                                                  _displayOrDash(potreiro.statusAtual),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _confirmDelete(potreiro),
                                          child: SvgPicture.asset('icon/trash.svg'),
                                        ),
                                        const SizedBox(height: 24),
                                        GestureDetector(
                                          onTap: () => _openEdit(potreiro),
                                          child: SvgPicture.asset('icon/square-pen.svg'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopPill({
    required String label,
    required Widget icon,
    VoidCallback? onTap,
    Color borderColor = const Color(0xFFE6E6E6),
    Color backgroundColor = Colors.transparent,
    Color textColor = const Color(0xFF8C8C8C),
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(64),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: borderColor),
            borderRadius: BorderRadius.circular(64),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
            const SizedBox(width: 8),
            icon,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 12,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF313131),
              fontSize: 12,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _potreiroTitle(PotreiroEntity potreiro) {
    final status = (potreiro.statusAtual ?? '').trim();
    if (status.isEmpty) {
      return potreiro.nome;
    }
    return '${potreiro.nome} - $status';
  }

  String _decimal(double? value) {
    if (value == null) {
      return '-';
    }
    if (value == value.truncateToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  String _displayOrDash(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? '-' : trimmed;
  }
}
