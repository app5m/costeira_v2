import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_entity.dart';
import 'package:costeira/features/climate_and_rain/presentation/page_controllers/climate_list_page_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/page_controllers/climate_page_controller.dart';
import 'package:costeira/features/climate_and_rain/presentation/pages/graphics_climate_page.dart';
import 'package:costeira/features/climate_and_rain/presentation/widgets/climate_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../theme/colors.dart';

class ClimatePage extends StatefulWidget {
  const ClimatePage({super.key});

  @override
  State<ClimatePage> createState() => _ClimatePageState();
}

class _ClimatePageState extends State<ClimatePage>
    with SingleTickerProviderStateMixin {
  final ClimatePageController _pageController =
      Modular.get<ClimatePageController>();
  final ClimateListPageController _listPageController =
      Modular.get<ClimateListPageController>();

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
    final result = await Modular.to.pushNamed<Map<String, dynamic>?>(
      AppRoutes.climateRainAdd,
    );

    if (!mounted || result?['success'] != true) {
      return;
    }

    await _listPageController.loadInitialData();
    if (!mounted) {
      return;
    }

    _showMessage(
      result?['message']?.toString() ?? 'Clima salvo com sucesso.',
      isError: false,
    );
  }

  Future<void> _openEdit(ClimateEntity climate) async {
    final result = await Modular.to.pushNamed<Map<String, dynamic>?>(
      AppRoutes.climateRainEdit,
      arguments: climate,
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

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<ClimateFilterSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ClimateFilterSheet(
        initialDataIn: _listPageController.currentDataInFilter,
        initialDataOut: _listPageController.currentDataOutFilter,
      ),
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

  Future<void> _confirmDelete(ClimateEntity climate) async {
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
                        colorFilter: const ColorFilter.mode(
                          Colors.red,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Excluir chuva',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tem certeza que deseja excluir este registro de chuva?',
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
                                  final action = await _listPageController
                                      .deleteClimate(climate);
                                  if (!mounted || !modalContext.mounted) {
                                    return;
                                  }
                                  if (action.isSuccess) {
                                    Modular.to.pop();
                                  }
                                  _showMessage(
                                    action.message,
                                    isError: !action.isSuccess,
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
                          child: Text(
                            _listPageController.isDeleting
                                ? 'Excluindo...'
                                : 'Excluir',
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
              onPressed: () => Modular.to.pop(),
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text(
              'Clima e Chuvas',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Column(
            children: [
              TabBar(
                controller: _pageController.tabController,
                tabs: const [
                  Tab(text: 'Lista'),
                  Tab(text: 'Dados'),
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
              if (_pageController.tabIndex == 0) ...[
                Row(
                  children: [
                    const SizedBox(width: 20),
                    _buildTopPill(
                      label: _listPageController.hasActiveFilters()
                          ? 'Filtros ativos'
                          : 'Filtrar',
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
                      final result = await _listPageController
                          .loadInitialData();
                      if (!mounted || result == null) {
                        return;
                      }
                      _showMessage(result.message, isError: !result.isSuccess);
                    },
                    child: Builder(
                      builder: (context) {
                        if (_listPageController.isLoading &&
                            _listPageController.climates.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (_listPageController.errorMessage != null &&
                            _listPageController.climates.isEmpty) {
                          return ListView(
                            children: [
                              const SizedBox(height: 120),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: Text(
                                    _listPageController.errorMessage!,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        if (_listPageController.climates.isEmpty) {
                          return ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Text(
                                  'Nenhum registro de chuva cadastrado ate agora.',
                                ),
                              ),
                            ],
                          );
                        }

                        return ListView.builder(
                          itemCount: _listPageController.climates.length,
                          itemBuilder: (context, index) {
                            final climate = _listPageController.climates[index];
                            return Container(
                              width: MediaQuery.of(context).size.width - 40,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(
                                bottom: 8,
                                left: 20,
                                right: 20,
                              ),
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                    width: 1,
                                    color: Color(0xFFEBEBEB),
                                  ),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: ShapeDecoration(
                                            color: const Color(0x198C8C8C),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(42.67),
                                            ),
                                          ),
                                          child: SvgPicture.asset(
                                            'icon/cloud.svg',
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${_formatDecimal(climate.quantidade)} mm',
                                                style: const TextStyle(
                                                  color: Color(0xFF313131),
                                                  fontSize: 14,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              _infoRow(
                                                'Inicio',
                                                climate.dataIn,
                                              ),
                                              const SizedBox(height: 6),
                                              _infoRow('Fim', climate.dataOut),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () => _confirmDelete(climate),
                                        child: SvgPicture.asset(
                                          'icon/trash.svg',
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      GestureDetector(
                                        onTap: () => _openEdit(climate),
                                        child: SvgPicture.asset(
                                          'icon/square-pen.svg',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
              if (_pageController.tabIndex == 1)
                const Expanded(child: GraficsClimatePage()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopPill({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
    required Color borderColor,
    required Color backgroundColor,
    required Color textColor,
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
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w500,
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
}

String _formatDecimal(double value) {
  if (value == value.truncateToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(2);
}
