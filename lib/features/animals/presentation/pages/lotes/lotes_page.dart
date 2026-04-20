import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/delete_animal_lot_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/pages/lotes/edit_lote.dart';
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
  final ListAnimalLotsController _listController = Modular.get<ListAnimalLotsController>();
  final DeleteAnimalLotController _deleteController = Modular.get<DeleteAnimalLotController>();

  @override
  void initState() {
    super.initState();
    AppLogger.info('LOTES LIST PAGE: INIT STATE');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLots();
    });
  }

  Future<void> _loadLots() async {
    AppLogger.info('LOTES LIST PAGE: CARREGANDO LOTES');
    try {
      if (_listController.currentFilter == null) {
        await _listController.load();
      } else {
        await _listController.reload();
      }
      AppLogger.success('LOTES LIST PAGE: LOTES CARREGADOS');
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppLogger.error('LOTES LIST PAGE: ERRO AO CARREGAR LOTES');
      _showMessage(_listController.errorMessage ?? 'Não foi possível carregar os lotes.');
    }
  }

  Future<void> _openFilters() async {
    AppLogger.info('LOTES LIST PAGE: ABRINDO MODAL DE FILTROS');
    final currentFilter = _listController.currentFilter;
    final result = await showModalBottomSheet<AnimalLotFilterSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AnimalLotFilterSheet(initialNome: currentFilter?.nome),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.shouldClear) {
      AppLogger.warning('LOTES LIST PAGE: LIMPANDO FILTROS');
      try {
        await _listController.load();
        if (!mounted) {
          return;
        }
        _showMessage('Filtros removidos com sucesso.', isError: false);
      } catch (_) {
        if (!mounted) {
          return;
        }
        _showMessage(_listController.errorMessage ?? 'Nao foi possivel limpar os filtros.');
      }
      return;
    }

    AppLogger.info('LOTES LIST PAGE: APLICANDO FILTRO POR NOME');
    try {
      await _listController.load(nome: result.nome);
      if (!mounted) {
        return;
      }
      _showMessage('Filtros aplicados com sucesso.', isError: false);
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage(_listController.errorMessage ?? 'Nao foi possivel aplicar os filtros.');
    }
  }

  Future<void> _openEdit(AnimalLotEntity lot) async {
    AppLogger.info('LOTES LIST PAGE: ABRINDO EDICAO DO LOTE ID=${lot.id}');
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(builder: (_) => EditLote(lot: lot)),
    );

    if (result?['success'] == true) {
      AppLogger.success('LOTES LIST PAGE: EDICAO CONCLUIDA, RECARREGANDO LISTA');
      await _loadLots();
      if (mounted) {
        _showMessage(
          result?['message']?.toString() ?? 'Lote atualizado com sucesso.',
          isError: false,
        );
      }
    }
  }

  Future<void> _confirmDelete(AnimalLotEntity lot) async {
    AppLogger.warning('LOTES LIST PAGE: SOLICITANDO CONFIRMACAO DE EXCLUSAO ID=${lot.id}');
    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (_) {
        return AnimatedBuilder(
          animation: _deleteController,
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
                              onTap: () => Navigator.of(context).pop(),
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
                          onPressed: _deleteController.isLoading
                              ? null
                              : () => _deleteLot(context, lot),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(8),
                            ),
                            side: const BorderSide(color: Colors.red),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                          ),
                          child: Text(
                            _deleteController.isLoading ? 'Excluindo...' : 'Excluir',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
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

  Future<void> _deleteLot(BuildContext modalContext, AnimalLotEntity lot) async {
    AppLogger.warning('LOTES LIST PAGE: EXECUTANDO EXCLUSAO ID=${lot.id}');
    try {
      final result = await _deleteController.delete(lot.id);
      if (!modalContext.mounted || !mounted || result == null) {
        return;
      }

      Navigator.of(modalContext).pop();
      _listController.removeLotById(lot.id);
      _showMessage(result.message, isError: false);
    } catch (_) {
      AppLogger.error('LOTES LIST PAGE: ERRO AO EXCLUIR LOTE');
      _showMessage(_deleteController.errorMessage ?? 'Não foi possível excluir o lote.');
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    AppLogger.warning('LOTES LIST PAGE: EXIBINDO MENSAGEM $message');
    AppSnackBar.show(context: context, message: message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _listController,
      builder: (context, _) {
        final hasActiveFilters = _hasActiveFilters(_listController.currentFilter);

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
                      color: hasActiveFilters ? MyColors.colorPrimary : const Color(0xFF8C8C8C),
                    ),
                    borderColor: hasActiveFilters ? MyColors.colorPrimary : const Color(0xFFE6E6E6),
                    backgroundColor: hasActiveFilters
                        ? const Color(0x14128977)
                        : Colors.transparent,
                    textColor: hasActiveFilters ? MyColors.colorPrimary : const Color(0xFF8C8C8C),
                    onTap: _openFilters,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadLots,
                  child: Builder(
                    builder: (context) {
                      if (_listController.isLoading && _listController.lots.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (_listController.errorMessage != null && _listController.lots.isEmpty) {
                        return ListView(
                          children: [
                            const SizedBox(height: 120),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  _listController.errorMessage!,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      if (_listController.lots.isEmpty) {
                        return ListView(
                          children: const [
                            SizedBox(height: 120),
                            Center(child: Text('Nenhum lote cadastrado até agora.')),
                          ],
                        );
                      }

                      return ListView.builder(
                        itemCount: _listController.lots.length,
                        itemBuilder: (context, index) {
                          final lot = _listController.lots[index];
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

  bool _hasActiveFilters(AnimalLotsFilterEntity? filter) {
    if (filter == null) {
      return false;
    }

    return filter.id != null || (filter.nome?.trim().isNotEmpty ?? false);
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
        shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 24, offset: Offset(0, 0))],
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
