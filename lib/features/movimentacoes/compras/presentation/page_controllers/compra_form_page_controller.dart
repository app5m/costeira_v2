import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/controllers/add_compra_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/controllers/edit_compra_controller.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

class CompraFormPageController extends ChangeNotifier {
  CompraFormPageController(
    this._addController,
    this._editController,
    this._getListController,
    this._lotsController,
    this._potreirosController,
  ) {
    _addController.addListener(notifyListeners);
    _editController.addListener(notifyListeners);
    _getListController.addListener(notifyListeners);
    _lotsController.addListener(notifyListeners);
    _potreirosController.addListener(notifyListeners);
    dataController.addListener(notifyListeners);
    valorUnitarioController.addListener(notifyListeners);
    fornecedorController.addListener(notifyListeners);
    municipioController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
  }

  static const List<String> tiposCompra = ['kg', 'cabeça'];
  static const int matrixCategoryId = 10;

  final AddCompraController _addController;
  final EditCompraController _editController;
  final GetListController _getListController;
  final ListAnimalLotsController _lotsController;
  final ListPotreirosController _potreirosController;

  final TextEditingController dataController = TextEditingController();
  final TextEditingController valorUnitarioController = TextEditingController();
  final TextEditingController fornecedorController = TextEditingController();
  final TextEditingController municipioController = TextEditingController();
  final TextEditingController obsController = TextEditingController();

  CompraEntity? _editingCompra;
  int? selectedPotreiroId;
  int? selectedLotId;
  String? selectedTipoCompra;
  int selectedAnimalSexo = 1;
  int? selectedAnimalCategoryId;
  int? selectedAnimalSubcategoryId;
  int? selectedAnimalBaseRacialId;
  List<CompraUpsertAnimalEntity> _animais = const [];
  int _animalListLoadRequest = 0;
  final Map<int, String> _animalCategoryLabels = {};
  final Map<int, String> _animalSubcategoryLabels = {};
  final Map<int, String> _animalBaseRacialLabels = {};

  bool get isEdit => _editingCompra != null;
  bool get isLoading =>
      _addController.isLoading ||
      _editController.isLoading ||
      _getListController.isLoading ||
      _lotsController.isLoading ||
      _potreirosController.isLoading;
  String? get errorMessage =>
      _addController.errorMessage ??
      _editController.errorMessage ??
      _getListController.errorMessage ??
      _lotsController.errorMessage ??
      _potreirosController.errorMessage;
  List<PotreiroEntity> get potreiros => _potreirosController.potreiros;
  List<AnimalLotEntity> get lots => _lotsController.lots;
  List<CompraUpsertAnimalEntity> get animais => _animais;
  List<ListCategoryEntity> get animalCategories {
    final categories = _getListController.result?.animaisCategorias ?? const [];
    return categories
        .where((item) => item.sexo == selectedAnimalSexo)
        .toList(growable: false);
  }

  List<ListItemEntity> get basesRaciais =>
      _getListController.result?.animaisBasesRaciais ?? const [];
  List<ListSubcategoryEntity> get animalSubcategories {
    final category = animalCategories.cast<ListCategoryEntity?>().firstWhere(
      (item) => item?.id == selectedAnimalCategoryId,
      orElse: () => null,
    );
    return category?.subcategorias ?? const [];
  }

  PotreiroEntity? get selectedPotreiro {
    try {
      return potreiros.firstWhere((item) => item.id == selectedPotreiroId);
    } catch (_) {
      return null;
    }
  }

  AnimalLotEntity? get selectedLot {
    try {
      return lots.firstWhere((item) => item.id == selectedLotId);
    } catch (_) {
      return null;
    }
  }

  String get selectedPotreiroLabel =>
      selectedPotreiro?.nome ??
      _editingCompra?.potreiro?.nome ??
      'Selecionar potreiro';
  String get selectedLotLabel =>
      selectedLot?.nome ?? _editingCompra?.lote?.nome ?? 'Selecionar lote';
  bool get isFormValid =>
      selectedPotreiroId != null &&
      selectedLotId != null &&
      dataController.text.trim().isNotEmpty &&
      selectedTipoCompra != null &&
      valorUnitarioController.text.trim().isNotEmpty &&
      (isEdit || _animais.isNotEmpty);
  bool get shouldShowAnimalSubcategory =>
      selectedAnimalSexo == 2 && selectedAnimalCategoryId == matrixCategoryId;

  Future<void> init({CompraEntity? compra}) async {
    _editingCompra = compra;
    if (compra != null) {
      selectedPotreiroId = compra.appPotreirosId ?? compra.potreiro?.id;
      selectedLotId = compra.appAnimaisLotesId ?? compra.lote?.id;
      selectedTipoCompra = tiposCompra.contains(compra.tipoCompra)
          ? compra.tipoCompra
          : null;
      dataController.text = compra.data;
      valorUnitarioController.text =
          compra.valorUnitario?.replaceAll('R\$', '').trim() ??
          compra.valorUnitarioRaw?.toStringAsFixed(2) ??
          '';
      fornecedorController.text = compra.fornecedor ?? '';
      municipioController.text = compra.municipio ?? '';
      obsController.text = compra.obs ?? '';
    }

    try {
      await Future.wait([
        _getListController.load(selectedAnimalSexo),
        _lotsController.load(),
        _potreirosController.load(),
      ]);
      _cacheAnimalLabelsFromCurrentLists();
      _syncAnimalCategory();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> reloadLots() => _lotsController.load();
  Future<void> reloadPotreiros() => _potreirosController.load();

  void onPotreiroChanged(int? value) {
    selectedPotreiroId = value;
    notifyListeners();
  }

  void onLotChanged(int? value) {
    selectedLotId = value;
    notifyListeners();
  }

  void onTipoCompraChanged(String? value) {
    selectedTipoCompra = value;
    notifyListeners();
  }

  Future<void> onAnimalSexoChanged(int value) async {
    final request = ++_animalListLoadRequest;
    selectedAnimalSexo = value;
    selectedAnimalCategoryId = null;
    selectedAnimalSubcategoryId = null;
    selectedAnimalBaseRacialId = null;
    _getListController.clear();
    notifyListeners();
    try {
      await _getListController.load(value);
      if (request != _animalListLoadRequest) {
        return;
      }
      _cacheAnimalLabelsFromCurrentLists();
      _syncAnimalCategory();
      notifyListeners();
    } catch (_) {}
  }

  void onAnimalCategoryChanged(int? value) {
    selectedAnimalCategoryId = value;
    if (!shouldShowAnimalSubcategory) {
      selectedAnimalSubcategoryId = null;
    }
    notifyListeners();
  }

  void onAnimalSubcategoryChanged(int? value) {
    selectedAnimalSubcategoryId = shouldShowAnimalSubcategory ? value : null;
    notifyListeners();
  }

  void onAnimalBaseRacialChanged(int? value) {
    selectedAnimalBaseRacialId = value;
    notifyListeners();
  }

  PageActionResult addAnimal({
    required String brinco,
    required String pesoTotal,
  }) {
    final categoryId = selectedAnimalCategoryId;
    final normalizedBrinco = brinco.trim();
    final normalizedPeso = _normalizePeso(pesoTotal);

    if (categoryId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione a categoria do animal.',
      );
    }
    if (normalizedBrinco.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o brinco do animal.',
      );
    }
    if (normalizedPeso.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o peso total do animal.',
      );
    }

    _animais = [
      ..._animais,
      CompraUpsertAnimalEntity(
        appAnimaisCategoriasId: categoryId,
        appAnimaisSubcategoriasId: shouldShowAnimalSubcategory
            ? selectedAnimalSubcategoryId
            : null,
        utBasesRaciaisId: selectedAnimalBaseRacialId,
        sexo: selectedAnimalSexo,
        brinco: normalizedBrinco,
        pesoTotal: normalizedPeso,
      ),
    ];
    notifyListeners();
    return const PageActionResult(
      isSuccess: true,
      message: 'Animal adicionado.',
    );
  }

  PageActionResult addAnimalEntity(CompraUpsertAnimalEntity animal) {
    if (animal.brinco.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o brinco do animal.',
      );
    }
    if (animal.pesoTotal.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o peso total do animal.',
      );
    }

    _animais = [..._animais, animal];
    notifyListeners();
    return const PageActionResult(
      isSuccess: true,
      message: 'Animal adicionado.',
    );
  }

  void updateAnimal(int index, CompraUpsertAnimalEntity animal) {
    if (index < 0 || index >= _animais.length) {
      return;
    }
    final copy = [..._animais];
    copy[index] = animal;
    _animais = copy;
    notifyListeners();
  }

  void removeAnimal(int index) {
    if (index < 0 || index >= _animais.length) {
      return;
    }
    final copy = [..._animais]..removeAt(index);
    _animais = copy;
    notifyListeners();
  }

  String animalCategoryLabel(int id) {
    return _animalCategoryLabels[id] ?? 'Categoria $id';
  }

  String? animalSubcategoryLabel(int? id) {
    if (id == null) {
      return null;
    }
    return _animalSubcategoryLabels[id] ?? 'Subcategoria $id';
  }

  String? animalBaseRacialLabel(int? id) {
    if (id == null) {
      return null;
    }
    return _animalBaseRacialLabels[id] ?? 'Base racial $id';
  }

  Future<PageActionResult> submit() async {
    final validation = _validateForm();
    if (validation != null) {
      return validation;
    }

    final entity = CompraUpsertEntity(
      id: _editingCompra?.id,
      appPotreirosId: selectedPotreiroId!,
      appAnimaisLotesId: selectedLotId!,
      data: dataController.text.trim(),
      tipoCompra: selectedTipoCompra!,
      valorUnitario: valorUnitarioController.text.trim(),
      fornecedor: _emptyToNull(fornecedorController.text),
      municipio: _emptyToNull(municipioController.text),
      obs: _emptyToNull(obsController.text),
      animais: isEdit ? const [] : _animais,
    );

    try {
      final result = isEdit
          ? await _editController.submit(entity)
          : await _addController.submit(entity);
      if (result == null) {
        return PageActionResult(
          isSuccess: false,
          message: isEdit
              ? 'Não foi possível atualizar a compra.'
              : 'Não foi possível salvar a compra.',
        );
      }
      return PageActionResult(
        isSuccess: result.isSuccess,
        message: result.message,
      );
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message:
            errorMessage ??
            (isEdit
                ? 'Não foi possível atualizar a compra.'
                : 'Não foi possível salvar a compra.'),
      );
    }
  }

  PageActionResult? _validateForm() {
    if (selectedPotreiroId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o potreiro.',
      );
    }
    if (selectedLotId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o lote.',
      );
    }
    if (dataController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data da compra.',
      );
    }
    if (selectedTipoCompra == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o tipo de compra.',
      );
    }
    if (valorUnitarioController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o valor unitário.',
      );
    }
    if (!isEdit && _animais.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Adicione pelo menos um animal.',
      );
    }
    return null;
  }

  void _syncAnimalCategory() {
    if (animalCategories.isEmpty) {
      selectedAnimalCategoryId = null;
      selectedAnimalSubcategoryId = null;
      selectedAnimalBaseRacialId = null;
      return;
    }
    if (!animalCategories.any((item) => item.id == selectedAnimalCategoryId)) {
      selectedAnimalCategoryId = animalCategories.first.id;
    }
    if (!basesRaciais.any((item) => item.id == selectedAnimalBaseRacialId)) {
      selectedAnimalBaseRacialId = basesRaciais.isEmpty
          ? null
          : basesRaciais.first.id;
    }
    if (!shouldShowAnimalSubcategory) {
      selectedAnimalSubcategoryId = null;
    }
  }

  void _cacheAnimalLabelsFromCurrentLists() {
    final result = _getListController.result;
    if (result == null) {
      return;
    }
    for (final category in result.animaisCategorias) {
      _animalCategoryLabels[category.id] = category.nome.trim();
      for (final subcategory in category.subcategorias) {
        _animalSubcategoryLabels[subcategory.id] = subcategory.nome.trim();
      }
    }
    for (final base in result.animaisBasesRaciais) {
      _animalBaseRacialLabels[base.id] = base.nome.trim();
    }
  }

  String _normalizePeso(String value) {
    return value.trim().replaceAll(',', '.').replaceAll('kg', '').trim();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  void dispose() {
    _addController.removeListener(notifyListeners);
    _editController.removeListener(notifyListeners);
    _getListController.removeListener(notifyListeners);
    _lotsController.removeListener(notifyListeners);
    _potreirosController.removeListener(notifyListeners);
    dataController.dispose();
    valorUnitarioController.dispose();
    fornecedorController.dispose();
    municipioController.dispose();
    obsController.dispose();
    super.dispose();
  }
}
