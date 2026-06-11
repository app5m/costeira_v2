import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/core/offline/cache/form_dependencies_cache_service.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_upsert_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/add_animal_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

class AnimalAddPageController extends ChangeNotifier {
  AnimalAddPageController(
    this._controller,
    this._getListController,
    this._lotsController,
    this._potreirosController,
    this._formDependenciesCacheService,
  ) {
    _controller.addListener(notifyListeners);
    _getListController.addListener(notifyListeners);
    _lotsController.addListener(notifyListeners);
    _potreirosController.addListener(notifyListeners);
    brincoController.addListener(notifyListeners);
    pesoController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
  }

  static const int matrixCategoryId = 10;
  static const List<String> animalStatuses = [
    'parida',
    'prenhe',
    'vazia',
    'descarte',
    'engorda',
  ];

  final AddAnimalController _controller;
  final GetListController _getListController;
  final ListAnimalLotsController _lotsController;
  final ListPotreirosController _potreirosController;
  final FormDependenciesCacheService _formDependenciesCacheService;

  final TextEditingController brincoController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController obsController = TextEditingController();

  int? selectedSexo;
  int? selectedCategoryId;
  int? selectedSubcategoryId;
  int? selectedBaseRacialId;
  int? selectedLotId;
  int? selectedPotreiroId;
  String? selectedStatus;

  bool get isLoading =>
      _controller.isLoading ||
      _getListController.isLoading ||
      _lotsController.isLoading ||
      _potreirosController.isLoading;
  String? get errorMessage =>
      _getListController.errorMessage ?? _potreirosController.errorMessage;

  List<ListCategoryEntity> get categories =>
      _getListController.result?.animaisCategorias ?? const [];

  List<ListSubcategoryEntity> get subcategories {
    final category = categories.cast<ListCategoryEntity?>().firstWhere(
      (item) => item?.id == selectedCategoryId,
      orElse: () => null,
    );
    return category?.subcategorias ?? const [];
  }

  List<ListItemEntity> get basesRaciais =>
      _getListController.result?.animaisBasesRaciais ?? const [];
  List<AnimalLotEntity> get lots => _lotsController.lots;
  List<PotreiroEntity> get potreiros => _potreirosController.potreiros;

  AnimalLotEntity? get selectedLot {
    try {
      return lots.firstWhere((item) => item.id == selectedLotId);
    } catch (_) {
      return null;
    }
  }

  String get selectedLotLabel => selectedLot?.nome ?? 'Selecionar lote';
  PotreiroEntity? get selectedPotreiro {
    try {
      return potreiros.firstWhere((item) => item.id == selectedPotreiroId);
    } catch (_) {
      return null;
    }
  }

  String get selectedPotreiroLabel =>
      selectedPotreiro?.nome ?? 'Selecionar potreiro';
  bool get requiresSubcategory =>
      selectedSexo == 2 && selectedCategoryId == matrixCategoryId;
  bool get shouldShowStatusField =>
      selectedSexo == 2 &&
      selectedCategoryId == matrixCategoryId &&
      selectedSubcategoryId != null;
  bool get isFormValid =>
      selectedSexo != null &&
      selectedCategoryId != null &&
      (!requiresSubcategory || selectedSubcategoryId != null);

  Future<void> init() async {
    AppLogger.info(
      'ANIMAIS ADD PAGE CONTROLLER: CARREGANDO DADOS PARA SEXO=$selectedSexo',
    );
    _getListController.clear();
    try {
      await _formDependenciesCacheService.preloadAnimalFormDependencies();
      await Future.wait([_lotsController.load(), _potreirosController.load()]);
      notifyListeners();
    } catch (_) {
      AppLogger.error('ANIMAIS ADD PAGE CONTROLLER: ERRO AO CARREGAR DADOS');
    }
  }

  Future<void> _loadListsForSexo(int sexo) async {
    AppLogger.info(
      'ANIMAIS ADD PAGE CONTROLLER: CARREGANDO LISTAS PARA SEXO=$sexo',
    );
    try {
      await _getListController.load(sexo);
      _syncSelectedCategory();
      notifyListeners();
    } catch (_) {
      AppLogger.error('ANIMAIS ADD PAGE CONTROLLER: ERRO AO CARREGAR LISTAS');
    }
  }

  Future<void> reloadLots() async {
    await _lotsController.load();
  }

  Future<void> reloadPotreiros() async {
    await _potreirosController.load();
  }

  void onSexoChanged(int value) {
    selectedSexo = value;
    selectedCategoryId = null;
    selectedSubcategoryId = null;
    selectedBaseRacialId = null;
    _getListController.clear();
    _syncStatusVisibility();
    notifyListeners();
    _loadListsForSexo(value);
  }

  void onCategoryChanged(int? value) {
    selectedCategoryId = value;
    selectedSubcategoryId = null;
    _syncStatusVisibility();
    notifyListeners();
  }

  void onSubcategoryChanged(int? value) {
    selectedSubcategoryId = value;
    _syncStatusVisibility();
    notifyListeners();
  }

  void onBaseRacialChanged(int? value) {
    selectedBaseRacialId = value;
    notifyListeners();
  }

  void onLotChanged(int? value) {
    selectedLotId = value;
    notifyListeners();
  }

  void onPotreiroChanged(int? value) {
    selectedPotreiroId = value;
    notifyListeners();
  }

  void onStatusChanged(String? value) {
    selectedStatus = value;
    notifyListeners();
  }

  Future<PageActionResult> submit() async {
    final sexo = selectedSexo;
    if (sexo == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o sexo do animal.',
      );
    }

    final categoryId = selectedCategoryId;
    if (categoryId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione a categoria do animal.',
      );
    }
    if (requiresSubcategory && selectedSubcategoryId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione a subcategoria da matriz.',
      );
    }

    try {
      final result = await _controller.submit(
        AnimalUpsertEntity(
          appAnimaisCategoriasId: categoryId,
          appAnimaisSubcategoriasId: selectedSubcategoryId,
          utBasesRaciaisId: selectedBaseRacialId,
          appAnimaisLotesId: selectedLotId,
          appPotreirosId: selectedPotreiroId,
          sexo: sexo,
          brinco: _emptyToNull(brincoController.text),
          peso: _normalizePeso(pesoController.text),
          obs: _emptyToNull(obsController.text),
          status: shouldShowStatusField ? selectedStatus : null,
        ),
      );

      if (result == null) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Nao foi possivel salvar o animal.',
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
            _controller.errorMessage ?? 'Nao foi possivel salvar o animal.',
      );
    }
  }

  void _syncSelectedCategory() {
    if (categories.isEmpty) {
      selectedCategoryId = null;
      selectedSubcategoryId = null;
      selectedBaseRacialId = null;
      _syncStatusVisibility();
      return;
    }

    if (selectedCategoryId != null &&
        !categories.any((item) => item.id == selectedCategoryId)) {
      selectedCategoryId = null;
    }

    if (!requiresSubcategory || subcategories.isEmpty) {
      selectedSubcategoryId = null;
    } else if (!subcategories.any((item) => item.id == selectedSubcategoryId)) {
      selectedSubcategoryId = null;
    }

    if (basesRaciais.isEmpty) {
      selectedBaseRacialId = null;
    } else if (selectedBaseRacialId != null &&
        !basesRaciais.any((item) => item.id == selectedBaseRacialId)) {
      selectedBaseRacialId = null;
    }

    _syncStatusVisibility();
  }

  void _syncStatusVisibility() {
    if (!shouldShowStatusField) {
      selectedStatus = null;
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
  void dispose() {
    _controller.removeListener(notifyListeners);
    _getListController.removeListener(notifyListeners);
    _lotsController.removeListener(notifyListeners);
    _potreirosController.removeListener(notifyListeners);
    brincoController.removeListener(notifyListeners);
    pesoController.removeListener(notifyListeners);
    obsController.removeListener(notifyListeners);
    brincoController.dispose();
    pesoController.dispose();
    obsController.dispose();
    super.dispose();
  }
}
