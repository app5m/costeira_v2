import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/delete_animal_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/pages/animals/detail_animal.dart';
import 'package:costeira/features/animals/presentation/pages/animals/edit_animal.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../theme/colors.dart';

class ListAnimais extends StatefulWidget {
  const ListAnimais({super.key});

  @override
  State<ListAnimais> createState() => _ListAnimaisState();
}

class _ListAnimaisState extends State<ListAnimais> {
  final ListAnimalsController _listController = Modular.get<ListAnimalsController>();
  final DeleteAnimalController _deleteController = Modular.get<DeleteAnimalController>();

  @override
  void initState() {
    super.initState();
    AppLogger.info('ANIMAIS LIST PAGE: INIT STATE');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnimals();
    });
  }

  Future<void> _loadAnimals() async {
    AppLogger.info('ANIMAIS LIST PAGE: CARREGANDO ANIMAIS');
    try {
      if (_listController.currentFilter == null) {
        await _listController.load();
      } else {
        await _listController.reload();
      }
      AppLogger.success('ANIMAIS LIST PAGE: ANIMAIS CARREGADOS');
    } catch (_) {
      if (!mounted) {
        return;
      }
      AppLogger.error('ANIMAIS LIST PAGE: ERRO AO CARREGAR ANIMAIS');
      _showMessage(_listController.errorMessage ?? 'Não foi possível carregar os animais.');
    }
  }

  Future<void> _openFilters() async {
    AppLogger.info('ANIMAIS LIST PAGE: ABRINDO MODAL DE FILTROS');
    final currentFilter = _listController.currentFilter;
    final result = await showModalBottomSheet<AnimalFilterSheetResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AnimalFilterSheet(
        initialBrinco: currentFilter?.brinco,
        initialCategoryId: currentFilter?.appAnimaisCategoriasId,
        initialSubcategoryId: currentFilter?.appAnimaisSubcategoriasId,
        initialBaseRacialId: currentFilter?.utBasesRaciaisId,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.shouldClear) {
      AppLogger.warning('ANIMAIS LIST PAGE: LIMPANDO FILTROS DA LISTA');
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

    AppLogger.info('ANIMAIS LIST PAGE: APLICANDO FILTROS NA LISTA');
    try {
      await _listController.load(
        appAnimaisCategoriasId: result.appAnimaisCategoriasId,
        appAnimaisSubcategoriasId: result.appAnimaisSubcategoriasId,
        utBasesRaciaisId: result.utBasesRaciaisId,
        brinco: result.brinco,
      );
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

  Future<void> _openEdit(AnimalEntity animal) async {
    AppLogger.info('ANIMAIS LIST PAGE: ABRINDO EDICAO DO ANIMAL ID=${animal.id}');
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(builder: (_) => EditAnimal(animal: animal)),
    );

    if (result?['success'] == true) {
      AppLogger.success('ANIMAIS LIST PAGE: EDICAO CONCLUIDA, RECARREGANDO LISTA');
      await _loadAnimals();
      if (mounted) {
        _showMessage(
          result?['message']?.toString() ?? 'Animal atualizado com sucesso.',
          isError: false,
        );
      }
    }
  }

  Future<void> _confirmDelete(AnimalEntity animal) async {
    AppLogger.warning('ANIMAIS LIST PAGE: SOLICITANDO CONFIRMACAO DE EXCLUSAO ID=${animal.id}');
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
                        'Excluir animal',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tem certeza que deseja excluir ${animal.brinco ?? 'este animal'} permanentemente?',
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
                              : () => _deleteAnimal(context, animal),
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

  Future<void> _deleteAnimal(BuildContext modalContext, AnimalEntity animal) async {
    AppLogger.warning('ANIMAIS LIST PAGE: EXECUTANDO EXCLUSAO ID=${animal.id}');
    try {
      final result = await _deleteController.delete(animal.id);
      if (!modalContext.mounted || !mounted || result == null) {
        return;
      }

      Navigator.of(modalContext).pop();
      _listController.removeAnimalById(animal.id);
      _showMessage(result.message, isError: false);
    } catch (_) {
      AppLogger.error('ANIMAIS LIST PAGE: ERRO AO EXCLUIR ANIMAL');
      _showMessage(_deleteController.errorMessage ?? 'Não foi possível excluir o animal.');
    }
  }

  void _showMessage(String message, {bool isError = true}) {
    AppLogger.warning('ANIMAIS LIST PAGE: EXIBINDO MENSAGEM $message');
    AppSnackBar.show(context: context, message: message, isError: isError);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _listController,
      builder: (context, _) {
        final hasActiveFilters = _hasActiveFilters(_listController.currentFilter);

        return Column(
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
                  backgroundColor: hasActiveFilters ? const Color(0x14128977) : Colors.transparent,
                  textColor: hasActiveFilters ? MyColors.colorPrimary : const Color(0xFF8C8C8C),
                  onTap: _openFilters,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadAnimals,
                child: Builder(
                  builder: (context) {
                    if (_listController.isLoading && _listController.animals.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (_listController.errorMessage != null && _listController.animals.isEmpty) {
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

                    if (_listController.animals.isEmpty) {
                      return ListView(
                        children: const [
                          SizedBox(height: 120),
                          Center(child: Text('Nenhum animal cadastrado até agora.')),
                        ],
                      );
                    }

                    return ListView.builder(
                      itemCount: _listController.animals.length,
                      itemBuilder: (context, index) {
                        final animal = _listController.animals[index];
                        return GestureDetector(
                          onTap: () {
                            AppLogger.info(
                              'ANIMAIS LIST PAGE: ABRINDO DETALHE DO ANIMAL ID=${animal.id}',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => DetailAnimal(animal: animal)),
                            );
                          },
                          child: Container(
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
                                          'icon/cow-light.svg',
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
                                              animal.brinco?.trim().isNotEmpty == true
                                                  ? animal.brinco!.trim()
                                                  : 'Animal #${animal.id}',
                                              style: const TextStyle(
                                                color: Color(0xFF313131),
                                                fontSize: 16,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              _buildSummary(animal),
                                              style: const TextStyle(
                                                color: Color(0xFF313131),
                                                fontSize: 14,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 16,
                                              runSpacing: 6,
                                              children: [
                                                _buildInfoChip('Lote', animal.lote?.nome),
                                                _buildInfoChip('Potreiro', animal.potreiro?.nome),
                                              ],
                                            ),
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
                                      onTap: () => _confirmDelete(animal),
                                      child: SvgPicture.asset('icon/trash.svg'),
                                    ),
                                    const SizedBox(width: 16),
                                    GestureDetector(
                                      onTap: () => _openEdit(animal),
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
        );
      },
    );
  }

  bool _hasActiveFilters(AnimalsFilterEntity? filter) {
    if (filter == null) {
      return false;
    }

    return filter.id != null ||
        filter.appAnimaisCategoriasId != null ||
        filter.appAnimaisSubcategoriasId != null ||
        filter.utBasesRaciaisId != null ||
        (filter.brinco?.trim().isNotEmpty ?? false);
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

  String _buildSummary(AnimalEntity animal) {
    final parts = <String?>[
      animal.categoria?.nome.trim(),
      animal.peso != null ? '${animal.peso} kg' : null,
      animal.baseRacial?.nome.trim(),
    ].whereType<String>().where((item) => item.isNotEmpty).toList();

    return parts.isEmpty ? 'Sem detalhes informados' : parts.join(' • ');
  }

  Widget _buildInfoChip(String label, String? value) {
    final displayValue = value?.trim();
    if (displayValue == null || displayValue.isEmpty) {
      return const SizedBox.shrink();
    }

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
        const SizedBox(width: 4),
        Text(
          displayValue,
          style: const TextStyle(
            color: Color(0xFF8C8C8C),
            fontSize: 12,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
