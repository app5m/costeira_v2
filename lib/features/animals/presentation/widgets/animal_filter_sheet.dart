import 'package:costeira/core/common/get_list/domain/entities/get_list_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/components/app_select_overlay.dart';
import 'package:costeira/core/components/custom_button.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

class AnimalFilterSheetResult {
  const AnimalFilterSheetResult._({
    this.shouldClear = false,
    this.brinco,
    this.appAnimaisCategoriasId,
    this.appAnimaisSubcategoriasId,
    this.utBasesRaciaisId,
  });

  const AnimalFilterSheetResult.apply({
    String? brinco,
    int? appAnimaisCategoriasId,
    int? appAnimaisSubcategoriasId,
    int? utBasesRaciaisId,
  }) : this._(
         brinco: brinco,
         appAnimaisCategoriasId: appAnimaisCategoriasId,
         appAnimaisSubcategoriasId: appAnimaisSubcategoriasId,
         utBasesRaciaisId: utBasesRaciaisId,
       );

  const AnimalFilterSheetResult.clear() : this._(shouldClear: true);

  final bool shouldClear;
  final String? brinco;
  final int? appAnimaisCategoriasId;
  final int? appAnimaisSubcategoriasId;
  final int? utBasesRaciaisId;
}

class AnimalFilterSheet extends StatefulWidget {
  const AnimalFilterSheet({
    super.key,
    this.initialBrinco,
    this.initialCategoryId,
    this.initialSubcategoryId,
    this.initialBaseRacialId,
  });

  final String? initialBrinco;
  final int? initialCategoryId;
  final int? initialSubcategoryId;
  final int? initialBaseRacialId;

  @override
  State<AnimalFilterSheet> createState() => _AnimalFilterSheetState();
}

class _AnimalFilterSheetState extends State<AnimalFilterSheet> {
  final GetListUsecase _getListUsecase = Modular.get<GetListUsecase>();
  late final TextEditingController _nameController;

  bool _isLoading = true;
  String? _errorMessage;
  List<ListCategoryEntity> _categories = const [];
  List<ListItemEntity> _basesRaciais = const [];
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  int? _selectedBaseRacialId;

  bool get _hasAnyFilter =>
      _nameController.text.trim().isNotEmpty ||
      _selectedCategoryId != null ||
      _selectedSubcategoryId != null ||
      _selectedBaseRacialId != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialBrinco ?? '');
    _nameController.addListener(_handleFilterChanged);
    _selectedCategoryId = widget.initialCategoryId;
    _selectedSubcategoryId = widget.initialSubcategoryId;
    _selectedBaseRacialId = widget.initialBaseRacialId;
    AppLogger.info('ANIMAIS FILTER SHEET: INIT STATE');
    _loadFilterLists();
  }

  @override
  void dispose() {
    AppLogger.info('ANIMAIS FILTER SHEET: DISPOSE');
    _nameController.dispose();
    super.dispose();
  }

  List<ListSubcategoryEntity> get _subcategories {
    final category = _categories.cast<ListCategoryEntity?>().firstWhere(
      (item) => item?.id == _selectedCategoryId,
      orElse: () => null,
    );
    return category?.subcategorias ?? const [];
  }

  Future<void> _loadFilterLists() async {
    AppLogger.info(
      'ANIMAIS FILTER SHEET: CARREGANDO LISTAS DE MACHO E FEMEA PARA FILTRO',
    );
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait<GetListEntity>([
        _getListUsecase(const GetListParamsEntity(sexo: 1)),
        _getListUsecase(const GetListParamsEntity(sexo: 2)),
      ]);

      final categoriesById = <int, ListCategoryEntity>{};
      final basesById = <int, ListItemEntity>{};

      for (final result in results) {
        for (final category in result.animaisCategorias) {
          categoriesById[category.id] = category;
        }
        for (final item in result.animaisBasesRaciais) {
          basesById[item.id] = item;
        }
      }

      _categories = categoriesById.values.toList()
        ..sort((a, b) => a.nome.trim().compareTo(b.nome.trim()));
      _basesRaciais = basesById.values.toList()
        ..sort((a, b) => a.nome.trim().compareTo(b.nome.trim()));

      final hasSelectedCategory = _categories.any(
        (item) => item.id == _selectedCategoryId,
      );
      if (!hasSelectedCategory) {
        _selectedCategoryId = null;
        _selectedSubcategoryId = null;
      }

      final hasSelectedBase = _basesRaciais.any(
        (item) => item.id == _selectedBaseRacialId,
      );
      if (!hasSelectedBase) {
        _selectedBaseRacialId = null;
      }

      if (_selectedSubcategoryId != null &&
          !_subcategories.any((item) => item.id == _selectedSubcategoryId)) {
        _selectedSubcategoryId = null;
      }

      AppLogger.success(
        'ANIMAIS FILTER SHEET: LISTAS CARREGADAS COM ${_categories.length} CATEGORIAS',
      );
    } catch (error) {
      _errorMessage = 'Nao foi possivel carregar os filtros.';
      AppLogger.error(
        'ANIMAIS FILTER SHEET: ERRO AO CARREGAR LISTAS MSG=$error',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    AppLogger.info('ANIMAIS FILTER SHEET: APLICANDO FILTROS');
    Modular.to.pop(
      AnimalFilterSheetResult.apply(
        brinco: _emptyToNull(_nameController.text),
        appAnimaisCategoriasId: _selectedCategoryId,
        appAnimaisSubcategoriasId: _selectedSubcategoryId,
        utBasesRaciaisId: _selectedBaseRacialId,
      ),
    );
  }

  void _clearFilters() {
    AppLogger.warning('ANIMAIS FILTER SHEET: LIMPANDO FILTROS');
    Modular.to.pop(const AnimalFilterSheetResult.clear());
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _handleFilterChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Flexible(child: _buildBody()),
              const SizedBox(height: 24),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            AppLogger.info('ANIMAIS FILTER SHEET: FECHANDO MODAL');
            Modular.to.pop();
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF313131)),
        ),
        const Expanded(
          child: Text(
            'Filtrar',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF313131),
              fontSize: 20,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: MyColors.colorPrimary),
      );
    }

    if ((_errorMessage ?? '').trim().isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF313131),
                fontFamily: 'Montserrat',
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadFilterLists,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Nome',
            hint: 'Insira aqui...',
            controller: _nameController,
          ),
          _buildDropdown<ListCategoryEntity>(
            label: 'Categoria',
            value: _selectedCategoryId,
            items: _categories,
            itemLabel: (item) => item.nome.trim(),
            onChanged: (value) {
              AppLogger.info(
                'ANIMAIS FILTER SHEET: CATEGORIA ALTERADA PARA ID=${value ?? 'NULL'}',
              );
              setState(() {
                _selectedCategoryId = value;
                _selectedSubcategoryId = null;
              });
            },
          ),
          if (_selectedCategoryId != null && _subcategories.isNotEmpty)
            _buildDropdown<ListSubcategoryEntity>(
              label: 'Subcategoria',
              value: _selectedSubcategoryId,
              items: _subcategories,
              itemLabel: (item) => item.nome.trim(),
              onChanged: (value) {
                AppLogger.info(
                  'ANIMAIS FILTER SHEET: SUBCATEGORIA ALTERADA PARA ID=${value ?? 'NULL'}',
                );
                setState(() {
                  _selectedSubcategoryId = value;
                });
              },
            ),
          _buildDropdown<ListItemEntity>(
            label: 'Base racial',
            value: _selectedBaseRacialId,
            items: _basesRaciais,
            itemLabel: (item) => item.nome.trim(),
            onChanged: (value) {
              AppLogger.info(
                'ANIMAIS FILTER SHEET: BASE RACIAL ALTERADA PARA ID=${value ?? 'NULL'}',
              );
              setState(() {
                _selectedBaseRacialId = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        CustomButton(
          onPressed: _applyFilters,
          text: 'Filtrar',
          enabled: _hasAnyFilter,
          height: 56,
          borderRadius: 16,
        ),
        const SizedBox(height: 16),
        CustomButton(
          onPressed: _clearFilters,
          text: 'Limpar',
          enabled: _hasAnyFilter,
          backgroundColor: Colors.white,
          disabledColor: Colors.white,
          textColor: MyColors.colorPrimary,
          disabledTextColor: MyColors.gray,
          borderColor: MyColors.colorPrimary,
          height: 56,
          borderRadius: 16,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
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
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(
            color: Color(0xFF313131),
            fontSize: 14,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 14,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
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
        const SizedBox(height: 24),
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
          ),
        ),
        const SizedBox(height: 6),
        AppSelectOverlay<int>(
          value: effectiveValue,
          placeholder: 'Selecionar',
          options: items
              .map(
                (item) => AppSelectOption<int>(
                  value: item.id,
                  label: itemLabel(item),
                ),
              )
              .toList(growable: false),
          enabled: items.isNotEmpty,
          onChanged: onChanged,
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
