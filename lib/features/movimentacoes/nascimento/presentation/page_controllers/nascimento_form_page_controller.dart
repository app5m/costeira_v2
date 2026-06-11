import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/core/offline/cache/form_dependencies_cache_service.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/nascimento_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/domain/entities/nascimento_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/controllers/add_nascimento_controller.dart';
import 'package:costeira/features/movimentacoes/nascimento/presentation/controllers/edit_nascimento_controller.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

class NascimentoFormPageController extends ChangeNotifier {
  NascimentoFormPageController(
    this._addController,
    this._editController,
    this._animalsController,
    this._lotsController,
    this._potreirosController,
    this._formDependenciesCacheService,
  ) {
    _addController.addListener(notifyListeners);
    _editController.addListener(notifyListeners);
    _animalsController.addListener(notifyListeners);
    _lotsController.addListener(notifyListeners);
    _potreirosController.addListener(notifyListeners);
    dataController.addListener(notifyListeners);
    pesoController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
    animalFilterController.addListener(notifyListeners);
  }

  static const String tipoMatriz = 'nascimento matriz';
  static const String tipoTerneiro = 'nascimento terneiro';

  final AddNascimentoController _addController;
  final EditNascimentoController _editController;
  final ListAnimalsController _animalsController;
  final ListAnimalLotsController _lotsController;
  final ListPotreirosController _potreirosController;
  final FormDependenciesCacheService _formDependenciesCacheService;

  final TextEditingController dataController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController obsController = TextEditingController();
  final TextEditingController animalFilterController = TextEditingController();

  NascimentoEntity? _editingNascimento;
  AnimalEntity? _selectedMatriz;
  AnimalEntity? _selectedTerneiro;
  int? selectedPotreiroId;
  int? selectedLotId;
  _NascimentoFormSnapshot? _initialSnapshot;

  bool get isEdit => _editingNascimento != null;
  bool get isLoading =>
      _addController.isLoading ||
      _editController.isLoading ||
      _animalsController.isLoading ||
      _lotsController.isLoading ||
      _potreirosController.isLoading;
  String? get errorMessage =>
      _addController.errorMessage ??
      _editController.errorMessage ??
      _animalsController.errorMessage ??
      _lotsController.errorMessage ??
      _potreirosController.errorMessage;
  List<AnimalEntity> get animais => _animalsController.animals;
  List<AnimalLotEntity> get lots => _lotsController.lots;
  List<PotreiroEntity> get potreiros => _potreirosController.potreiros;
  AnimalEntity? get selectedMatriz => _selectedMatriz;
  AnimalEntity? get selectedTerneiro => _selectedTerneiro;
  NascimentoEntity? get editingNascimento => _editingNascimento;

  List<AnimalEntity> get filteredAnimais {
    final filter = animalFilterController.text.trim().toLowerCase();
    if (filter.isEmpty) {
      return animais;
    }
    return animais
        .where((animal) {
          final brinco = animal.brinco?.toLowerCase() ?? '';
          final peso = animal.peso?.toString() ?? '';
          return brinco.contains(filter) || peso.contains(filter);
        })
        .toList(growable: false);
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
      _editingNascimento?.potreiro?.nome ??
      'Selecionar potreiro';
  String get selectedLotLabel =>
      selectedLot?.nome ?? _editingNascimento?.lote?.nome ?? 'Selecionar lote';
  String get selectedMatrizLabel => _selectedMatriz == null
      ? 'Selecionar matriz'
      : _animalLabel(_selectedMatriz!);
  String get selectedTerneiroLabel => _selectedTerneiro == null
      ? 'Selecionar terneiro'
      : _animalLabel(_selectedTerneiro!);

  bool get hasRequiredFields =>
      selectedPotreiroId != null &&
      selectedLotId != null &&
      dataController.text.trim().isNotEmpty;

  bool get canSelectAnimals => hasRequiredFields && !isLoading;

  bool get isFormValid =>
      hasRequiredFields &&
      (isEdit || (_selectedMatriz != null && _selectedTerneiro != null)) &&
      hasChanges;

  String get formValidationDebug =>
      'potreiro=$selectedPotreiroId '
      'lote=$selectedLotId '
      'data="${dataController.text.trim()}" '
      'matriz=${_selectedMatriz?.id} '
      'terneiro=${_selectedTerneiro?.id} '
      'isEdit=$isEdit '
      'hasChanges=$hasChanges '
      'isFormValid=$isFormValid';
  bool get hasChanges =>
      !isEdit ||
      _initialSnapshot == null ||
      _currentSnapshot() != _initialSnapshot;

  Future<void> init({NascimentoEntity? nascimento}) async {
    _editingNascimento = nascimento;
    if (nascimento != null) {
      selectedPotreiroId = nascimento.appPotreirosId ?? nascimento.potreiro?.id;
      selectedLotId = nascimento.appAnimaisLotesId ?? nascimento.lote?.id;
      dataController.text = nascimento.data;
      pesoController.text = nascimento.pesoTotal?.toStringAsFixed(2) ?? '';
      obsController.text = nascimento.obs ?? '';
      _initialSnapshot = _currentSnapshot();
    } else {
      _initialSnapshot = null;
    }

    try {
      await _formDependenciesCacheService.preloadNascimentoFormDependencies();
      await Future.wait([
        _lotsController.load(),
        _potreirosController.load(),
        if (!isEdit) _animalsController.load(),
      ]);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> reloadLots() => _lotsController.load();
  Future<void> reloadPotreiros() => _potreirosController.load();
  Future<void> reloadAnimais() => _animalsController.reload();

  void onPotreiroChanged(int? value) {
    selectedPotreiroId = value;
    notifyListeners();
  }

  void onLotChanged(int? value) {
    selectedLotId = value;
    notifyListeners();
  }

  void selectMatriz(AnimalEntity animal) {
    if (isEdit) {
      return;
    }
    _selectedMatriz = animal;
    if (_selectedTerneiro?.id == animal.id) {
      _selectedTerneiro = null;
    }
    notifyListeners();
  }

  void selectTerneiro(AnimalEntity animal) {
    if (isEdit) {
      return;
    }
    _selectedTerneiro = animal;
    if (_selectedMatriz?.id == animal.id) {
      _selectedMatriz = null;
    }
    notifyListeners();
  }

  bool isMatrizSelected(int animalId) => _selectedMatriz?.id == animalId;
  bool isTerneiroSelected(int animalId) => _selectedTerneiro?.id == animalId;

  Future<PageActionResult> submit() async {
    final validation = _validateForm();
    if (validation != null) {
      AppLogger.warning(
        'NASCIMENTO FORM PAGE CONTROLLER: FORM INVALIDO $formValidationDebug',
      );
      return validation;
    }

    final entity = NascimentoUpsertEntity(
      id: _editingNascimento?.id,
      appPotreirosId: selectedPotreiroId!,
      appAnimaisLotesId: selectedLotId!,
      data: dataController.text.trim(),
      pesoTotal: _emptyToNull(_normalizePeso(pesoController.text)),
      obs: _emptyToNull(obsController.text),
      animais: isEdit
          ? const []
          : [
              NascimentoUpsertAnimalEntity(
                id: _selectedMatriz!.id,
                tipo: tipoMatriz,
              ),
              NascimentoUpsertAnimalEntity(
                id: _selectedTerneiro!.id,
                tipo: tipoTerneiro,
              ),
            ],
    );

    try {
      final result = isEdit
          ? await _editController.submit(entity)
          : await _addController.submit(entity);
      if (result == null) {
        return PageActionResult(
          isSuccess: false,
          message: isEdit
              ? 'Nao foi possivel atualizar o nascimento.'
              : 'Nao foi possivel salvar o nascimento.',
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
                ? 'Nao foi possivel atualizar o nascimento.'
                : 'Nao foi possivel salvar o nascimento.'),
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
        message: 'Informe a data do nascimento.',
      );
    }
    if (!isEdit && _selectedMatriz == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione a matriz.',
      );
    }
    if (!isEdit && _selectedTerneiro == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o terneiro.',
      );
    }
    if (!isEdit && _selectedMatriz?.id == _selectedTerneiro?.id) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione animais diferentes para matriz e terneiro.',
      );
    }
    return null;
  }

  String _animalLabel(AnimalEntity animal) {
    final brinco = animal.brinco?.trim();
    return brinco?.isNotEmpty == true ? brinco! : 'Animal ${animal.id}';
  }

  String _normalizePeso(String value) {
    return value.trim().replaceAll(',', '.').replaceAll('kg', '').trim();
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  _NascimentoFormSnapshot _currentSnapshot() {
    return _NascimentoFormSnapshot(
      selectedPotreiroId: selectedPotreiroId,
      selectedLotId: selectedLotId,
      data: dataController.text.trim(),
      pesoTotal: _normalizePeso(pesoController.text),
      obs: _normalizeOptionalText(obsController.text),
    );
  }

  String? _normalizeOptionalText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  void dispose() {
    _addController.removeListener(notifyListeners);
    _editController.removeListener(notifyListeners);
    _animalsController.removeListener(notifyListeners);
    _lotsController.removeListener(notifyListeners);
    _potreirosController.removeListener(notifyListeners);
    dataController.dispose();
    pesoController.dispose();
    obsController.dispose();
    animalFilterController.dispose();
    super.dispose();
  }
}

class _NascimentoFormSnapshot {
  const _NascimentoFormSnapshot({
    required this.selectedPotreiroId,
    required this.selectedLotId,
    required this.data,
    required this.pesoTotal,
    required this.obs,
  });

  final int? selectedPotreiroId;
  final int? selectedLotId;
  final String data;
  final String pesoTotal;
  final String? obs;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _NascimentoFormSnapshot &&
            other.selectedPotreiroId == selectedPotreiroId &&
            other.selectedLotId == selectedLotId &&
            other.data == data &&
            other.pesoTotal == pesoTotal &&
            other.obs == obs;
  }

  @override
  int get hashCode =>
      Object.hash(selectedPotreiroId, selectedLotId, data, pesoTotal, obs);
}
