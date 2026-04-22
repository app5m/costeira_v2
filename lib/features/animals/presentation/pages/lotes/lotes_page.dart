import 'package:costeira/app/app_routes.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/page_controllers/lotes_page_controller.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_lot_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../theme/colors.dart';

class LotesPage extends StatefulWidget {
  const LotesPage({super.key});

  @override
  State<LotesPage> createState() => _LotesPageState();
}

class _LotesPageState extends State<LotesPage> {
  final LotesPageController _pageController =
      Modular.get<LotesPageController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final result = await _pageController.loadInitialData();
      if (!mounted || result == null) {
        return;
      }
      _showMessage(result.message, isError: !result.isSuccess);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _showFilterSheet() async {
    final result = await showModalBottomSheet<AnimalLotFilterSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AnimalLotFilterSheet(
        initialNome: _pageController.currentFilter?.nome,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final action = await _pageController.applyFilters(result);
    if (!mounted) {
      return;
    }
    _showMessage(action.message, isError: !action.isSuccess);
  }

  Future<void> _openEdit(AnimalLotEntity lot) async {
    final result = await Modular.to.pushNamed<Map<String, dynamic>?>(
      AppRoutes.animalLotsEdit,
      arguments: lot,
    );

    if (!mounted) {
      return;
    }

    final action = await _pageController.handleEditResult(result);
    if (!mounted || action == null) {
      return;
    }
    _showMessage(action.message, isError: !action.isSuccess);
  }

  Future<void> _confirmDelete(AnimalLotEntity lot) async {
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
          animation: _pageController,
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
                        'Excluir lote',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tem certeza que deseja excluir o lote ${lot.nome} permanentemente?',
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
                          onPressed: _pageController.isDeleting
                              ? null
                              : () async {
                                  final action = await _pageController
                                      .deleteLot(lot);
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
                            _pageController.isDeleting
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
      animation: _pageController,
      builder: (context, _) {
        final hasActiveFilters = _pageController.hasActiveFilters();

        return Expanded(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  const SizedBox(width: 20),
                  _buildTopPill(
                    label: hasActiveFilters ? 'Filtros ativos' : 'Filtrar',
                    icon: Icon(
                      Icons.tune_rounded,
                      size: 16,
                      color: hasActiveFilters
                          ? MyColors.colorPrimary
                          : const Color(0xFF8C8C8C),
                    ),
                    borderColor: hasActiveFilters
                        ? MyColors.colorPrimary
                        : const Color(0xFFE6E6E6),
                    backgroundColor: hasActiveFilters
                        ? const Color(0x14128977)
                        : Colors.transparent,
                    textColor: hasActiveFilters
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
                    final result = await _pageController.loadInitialData();
                    if (!mounted || result == null) {
                      return;
                    }
                    _showMessage(result.message, isError: !result.isSuccess);
                  },
                  child: Builder(
                    builder: (context) {
                      if (_pageController.isLoading &&
                          _pageController.lots.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (_pageController.errorMessage != null &&
                          _pageController.lots.isEmpty) {
                        return ListView(
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  _pageController.errorMessage!,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      if (_pageController.lots.isEmpty) {
                        return ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(
                              child: Text('Nenhum lote cadastrado ate agora.'),
                            ),
                          ],
                        );
                      }

                      return ListView.builder(
                        itemCount: _pageController.lots.length,
                        itemBuilder: (context, index) {
                          final lot = _pageController.lots[index];
                          return _buildLotCard(lot);
                        },
                      );
                    },
                  ),
                ),
              ),
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

  Widget _buildLotCard(AnimalLotEntity lot) {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      margin: const EdgeInsets.only(bottom: 8, left: 20, right: 20),
      padding: const EdgeInsets.all(16),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Lote:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF8C8C8C),
                  fontSize: 12,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                lot.nome,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF313131),
                  fontSize: 14,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => _confirmDelete(lot),
                child: SvgPicture.asset('icon/trash.svg'),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => _openEdit(lot),
                child: SvgPicture.asset('icon/square-pen.svg'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
