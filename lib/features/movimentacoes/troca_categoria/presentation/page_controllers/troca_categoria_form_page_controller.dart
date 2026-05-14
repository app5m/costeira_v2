import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/troca_categoria_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/troca_categoria_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/controllers/add_troca_categoria_controller.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/presentation/controllers/edit_troca_categoria_controller.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

class TrocaCategoriaFormPageController extends ChangeNotifier {
  TrocaCategoriaFormPageController(
    this._addController,
    this._editController,
    this._animalsController,
    this._getListController,
    this._lotsController,
    this._potreirosController,
  ) {
    _addController.addListener(notifyListeners);
    _editController.addListener(notifyListeners);
    _animalsController.addListener(notifyListeners);
    _getListController.addListener(notifyListeners);
    _lotsController.addListener(notifyListeners);
    _potreirosController.addListener(notifyListeners);
    dataController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
    animalFilterController.addListener(notifyListeners);
  }

  final AddTrocaCategoriaController _addController;
  final EditTrocaCategoriaController _editController;
  final ListAnimalsController _animalsController;
  final GetListController _getListController;
  final ListAnimalLotsController _lotsController;
  final ListPotreirosController _potreirosController;

  final TextEditingController dataController = TextEditingController();
  final TextEditingController obsController = TextEditingController();
  final TextEditingController animalFilterController = TextEditingController();

  TrocaCategoriaEntity? _editingTroca;
  int? selectedCategoriaDestinoId;
  int? selectedPotreiroId;
  int? selectedLoteId;
  List<AnimalEntity> _selectedAnimais = const [];
  List<ListCategoryEntity> _categorias = const [];

  bool get isEdit => _editingTroca != null;
  bool get isLoading =>
      _addController.isLoading ||
      _editController.isLoading ||
      _animalsController.isLoading ||
      _getListController.isLoading ||
      _lotsController.isLoading ||
      _potreirosController.isLoading;
  String? get errorMessage =>
      _addController.errorMessage ??
      _editController.errorMessage ??
      _animalsController.errorMessage ??
      _getListController.errorMessage ??
      _lotsController.errorMessage ??
      _potreirosController.errorMessage;

  List<AnimalEntity> get animais => _animalsController.animals;
  List<ListCategoryEntity> get categorias => _categorias;
  List<AnimalLotEntity> get lotes => _lotsController.lots;
  List<PotreiroEntity> get potreiros => _potreirosController.potreiros;
  List<AnimalEntity> get selectedAnimais => _selectedAnimais;

  bool get isFormValid =>
      dataController.text.trim().isNotEmpty &&
      selectedPotreiroId != null &&
      selectedLoteId != null &&
      selectedCategoriaDestinoId != null &&
      (isEdit || _selectedAnimais.isNotEmpty);

  String get selectedPotreiroLabel =>
      _findPotreiroName(selectedPotreiroId) ??
      _editingTroca?.potreiro?.nome ??
      'Selecionar potreiro';
  String get selectedLoteLabel =>
      _findLoteName(selectedLoteId) ??
      _editingTroca?.lote?.nome ??
      'Selecionar lote';
  String get selectedCategoriaDestinoLabel =>
      _findCategoriaName(selectedCategoriaDestinoId) ??
      _editingTroca?.animais.firstOrNull?.catgDestino?.nome ??
      'Selecionar categoria';

  List<AnimalEntity> get filteredAnimais {
    final filter = animalFilterController.text.trim().toLowerCase();
    if (filter.isEmpty) {
      return animais;
    }
    return animais
        .where((animal) {
          final brinco = animal.brinco?.toLowerCase() ?? '';
          return brinco.contains(filter);
        })
        .toList(growable: false);
  }

  Future<void> init({TrocaCategoriaEntity? troca}) async {
    _editingTroca = troca;
    if (troca != null) {
      dataController.text = troca.data;
      obsController.text = troca.obs ?? '';
      selectedPotreiroId = troca.appPotreirosId ?? troca.potreiro?.id;
      selectedLoteId = troca.appAnimaisLotesId ?? troca.lote?.id;
      selectedCategoriaDestinoId = troca.animais.firstOrNull?.catgDestino?.id;
    }

    try {
      await Future.wait([
        _loadCategorias(),
        _lotsController.load(),
        _potreirosController.load(),
        if (!isEdit) _animalsController.load(),
      ]);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> reloadAnimais() => _animalsController.reload();

  Future<void> _loadCategorias() async {
    final categories = <int, ListCategoryEntity>{};
    for (final sexo in const [1, 2]) {
      final result = await _getListController.load(sexo);
      for (final category in result?.animaisCategorias ?? const []) {
        categories[category.id] = category;
      }
    }
    _categorias = categories.values.toList(growable: false);
  }

  void onCategoriaDestinoChanged(int? value) {
    selectedCategoriaDestinoId = value;
    notifyListeners();
  }

  void onPotreiroChanged(int? value) {
    selectedPotreiroId = value;
    notifyListeners();
  }

  void onLoteChanged(int? value) {
    selectedLoteId = value;
    notifyListeners();
  }

  void toggleAnimal(AnimalEntity animal) {
    if (isEdit) {
      return;
    }
    final isSelected = _selectedAnimais.any((item) => item.id == animal.id);
    _selectedAnimais = isSelected
        ? _selectedAnimais
              .where((item) => item.id != animal.id)
              .toList(growable: false)
        : [..._selectedAnimais, animal];
    notifyListeners();
  }

  bool isAnimalSelected(int animalId) {
    return _selectedAnimais.any((item) => item.id == animalId);
  }

  Future<PageActionResult> submit() async {
    final validation = _validateForm();
    if (validation != null) {
      return validation;
    }

    final entity = TrocaCategoriaUpsertEntity(
      id: _editingTroca?.id,
      data: dataController.text.trim(),
      catgDestino: selectedCategoriaDestinoId!,
      appPotreirosId: selectedPotreiroId!,
      appAnimaisLotesId: selectedLoteId!,
      obs: _emptyToNull(obsController.text),
      animais: isEdit
          ? const []
          : _selectedAnimais
                .map(
                  (animal) => TrocaCategoriaUpsertAnimalEntity(id: animal.id),
                )
                .toList(growable: false),
    );

    try {
      final result = isEdit
          ? await _editController.submit(entity)
          : await _addController.submit(entity);
      if (result == null) {
        return PageActionResult(
          isSuccess: false,
          message: isEdit
              ? 'Nao foi possivel atualizar a troca.'
              : 'Nao foi possivel salvar a troca.',
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
                ? 'Nao foi possivel atualizar a troca.'
                : 'Nao foi possivel salvar a troca.'),
      );
    }
  }

  PageActionResult? _validateForm() {
    if (dataController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data da troca.',
      );
    }
    if (selectedPotreiroId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o potreiro.',
      );
    }
    if (selectedLoteId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o lote.',
      );
    }
    if (selectedCategoriaDestinoId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione a categoria de destino.',
      );
    }
    if (!isEdit && _selectedAnimais.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione pelo menos um animal.',
      );
    }
    return null;
  }

  String? _findPotreiroName(int? id) {
    if (id == null) return null;
    try {
      return potreiros.firstWhere((item) => item.id == id).nome;
    } catch (_) {
      return null;
    }
  }

  String? _findLoteName(int? id) {
    if (id == null) return null;
    try {
      return lotes.firstWhere((item) => item.id == id).nome;
    } catch (_) {
      return null;
    }
  }

  String? _findCategoriaName(int? id) {
    if (id == null) return null;
    try {
      return categorias.firstWhere((item) => item.id == id).nome;
    } catch (_) {
      return null;
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  void dispose() {
    _addController.removeListener(notifyListeners);
    _editController.removeListener(notifyListeners);
    _animalsController.removeListener(notifyListeners);
    _getListController.removeListener(notifyListeners);
    _lotsController.removeListener(notifyListeners);
    _potreirosController.removeListener(notifyListeners);
    dataController.dispose();
    obsController.dispose();
    animalFilterController.dispose();
    super.dispose();
  }
}
