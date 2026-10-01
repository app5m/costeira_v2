import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_list_item.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/controllers/add_transferencia_fazenda_controller.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/controllers/edit_transferencia_fazenda_controller.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

enum TransferenciaFazendaEscopo { loteInteiro, parcial }

class TransferenciaFazendaFormPageController extends ChangeNotifier {
  TransferenciaFazendaFormPageController(
    this._addController,
    this._editController,
    this._animalsController,
    this._potreirosController,
    this._lotsController,
    this._getListController,
    this._getFazendasUsecase,
    this._resolveCurrentFarmId,
  ) {
    _addController.addListener(notifyListeners);
    _editController.addListener(notifyListeners);
    _animalsController.addListener(notifyListeners);
    _potreirosController.addListener(notifyListeners);
    _lotsController.addListener(notifyListeners);
    _getListController.addListener(notifyListeners);
    dataController.addListener(notifyListeners);
    gtaController.addListener(notifyListeners);
  }

  static const idCategoria = 9;

  final AddTransferenciaFazendaController _addController;
  final EditTransferenciaFazendaController _editController;
  final ListAnimalsController _animalsController;
  final ListPotreirosController _potreirosController;
  final ListAnimalLotsController _lotsController;
  final GetListController _getListController;
  final GetFazendasUsecase _getFazendasUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  final TextEditingController dataController = TextEditingController();
  final TextEditingController gtaController = TextEditingController();

  TransferenciaFazendaListItem? editing;

  bool get isEdit => editing != null;

  List<ListCategoryEntity> _allCategories = const [];
  List<FazendaEntity> fazendasDestino = const [];
  int? originFarmId;
  int? selectedDestinoId;
  int? selectedPotreiroId;
  int? selectedLotId;
  int? selectedCategoryId;
  int? selectedSubcategoryId;
  final Set<String> selectedStatuses = {};
  TransferenciaFazendaEscopo escopo = TransferenciaFazendaEscopo.loteInteiro;
  final Set<int> _parcialSelectedIds = {};

  bool get isLoading =>
      _addController.isLoading ||
      _editController.isLoading ||
      _animalsController.isLoading ||
      _potreirosController.isLoading ||
      _lotsController.isLoading ||
      _getListController.isLoading;
  String? get errorMessage =>
      _editController.errorMessage ??
      _addController.errorMessage ??
      _animalsController.errorMessage ??
      _lotsController.errorMessage ??
      _potreirosController.errorMessage;
  List<AnimalEntity> get animais => _animalsController.animals;
  List<PotreiroEntity> get potreiros => _potreirosController.potreiros;
  bool get isLoteInteiro => escopo == TransferenciaFazendaEscopo.loteInteiro;
  bool get canShowEscopo => selectedPotreiroId != null && selectedLotId != null;

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

  FazendaEntity? get selectedDestino {
    for (final farm in fazendasDestino) {
      if (farm.id == selectedDestinoId) {
        return farm;
      }
    }
    return null;
  }

  String get selectedDestinoDocumento {
    final farm = selectedDestino;
    if (farm != null) {
      if (farm.cnpj.trim().isNotEmpty) {
        return farm.cnpj.trim();
      }
      return farm.documento.trim();
    }
    final saved = editing?.fazendaDestino;
    if (saved != null && saved.id == selectedDestinoId) {
      return saved.cnpj.trim();
    }
    return '';
  }

  String get custoPorAnimalLabel => 'R\$ 0,00';
  String get custoTotalLabel => 'R\$ 0,00';

  bool get isFormValid {
    final base =
        dataController.text.trim().isNotEmpty && selectedDestinoId != null;
    if (isEdit) {
      return base && (editing?.id ?? 0) > 0;
    }
    return base && canShowEscopo && scopedAnimals.isNotEmpty;
  }

  Future<void> init({TransferenciaFazendaListItem? item}) async {
    editing = item;
    if (item != null) {
      dataController.text = item.data;
      gtaController.text = item.gtaDocumento ?? '';
      final destinoId = item.appFazendasIdDest > 0
          ? item.appFazendasIdDest
          : item.fazendaDestino?.id;
      selectedDestinoId = destinoId;
    } else {
      dataController.text = _formatDate(DateTime.now());
    }
    try {
      final user = await SessionStorage.getUserSession();
      originFarmId = item != null && item.appFazendasId > 0
          ? item.appFazendasId
          : await _resolveCurrentFarmId(userId: user?.id);
      if (isEdit) {
        await _loadDestinos(user?.id);
      } else {
        await Future.wait([
          _potreirosController.load(),
          _lotsController.load(),
          _loadCategories(),
          _animalsController.load(brincoOnly: true),
          _loadDestinos(user?.id),
        ]);
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _loadDestinos(int? userId) async {
    if (userId == null || originFarmId == null) {
      fazendasDestino = const [];
      return;
    }
    final result = await _getFazendasUsecase(
      FazendaFilterEntity(
        appUsersId: userId,
        id: originFarmId,
        mesmoTitular: true,
      ),
    );
    fazendasDestino = result.data
        .where((farm) => farm.id != originFarmId)
        .toList(growable: false);
  }

  void onDestinoChanged(int? value) {
    selectedDestinoId = value;
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

  void onEscopoChanged(TransferenciaFazendaEscopo value) {
    escopo = value;
    notifyListeners();
  }

  bool isParcialSelected(int animalId) => _parcialSelectedIds.contains(animalId);

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

  Future<PageActionResult> submit() async {
    final destino = selectedDestinoId;
    if (dataController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data da transferencia.',
      );
    }
    if (destino == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione a fazenda de destino.',
      );
    }
    if (isEdit) {
      return _submitEdit(destino);
    }
    if (selectedPotreiroId == null || selectedLotId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o piquete e o lote.',
      );
    }
    if (scopedAnimals.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione pelo menos um animal.',
      );
    }

    final gta = gtaController.text.trim();
    final entity = TransferenciaFazendaUpsertEntity(
      appFazendasId: originFarmId,
      idCategoria: idCategoria,
      idFazendaDestino: destino,
      valorUnitario: custoPorAnimalLabel,
      valorTotal: custoTotalLabel,
      data: dataController.text.trim(),
      gtaDocumento: gta.isEmpty ? null : gta,
      animais: scopedAnimals
          .map((animal) => TransferenciaFazendaAnimalEntity(id: animal.id))
          .toList(growable: false),
    );

    return _runSubmit(() => _addController.submit(entity));
  }

  Future<PageActionResult> _submitEdit(int destino) async {
    final current = editing;
    if (current == null || current.id <= 0) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Transferencia sem id para atualizar.',
      );
    }
    final origem = current.appFazendasId > 0
        ? current.appFazendasId
        : current.fazendaOrigem?.id ?? originFarmId;
    final gta = gtaController.text.trim();
    final entity = TransferenciaFazendaUpsertEntity(
      id: current.id,
      appFazendasId: origem,
      idCategoria: idCategoria,
      idFazendaOrigem: origem,
      idFazendaDestino: destino,
      valorUnitario: current.valorUnitario,
      valorTotal: current.valorTotal,
      data: dataController.text.trim(),
      gtaDocumento: gta.isEmpty ? null : gta,
    );
    return _runSubmit(() => _editController.submit(entity));
  }

  Future<PageActionResult> _runSubmit(
    Future<ApiMessage?> Function() submit,
  ) async {
    try {
      final result = await submit();
      if (result == null) {
        return PageActionResult(
          isSuccess: false,
          message: errorMessage ?? 'Nao foi possivel salvar a transferencia.',
        );
      }
      return PageActionResult(
        isSuccess: result.isSuccess,
        message: result.message,
      );
    } catch (_) {
      return PageActionResult(
        isSuccess: false,
        message: errorMessage ?? 'Nao foi possivel salvar a transferencia.',
      );
    }
  }

  List<AnimalEntity> _animalsMatching({bool ignoreStatus = false}) {
    return animais.where((animal) {
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
    }).toList(growable: false);
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

  @override
  void dispose() {
    _addController.removeListener(notifyListeners);
    _editController.removeListener(notifyListeners);
    _animalsController.removeListener(notifyListeners);
    _potreirosController.removeListener(notifyListeners);
    _lotsController.removeListener(notifyListeners);
    _getListController.removeListener(notifyListeners);
    dataController.dispose();
    gtaController.dispose();
    super.dispose();
  }
}
