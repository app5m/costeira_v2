import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/core/offline/cache/form_dependencies_cache_service.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_entity.dart';
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
    brincoCriaController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
    animalFilterController.addListener(notifyListeners);
  }

  static const int sexoMacho = 1;
  static const int sexoFemea = 2;

  final AddNascimentoController _addController;
  final EditNascimentoController _editController;
  final ListAnimalsController _animalsController;
  final ListAnimalLotsController _lotsController;
  final ListPotreirosController _potreirosController;
  final FormDependenciesCacheService _formDependenciesCacheService;

  final TextEditingController dataController = TextEditingController();
  final TextEditingController pesoController = TextEditingController();
  final TextEditingController brincoCriaController = TextEditingController();
  final TextEditingController obsController = TextEditingController();
  final TextEditingController animalFilterController = TextEditingController();

  NascimentoEntity? _editingNascimento;
  List<AnimalEntity> _prenheNoPotreiro = const [];
  List<AnimalEntity> _maes = const [];
  int? selectedPotreiroId;
  int? selectedLotId;
  int? selectedMaeId;
  int? selectedSexoCria;
  int? destPotreiroId;
  int? destLotId;
  int _listRequest = 0;
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
  List<AnimalLotEntity> get allLots => _lotsController.lots;
  List<PotreiroEntity> get potreiros => _potreirosController.potreiros;
  List<AnimalEntity> get maes => _maes;
  NascimentoEntity? get editingNascimento => _editingNascimento;

  List<AnimalEntity> get filteredAnimais {
    final filter = animalFilterController.text.trim().toLowerCase();
    if (filter.isEmpty) {
      return maes;
    }
    return maes
        .where((animal) => (animal.brinco ?? '').toLowerCase().contains(filter))
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
    final source = isEdit ? allLots : eligibleLots;
    for (final lot in source) {
      if (lot.id == selectedLotId) {
        return lot;
      }
    }
    return null;
  }

  List<AnimalLotEntity> get eligibleLots {
    if (selectedPotreiroId == null) {
      return const [];
    }
    final ids = <int>{};
    for (final animal in _prenheNoPotreiro) {
      final id = animal.appAnimaisLotesId ?? animal.lote?.id;
      if (id != null) {
        ids.add(id);
      }
    }
    final known = {for (final lot in allLots) lot.id: lot};
    final result = <AnimalLotEntity>[];
    for (final id in ids) {
      result.add(
        known[id] ?? AnimalLotEntity(id: id, appUsersId: 0, nome: _lotName(id)),
      );
    }
    result.sort((a, b) => a.nome.compareTo(b.nome));
    return result;
  }

  List<AnimalLotEntity> get destinationLots {
    final potreiroId = destPotreiroId ?? selectedPotreiroId;
    if (potreiroId == null) {
      return allLots;
    }
    return allLots
        .where(
          (lot) =>
              lot.appPotreirosId == null || lot.appPotreirosId == potreiroId,
        )
        .toList(growable: false);
  }

  String get selectedPotreiroLabel =>
      selectedPotreiro?.nome ??
      _editingNascimento?.potreiro?.nome ??
      'Selecionar piquete';

  String get selectedLotLabel {
    if (isEdit) {
      return selectedLot?.nome ??
          _editingNascimento?.lote?.nome ??
          'Selecionar lote';
    }
    if (selectedPotreiroId == null) {
      return 'Selecione o piquete primeiro';
    }
    if (eligibleLots.isEmpty && !isLoading) {
      return 'Nenhum lote com fêmea prenhe';
    }
    return selectedLot?.nome ?? 'Selecionar lote';
  }

  AnimalEntity? get selectedMae {
    final id = selectedMaeId;
    if (id == null) {
      return null;
    }
    for (final animal in maes) {
      if (animal.id == id) {
        return animal;
      }
    }
    return null;
  }

  String get selectedMaeLabel {
    final brinco = selectedMae?.brinco?.trim();
    if (brinco == null || brinco.isEmpty) {
      return 'Selecionar brinco da mãe';
    }
    return brinco;
  }

  bool get showMaeSelect => !isEdit && selectedLotId != null;
  bool get hasMaes => maes.isNotEmpty;
  bool get showBirthFields => isEdit || (showMaeSelect && hasMaes);

  bool get hasChanges =>
      !isEdit ||
      _initialSnapshot == null ||
      _currentSnapshot() != _initialSnapshot;

  bool get isFormValid {
    if (!hasChanges) {
      return false;
    }
    if (isEdit) {
      return selectedPotreiroId != null &&
          selectedLotId != null &&
          dataController.text.trim().isNotEmpty;
    }
    return selectedPotreiroId != null &&
        selectedLotId != null &&
        selectedMaeId != null &&
        selectedSexoCria != null &&
        dataController.text.trim().isNotEmpty;
  }

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
      dataController.text = _formatDate(DateTime.now());
      _initialSnapshot = null;
    }

    try {
      await _formDependenciesCacheService.preloadNascimentoFormDependencies();
      await Future.wait([_lotsController.load(), _potreirosController.load()]);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> reloadLots() => _lotsController.load();
  Future<void> reloadPotreiros() => _potreirosController.load();
  Future<void> reloadAnimais() => onLotChanged(selectedLotId);

  Future<void> onPotreiroChanged(int? value) async {
    selectedPotreiroId = value;
    selectedLotId = null;
    selectedMaeId = null;
    _maes = const [];
    _prenheNoPotreiro = const [];
    final request = ++_listRequest;
    notifyListeners();
    if (value == null || isEdit) {
      return;
    }
    try {
      await _animalsController.load(
        appPotreirosId: value,
        status: 'prenhe',
        brincoOnly: true,
      );
    } catch (_) {
      if (request == _listRequest) {
        notifyListeners();
      }
      return;
    }
    if (request != _listRequest) {
      return;
    }
    _prenheNoPotreiro = _animalsController.animals
        .where(_isPrenheMae)
        .toList(growable: false);
    notifyListeners();
  }

  Future<void> onLotChanged(int? value) async {
    selectedLotId = value;
    selectedMaeId = null;
    _maes = const [];
    final request = ++_listRequest;
    notifyListeners();
    if (value == null || selectedPotreiroId == null || isEdit) {
      return;
    }
    try {
      await _animalsController.load(
        appPotreirosId: selectedPotreiroId,
        appAnimaisLotesId: value,
        status: 'prenhe',
        brincoOnly: true,
      );
    } catch (_) {
      if (request == _listRequest) {
        notifyListeners();
      }
      return;
    }
    if (request != _listRequest) {
      return;
    }
    _maes = _animalsController.animals
        .where(_isPrenheMae)
        .toList(growable: false);
    notifyListeners();
  }

  void selectMae(AnimalEntity animal) {
    if (isEdit) {
      return;
    }
    selectedMaeId = animal.id;
    notifyListeners();
  }

  bool isMaeSelected(int animalId) => selectedMaeId == animalId;

  void onMaeChanged(int? value) {
    selectedMaeId = value;
    notifyListeners();
  }

  void onSexoCriaChanged(int? value) {
    selectedSexoCria = value;
    notifyListeners();
  }

  void onDestPotreiroChanged(int? value) {
    destPotreiroId = value;
    destLotId = null;
    notifyListeners();
  }

  void onDestLotChanged(int? value) {
    destLotId = value;
    notifyListeners();
  }

  Future<PageActionResult> submit() async {
    final validation = _validateForm();
    if (validation != null) {
      AppLogger.warning(
        'NASCIMENTO FORM PAGE CONTROLLER: FORM INVALIDO potreiro=$selectedPotreiroId lote=$selectedLotId mae=$selectedMaeId',
      );
      return validation;
    }

    final entity = isEdit
        ? NascimentoUpsertEntity(
            id: _editingNascimento?.id,
            appPotreirosId: selectedPotreiroId,
            appAnimaisLotesId: selectedLotId,
            data: dataController.text.trim(),
            pesoTotal: _emptyToNull(_normalizePeso(pesoController.text)),
            obs: _emptyToNull(obsController.text),
          )
        : NascimentoUpsertEntity(
            data: dataController.text.trim(),
            sexo: selectedSexoCria,
            idAnimalMae: selectedMaeId,
            brincoCria: _emptyToNull(brincoCriaController.text),
            pesoTotal: _emptyToNull(_normalizePeso(pesoController.text)),
            obs: _emptyToNull(obsController.text),
            appPotreirosId: destPotreiroId ?? selectedPotreiroId,
            appAnimaisLotesId: destLotId ?? selectedLotId,
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
        message: 'Selecione o piquete.',
      );
    }
    if (selectedLotId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o lote.',
      );
    }
    if (!isEdit && selectedMaeId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o brinco da mãe.',
      );
    }
    if (!isEdit && selectedSexoCria == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o sexo da cria.',
      );
    }
    if (dataController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data do nascimento.',
      );
    }
    return null;
  }

  String _lotName(int id) {
    for (final animal in _prenheNoPotreiro) {
      if (animal.appAnimaisLotesId != id && animal.lote?.id != id) {
        continue;
      }
      final nome = animal.lote?.nome.trim();
      if (nome != null && nome.isNotEmpty) {
        return nome;
      }
    }
    return 'Lote $id';
  }

  bool _isPrenheMae(AnimalEntity animal) {
    final status = animal.status?.trim().toLowerCase();
    if (status != 'prenhe') {
      return false;
    }
    if (animal.sexo != 0 && animal.sexo != sexoFemea) {
      return false;
    }
    return (animal.brinco ?? '').trim().isNotEmpty;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
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
      obs: _emptyToNull(obsController.text),
    );
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
    brincoCriaController.dispose();
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
