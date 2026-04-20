import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/core/components/app_snack.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_upsert_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/add_animal_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/pages/lotes/add_lote.dart';
import 'package:costeira/features/animals/presentation/widgets/animal_lot_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import '../../../../../theme/colors.dart';

class AddAnimal extends StatefulWidget {
  const AddAnimal({super.key});

  @override
  State<AddAnimal> createState() => _AddAnimalState();
}

class _AddAnimalState extends State<AddAnimal> {
  static const int _matrixCategoryId = 10;
  static const List<String> _animalStatuses = [
    'parida',
    'prenhe',
    'vazia',
    'descarte',
    'engorda',
  ];

  final AddAnimalController _controller = Modular.get<AddAnimalController>();
  final GetListController _getListController = Modular.get<GetListController>();
  final ListAnimalLotsController _lotsController =
      Modular.get<ListAnimalLotsController>();

  final TextEditingController _brincoController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _obsController = TextEditingController();

  int _selectedSexo = 2;
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  int? _selectedBaseRacialId;
  int? _selectedLotId;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    AppLogger.info('ANIMAIS ADD PAGE: INIT STATE');
    _brincoController.addListener(_handleFormChanged);
    _pesoController.addListener(_handleFormChanged);
    _obsController.addListener(_handleFormChanged);
    _loadInitialData();
  }

  @override
  void dispose() {
    AppLogger.info('ANIMAIS ADD PAGE: DISPOSE');
    _brincoController.dispose();
    _pesoController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    AppLogger.info(
      'ANIMAIS ADD PAGE: CARREGANDO LISTAS E LOTES PARA SEXO=$_selectedSexo',
    );
    try {
      await Future.wait([
        _getListController.load(_selectedSexo),
        _lotsController.load(),
      ]);
      if (!mounted) {
        return;
      }
      setState(_syncSelectedCategory);
      AppLogger.success('ANIMAIS ADD PAGE: LISTAS E LOTES CARREGADOS');
    } catch (_) {
      AppLogger.error('ANIMAIS ADD PAGE: ERRO AO CARREGAR LISTAS/LOTES');
    }
  }

  List<ListCategoryEntity> get _categories =>
      _getListController.result?.animaisCategorias ?? const [];

  List<ListSubcategoryEntity> get _subcategories {
    final category = _categories.cast<ListCategoryEntity?>().firstWhere(
      (item) => item?.id == _selectedCategoryId,
      orElse: () => null,
    );
    return category?.subcategorias ?? const [];
  }

  List<ListItemEntity> get _basesRaciais =>
      _getListController.result?.animaisBasesRaciais ?? const [];

  List<AnimalLotEntity> get _lots => _lotsController.lots;

  AnimalLotEntity? get _selectedLot {
    try {
      return _lots.firstWhere((item) => item.id == _selectedLotId);
    } catch (_) {
      return null;
    }
  }

  String get _selectedLotLabel => _selectedLot?.nome ?? 'Selecionar lote';

  bool get _requiresSubcategory => _selectedCategoryId == _matrixCategoryId;
  bool get _isFormValid =>
      _selectedCategoryId != null &&
      _selectedSexo > 0 &&
      (!_requiresSubcategory || _selectedSubcategoryId != null);

  Future<void> _submit() async {
    AppLogger.info('ANIMAIS ADD PAGE: VALIDANDO FORMULARIO PARA SALVAR');
    final categoryId = _selectedCategoryId;
    if (categoryId == null) {
      _showMessage('Selecione a categoria do animal.');
      return;
    }
    if (_requiresSubcategory && _selectedSubcategoryId == null) {
      _showMessage('Selecione a subcategoria da matriz.');
      return;
    }

    try {
      AppLogger.info('ANIMAIS ADD PAGE: ENVIANDO DADOS DO ANIMAL');
      final result = await _controller.submit(
        AnimalUpsertEntity(
          appAnimaisCategoriasId: categoryId,
          appAnimaisSubcategoriasId: _selectedSubcategoryId,
          utBasesRaciaisId: _selectedBaseRacialId,
          appAnimaisLotesId: _selectedLotId,
          sexo: _selectedSexo,
          brinco: _emptyToNull(_brincoController.text),
          peso: _normalizePeso(_pesoController.text),
          obs: _emptyToNull(_obsController.text),
          status: _selectedStatus,
        ),
      );

      if (!mounted || result == null) {
        return;
      }

      if (result.isSuccess) {
        AppLogger.success(
          'ANIMAIS ADD PAGE: ANIMAL SALVO COM SUCESSO MSG=${result.message}',
        );
        Navigator.of(context).pop({'success': true, 'message': result.message});
        return;
      }

      _showMessage(result.message);
    } catch (_) {
      AppLogger.error('ANIMAIS ADD PAGE: ERRO AO SALVAR ANIMAL');
      _showMessage(
        _controller.errorMessage ?? 'Não foi possível salvar o animal.',
      );
    }
  }

  Future<void> _openLotSelection() async {
    AppLogger.info('ANIMAIS ADD PAGE: ABRINDO SELETOR DE LOTES');
    if (!_lotsController.isLoading &&
        _lots.isEmpty &&
        (_lotsController.errorMessage ?? '').isEmpty) {
      try {
        await _lotsController.load();
      } catch (_) {}
    }

    if (!mounted) {
      return;
    }

    final result = await showModalBottomSheet<AnimalLotSelectionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AnimalLotSelectionSheet(
        lots: _lots,
        initialSelectedLotId: _selectedLotId,
        isLoading: _lotsController.isLoading,
        errorMessage: _lotsController.errorMessage,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    if (result.shouldAddLot) {
      AppLogger.info('ANIMAIS ADD PAGE: USUARIO ESCOLHEU ADICIONAR LOTE');
      final created = await Navigator.push<Map<String, dynamic>?>(
        context,
        MaterialPageRoute(builder: (_) => const AddLote()),
      );

      if (!mounted) {
        return;
      }

      if (created?['success'] == true) {
        AppSnackBar.show(
          context: context,
          message:
              created?['message']?.toString() ?? 'Lote adicionado com sucesso.',
          isError: false,
        );

        try {
          await _lotsController.load();
          if (!mounted) {
            return;
          }
          await _openLotSelection();
        } catch (_) {
          _showMessage(
            _lotsController.errorMessage ??
                'Não foi possível recarregar os lotes.',
          );
        }
      }
      return;
    }

    setState(() {
      _selectedLotId = result.selectedLotId;
    });
  }

  void _showMessage(String message, {bool isError = true}) {
    AppLogger.warning('ANIMAIS ADD PAGE: EXIBINDO MENSAGEM $message');
    AppSnackBar.show(context: context, message: message, isError: isError);
  }

  void _handleFormChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _syncSelectedCategory() {
    AppLogger.debug('ANIMAIS ADD PAGE: SINCRONIZANDO CATEGORIA E SUBCATEGORIA');
    if (_categories.isEmpty) {
      _selectedCategoryId = null;
      _selectedSubcategoryId = null;
      _selectedBaseRacialId = null;
      return;
    }

    final categoryExists = _categories.any(
      (item) => item.id == _selectedCategoryId,
    );
    if (!categoryExists) {
      _selectedCategoryId = _categories.first.id;
    }

    final subcategories = _subcategories;
    if (!_requiresSubcategory || subcategories.isEmpty) {
      _selectedSubcategoryId = null;
    } else if (!subcategories.any(
      (item) => item.id == _selectedSubcategoryId,
    )) {
      _selectedSubcategoryId = subcategories.first.id;
    }

    if (_basesRaciais.isEmpty) {
      _selectedBaseRacialId = null;
    } else if (!_basesRaciais.any((item) => item.id == _selectedBaseRacialId)) {
      _selectedBaseRacialId = _basesRaciais.first.id;
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String? _normalizePeso(String value) {
    final trimmed = value.trim().replaceAll(',', '.').replaceAll('kg', '');
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _controller,
        _getListController,
        _lotsController,
      ]),
      builder: (context, _) {
        final isLoading =
            _controller.isLoading ||
            _getListController.isLoading ||
            _lotsController.isLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: MyColors.colorPrimary,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            title: const Text(
              'Adicionar animal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSexoSelector(),
                const SizedBox(height: 18),
                _buildTextField(
                  controller: _brincoController,
                  label: 'Brinco',
                  hint: 'Ex: BR-005',
                ),
                _buildDropdown<ListCategoryEntity>(
                  label: 'Categoria',
                  value: _selectedCategoryId,
                  items: _categories,
                  itemLabel: (item) => item.nome.trim(),
                  onChanged: (value) {
                    AppLogger.info(
                      'ANIMAIS ADD PAGE: CATEGORIA ALTERADA PARA ID=${value ?? 'NULL'}',
                    );
                    setState(() {
                      _selectedCategoryId = value;
                      final subcategories = _subcategories;
                      _selectedSubcategoryId = null;
                      if (value == _matrixCategoryId &&
                          subcategories.isNotEmpty) {
                        _selectedSubcategoryId = subcategories.first.id;
                      }
                    });
                  },
                ),
                if (_requiresSubcategory)
                  _buildDropdown<ListSubcategoryEntity>(
                    label: 'Subcategoria obrigatória',
                    value: _selectedSubcategoryId,
                    items: _subcategories,
                    itemLabel: (item) => item.nome.trim(),
                    onChanged: (value) {
                      AppLogger.info(
                        'ANIMAIS ADD PAGE: SUBCATEGORIA ALTERADA PARA ID=${value ?? 'NULL'}',
                      );
                      setState(() {
                        _selectedSubcategoryId = value;
                      });
                    },
                  ),
                _buildTextField(
                  controller: _pesoController,
                  label: 'Peso',
                  hint: '700.50',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                _buildDropdown<ListItemEntity>(
                  label: 'Base racial',
                  value: _selectedBaseRacialId,
                  items: _basesRaciais,
                  itemLabel: (item) => item.nome.trim(),
                  onChanged: (value) {
                    AppLogger.info(
                      'ANIMAIS ADD PAGE: BASE RACIAL ALTERADA PARA ID=${value ?? 'NULL'}',
                    );
                    setState(() {
                      _selectedBaseRacialId = value;
                    });
                  },
                ),
                AnimalLotSelectorField(
                  label: 'Lote',
                  value: _selectedLotLabel,
                  onTap: _openLotSelection,
                  isLoading: _lotsController.isLoading,
                  errorMessage: _lotsController.errorMessage,
                ),
                _buildStatusDropdown(
                  value: _selectedStatus,
                  onChanged: (value) {
                    AppLogger.info(
                      'ANIMAIS ADD PAGE: STATUS ALTERADO PARA ${value ?? 'NULL'}',
                    );
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),
                _buildTextField(
                  controller: _obsController,
                  label: 'Observações gerais',
                  hint: 'Animal em observação',
                  maxLines: 3,
                ),
                if (_getListController.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _getListController.errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
                const SizedBox(height: 20),
                CustomButton(
                  onPressed: _submit,
                  text: 'Adicionar',
                  enabled: _isFormValid,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSexoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sexo',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<int>(
                value: 1,
                groupValue: _selectedSexo,
                contentPadding: EdgeInsets.zero,
                title: const Text('Macho'),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  AppLogger.info('ANIMAIS ADD PAGE: SEXO ALTERADO PARA MACHO');
                  setState(() {
                    _selectedSexo = value;
                    _selectedCategoryId = null;
                    _selectedSubcategoryId = null;
                  });
                  _loadInitialData();
                },
              ),
            ),
            Expanded(
              child: RadioListTile<int>(
                value: 2,
                groupValue: _selectedSexo,
                contentPadding: EdgeInsets.zero,
                title: const Text('Fêmea'),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  AppLogger.info('ANIMAIS ADD PAGE: SEXO ALTERADO PARA FEMEA');
                  setState(() {
                    _selectedSexo = value;
                    _selectedCategoryId = null;
                    _selectedSubcategoryId = null;
                  });
                  _loadInitialData();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              height: 1.50,
              letterSpacing: 0.10,
            ),
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildDropdown<T extends ListItemEntity>({
    required String label,
    required int? value,
    required List<T> items,
    required String Function(T item) itemLabel,
    required void Function(int? value) onChanged,
  }) {
    final effectiveValue = items.any((item) => item.id == value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<int>(
          value: effectiveValue,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          hint: const Text('Selecione'),
          items: items
              .map(
                (item) => DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(itemLabel(item)),
                ),
              )
              .toList(growable: false),
          onChanged: items.isEmpty ? null : onChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  Widget _buildStatusDropdown({
    required String? value,
    required void Function(String? value) onChanged,
  }) {
    final effectiveValue = _animalStatuses.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            height: 1.50,
            letterSpacing: 0.10,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: effectiveValue,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFEBEBEB),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          hint: const Text('Selecione o status'),
          items: _animalStatuses
              .map(
                (status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}
