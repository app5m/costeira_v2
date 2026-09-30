import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/domain/entities/morte_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/controllers/add_morte_controller.dart';
import 'package:costeira/features/movimentacoes/mortes/presentation/controllers/edit_morte_controller.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

enum MorteEscopo { loteInteiro, parcial }

class MorteTipoBaixa {
  const MorteTipoBaixa({required this.id, required this.nome});

  final int id;
  final String nome;
}

class MorteFormPageController extends ChangeNotifier {
  MorteFormPageController(
    this._addController,
    this._editController,
    this._animalsController,
    this._potreirosController,
    this._lotsController,
    this._getListController,
  ) {
    _addController.addListener(notifyListeners);
    _editController.addListener(notifyListeners);
    _animalsController.addListener(notifyListeners);
    _potreirosController.addListener(notifyListeners);
    _lotsController.addListener(notifyListeners);
    _getListController.addListener(notifyListeners);
    dataController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
    animalFilterController.addListener(notifyListeners);
  }

  static const tipos = [
    MorteTipoBaixa(id: 3, nome: 'Morte'),
    MorteTipoBaixa(id: 6, nome: 'Abigeato'),
    MorteTipoBaixa(id: 8, nome: 'Consumo Interno'),
  ];

  final AddMorteController _addController;
  final EditMorteController _editController;
  final ListAnimalsController _animalsController;
  final ListPotreirosController _potreirosController;
  final ListAnimalLotsController _lotsController;
  final GetListController _getListController;

  final TextEditingController dataController = TextEditingController();
  final TextEditingController obsController = TextEditingController();
  final TextEditingController animalFilterController = TextEditingController();

  MorteEntity? _editingMorte;
  List<ListCategoryEntity> _allCategories = const [];
  int idCategoria = 3;
  int? selectedPotreiroId;
  int? selectedLotId;
  int? selectedCategoryId;
  int? selectedSubcategoryId;
  final Set<String> selectedStatuses = {};
  MorteEscopo escopo = MorteEscopo.loteInteiro;
  final Set<int> _parcialSelectedIds = {};
  _MorteFormSnapshot? _initialSnapshot;

  bool get isEdit => _editingMorte != null;
  bool get isLoading =>
      _addController.isLoading ||
      _editController.isLoading ||
      _animalsController.isLoading ||
      _potreirosController.isLoading ||
      _lotsController.isLoading ||
      _getListController.isLoading;
  String? get errorMessage =>
      _addController.errorMessage ??
      _editController.errorMessage ??
      _animalsController.errorMessage ??
      _lotsController.errorMessage ??
      _potreirosController.errorMessage;
  String? get potreiroError => _potreirosController.errorMessage;
  List<AnimalEntity> get animais => _animalsController.animals;
  List<PotreiroEntity> get potreiros => _potreirosController.potreiros;
  bool get isLoteInteiro => escopo == MorteEscopo.loteInteiro;
  bool get canShowEscopo =>
      !isEdit && selectedPotreiroId != null && selectedLotId != null;

  List<ListCategoryEntity> get animalCategories => _allCategories;

  List<ListSubcategoryEntity> get animalSubcategories {
    final category = animalCategories.cast<ListCategoryEntity?>().firstWhere(
      (item) => item?.id == selectedCategoryId,
      orElse: () => null,
    );
    return category?.subcategorias ?? const [];
  }

  bool get hasAnimalSubcategories => animalSubcategories.isNotEmpty;
  bool get canSelectStatus =>
      selectedCategoryId != null &&
      (!hasAnimalSubcategories || selectedSubcategoryId != null);

  List<AnimalLotEntity> get lots {
    final all = _lotsController.lots;
    final potreiroId = selectedPotreiroId;
    if (potreiroId == null) {
      return all;
    }
    return all
        .where(
          (lot) =>
              lot.appPotreirosId == null || lot.appPotreirosId == potreiroId,
        )
        .toList(growable: false);
  }

  List<String> get availableStatuses {
    if (!canSelectStatus) {
      return const [];
    }
    final fromAnimals = _animalsMatching(ignoreStatus: true)
        .map((animal) => animal.status?.trim())
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toSet();
    return fromAnimals.toList(growable: false)..sort();
  }

  bool get hasStatusOptions => availableStatuses.isNotEmpty;

  List<AnimalEntity> get groupedAnimals => _animalsMatching();

  List<AnimalEntity> get scopedAnimals {
    if (isLoteInteiro) {
      return groupedAnimals;
    }
    return groupedAnimals
        .where((animal) => _parcialSelectedIds.contains(animal.id))
        .toList(growable: false);
  }

  List<AnimalEntity> get selectedAnimais => scopedAnimals;

  List<AnimalEntity> get filteredAnimais {
    final filter = animalFilterController.text.trim().toLowerCase();
    final source = groupedAnimals;
    if (filter.isEmpty) {
      return source;
    }
    return source
        .where((animal) => (animal.brinco ?? '').toLowerCase().contains(filter))
        .toList(growable: false);
  }

  bool get allBrincados =>
      groupedAnimals.isNotEmpty &&
      groupedAnimals.every((animal) => (animal.brinco ?? '').trim().isNotEmpty);

  Map<String, int> get categoryCounts {
    final counts = <String, int>{};
    for (final animal in groupedAnimals) {
      final name = (animal.categoria?.nome ?? 'Sem categoria').trim();
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> get faseCounts {
    final counts = <String, int>{};
    for (final animal in groupedAnimals) {
      final name = (animal.subcategoria?.nome ?? '').trim();
      if (name.isEmpty) {
        continue;
      }
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return counts;
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
      selectedPotreiro?.nome ?? 'Todos os piquetes';

  String get selectedLotLabel => selectedLot?.nome ?? 'Selecionar lote';

  bool get hasChanges =>
      !isEdit ||
      _initialSnapshot == null ||
      _currentSnapshot() != _initialSnapshot;

  bool get isFormValid {
    if (dataController.text.trim().isEmpty || !hasChanges) {
      return false;
    }
    if (!tipos.any((tipo) => tipo.id == idCategoria)) {
      return false;
    }
    if (isEdit) {
      return true;
    }
    return canShowEscopo && scopedAnimals.isNotEmpty;
  }

  Future<void> init({MorteEntity? morte}) async {
    _editingMorte = morte;
    if (morte != null) {
      dataController.text = morte.data;
      obsController.text = morte.obs ?? '';
      idCategoria =
          tipos.any((tipo) => tipo.id == morte.appMovimentacoesCategoriasId)
          ? morte.appMovimentacoesCategoriasId
          : 3;
      _initialSnapshot = _currentSnapshot();
    } else {
      dataController.text = _formatDate(DateTime.now());
      idCategoria = 3;
      _initialSnapshot = null;
    }

    try {
      await Future.wait([
        _potreirosController.load(),
        _lotsController.load(),
        _loadCategories(),
        if (!isEdit) _animalsController.load(brincoOnly: true),
      ]);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> reloadPotreiros() => _potreirosController.load();
  Future<void> reloadAnimais() => _animalsController.reload();

  void onTipoChanged(int? value) {
    if (value == null || !tipos.any((tipo) => tipo.id == value)) {
      return;
    }
    idCategoria = value;
    notifyListeners();
  }

  void onPotreiroChanged(int? value) {
    selectedPotreiroId = value;
    if (selectedLotId != null && !lots.any((lot) => lot.id == selectedLotId)) {
      selectedLotId = null;
    }
    _pruneParcial();
    notifyListeners();
  }

  void onLotChanged(int? value) {
    selectedLotId = value;
    _pruneParcial();
    notifyListeners();
  }

  void onCategoryChanged(int? value) {
    selectedCategoryId = value;
    selectedSubcategoryId = null;
    selectedStatuses.clear();
    _pruneParcial();
    notifyListeners();
  }

  void onSubcategoryChanged(int? value) {
    selectedSubcategoryId = hasAnimalSubcategories ? value : null;
    selectedStatuses.clear();
    _pruneParcial();
    notifyListeners();
  }

  void toggleStatus(String status) {
    if (selectedStatuses.contains(status)) {
      selectedStatuses.remove(status);
    } else {
      selectedStatuses.add(status);
    }
    _pruneParcial();
    notifyListeners();
  }

  void onEscopoChanged(MorteEscopo value) {
    escopo = value;
    notifyListeners();
  }

  bool isAnimalSelected(int animalId) => _parcialSelectedIds.contains(animalId);

  bool isParcialSelected(int animalId) => isAnimalSelected(animalId);

  void toggleAnimal(AnimalEntity animal) => toggleParcialAnimal(animal.id);

  void toggleParcialAnimal(int animalId) {
    if (isLoteInteiro) {
      return;
    }
    if (_parcialSelectedIds.contains(animalId)) {
      _parcialSelectedIds.remove(animalId);
    } else {
      _parcialSelectedIds.add(animalId);
    }
    notifyListeners();
  }

  void selectAllParcial() {
    _parcialSelectedIds
      ..clear()
      ..addAll(groupedAnimals.map((animal) => animal.id));
    notifyListeners();
  }

  void clearParcial() {
    _parcialSelectedIds.clear();
    notifyListeners();
  }

  void setAnimalCausa(int animalId, String? causa) {}

  String? animalCausa(int animalId) => null;

  Future<PageActionResult> submit() async {
    final validation = _validateForm();
    if (validation != null) {
      return validation;
    }

    final entity = MorteUpsertEntity(
      id: _editingMorte?.id,
      idCategoria: idCategoria,
      data: dataController.text.trim(),
      obs: _emptyToNull(obsController.text),
      animais: isEdit
          ? const []
          : scopedAnimals
                .map((animal) => MorteUpsertAnimalEntity(id: animal.id))
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
              ? 'Nao foi possivel atualizar a baixa.'
              : 'Nao foi possivel salvar a baixa.',
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
                ? 'Nao foi possivel atualizar a baixa.'
                : 'Nao foi possivel salvar a baixa.'),
      );
    }
  }

  PageActionResult? _validateForm() {
    if (dataController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data da baixa.',
      );
    }
    if (!tipos.any((tipo) => tipo.id == idCategoria)) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o tipo de baixa.',
      );
    }
    if (!isEdit && (selectedPotreiroId == null || selectedLotId == null)) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o piquete e o lote.',
      );
    }
    if (!isEdit && scopedAnimals.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione pelo menos um animal.',
      );
    }
    return null;
  }

  List<AnimalEntity> _animalsMatching({bool ignoreStatus = false}) {
    return animais
        .where((animal) {
          if ((animal.brinco ?? '').trim().isEmpty) {
            return false;
          }
          if (selectedCategoryId != null &&
              animal.appAnimaisCategoriasId != selectedCategoryId) {
            return false;
          }
          if (selectedSubcategoryId != null &&
              animal.appAnimaisSubcategoriasId != selectedSubcategoryId) {
            return false;
          }
          if (!ignoreStatus && selectedStatuses.isNotEmpty) {
            final status = animal.status?.trim();
            if (status == null || !selectedStatuses.contains(status)) {
              return false;
            }
          }
          if (selectedPotreiroId != null &&
              animal.appPotreirosId != selectedPotreiroId) {
            return false;
          }
          if (selectedLotId != null &&
              (animal.appAnimaisLotesId ?? animal.lote?.id) != selectedLotId) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }

  void _pruneParcial() {
    final ids = groupedAnimals.map((animal) => animal.id).toSet();
    _parcialSelectedIds.removeWhere((id) => !ids.contains(id));
  }

  Future<void> _loadCategories() async {
    final categories = <ListCategoryEntity>[];
    try {
      final macho = await _getListController.load(1);
      if (macho != null) {
        categories.addAll(macho.animaisCategorias);
      }
    } catch (_) {}
    try {
      final femea = await _getListController.load(2);
      if (femea != null) {
        categories.addAll(femea.animaisCategorias);
      }
    } catch (_) {}
    _allCategories = categories;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  _MorteFormSnapshot _currentSnapshot() {
    return _MorteFormSnapshot(
      idCategoria: idCategoria,
      data: dataController.text.trim(),
      obs: _emptyToNull(obsController.text),
    );
  }

  @override
  void dispose() {
    _addController.removeListener(notifyListeners);
    _editController.removeListener(notifyListeners);
    _animalsController.removeListener(notifyListeners);
    _potreirosController.removeListener(notifyListeners);
    _lotsController.removeListener(notifyListeners);
    _getListController.removeListener(notifyListeners);
    dataController.dispose();
    obsController.dispose();
    animalFilterController.dispose();
    super.dispose();
  }
}

class _MorteFormSnapshot {
  const _MorteFormSnapshot({
    required this.idCategoria,
    required this.data,
    required this.obs,
  });

  final int idCategoria;
  final String data;
  final String? obs;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _MorteFormSnapshot &&
            other.idCategoria == idCategoria &&
            other.data == data &&
            other.obs == obs;
  }

  @override
  int get hashCode => Object.hash(idCategoria, data, obs);
}
