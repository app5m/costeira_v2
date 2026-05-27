import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/aborto_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/abortos/domain/entities/aborto_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abortos/presentation/controllers/add_aborto_controller.dart';
import 'package:costeira/features/movimentacoes/abortos/presentation/controllers/edit_aborto_controller.dart';
import 'package:costeira/features/movimentacoes/domain/entities/aborto_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

class AbortoSelectedAnimal {
  const AbortoSelectedAnimal({required this.animal, this.causa});

  final AnimalEntity animal;
  final String? causa;

  AbortoSelectedAnimal copyWith({Object? causa = _keepValue}) {
    return AbortoSelectedAnimal(
      animal: animal,
      causa: causa == _keepValue ? this.causa : causa as String?,
    );
  }
}

const _keepValue = Object();

class AbortoFormPageController extends ChangeNotifier {
  AbortoFormPageController(
    this._addController,
    this._editController,
    this._animalsController,
    this._lotsController,
    this._potreirosController,
  ) {
    _addController.addListener(notifyListeners);
    _editController.addListener(notifyListeners);
    _animalsController.addListener(notifyListeners);
    _lotsController.addListener(notifyListeners);
    _potreirosController.addListener(notifyListeners);
    dataController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
    animalFilterController.addListener(notifyListeners);
  }

  final AddAbortoController _addController;
  final EditAbortoController _editController;
  final ListAnimalsController _animalsController;
  final ListAnimalLotsController _lotsController;
  final ListPotreirosController _potreirosController;

  final TextEditingController dataController = TextEditingController();
  final TextEditingController obsController = TextEditingController();
  final TextEditingController animalFilterController = TextEditingController();

  AbortoEntity? _editingAborto;
  int? selectedPotreiroId;
  int? selectedLotId;
  List<AbortoSelectedAnimal> _selectedAnimais = const [];

  bool get isEdit => _editingAborto != null;
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
  List<AbortoSelectedAnimal> get selectedAnimais => _selectedAnimais;

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
      _editingAborto?.potreiro?.nome ??
      'Selecionar potreiro';
  String get selectedLotLabel =>
      selectedLot?.nome ?? _editingAborto?.lote?.nome ?? 'Selecionar lote';

  List<AnimalEntity> get filteredAnimais {
    final filter = animalFilterController.text.trim().toLowerCase();
    final animaisDoLote = selectedLotId == null
        ? animais
        : animais
              .where((animal) => _animalLotId(animal) == selectedLotId)
              .toList(growable: false);
    if (filter.isEmpty) {
      return animaisDoLote;
    }
    return animaisDoLote
        .where((animal) {
          final brinco = animal.brinco?.toLowerCase() ?? '';
          final peso = animal.peso?.toString() ?? '';
          final lote = animal.lote?.nome.toLowerCase() ?? '';
          return brinco.contains(filter) ||
              peso.contains(filter) ||
              lote.contains(filter);
        })
        .toList(growable: false);
  }

  bool get isFormValid =>
      selectedPotreiroId != null &&
      selectedLotId != null &&
      dataController.text.trim().isNotEmpty &&
      (isEdit || _selectedAnimais.isNotEmpty);

  Future<void> init({AbortoEntity? aborto}) async {
    _editingAborto = aborto;
    if (aborto != null) {
      dataController.text = aborto.data;
      obsController.text = aborto.obs ?? '';
      selectedPotreiroId = aborto.appPotreirosId ?? aborto.potreiro?.id;
      selectedLotId = aborto.appAnimaisLotesId ?? aborto.lote?.id;
    }

    try {
      await Future.wait([
        _lotsController.load(),
        _potreirosController.load(),
        _animalsController.load(),
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

  Future<void> onLotChanged(int? value) async {
    selectedLotId = value;
    _selectedAnimais = _selectedAnimais
        .where((item) => _animalLotId(item.animal) == value)
        .toList(growable: false);
    notifyListeners();
    if (_animalsController.currentFilter == null) {
      try {
        await _animalsController.load();
      } catch (_) {}
    }
    notifyListeners();
  }

  bool isAnimalSelected(int animalId) {
    return _selectedAnimais.any((item) => item.animal.id == animalId);
  }

  void toggleAnimal(AnimalEntity animal) {
    if (isEdit) {
      return;
    }
    if (isAnimalSelected(animal.id)) {
      _selectedAnimais = _selectedAnimais
          .where((item) => item.animal.id != animal.id)
          .toList(growable: false);
    } else {
      _selectedAnimais = [
        ..._selectedAnimais,
        AbortoSelectedAnimal(animal: animal),
      ];
    }
    notifyListeners();
  }

  void setAnimalCausa(int animalId, String? causa) {
    final trimmed = causa?.trim();
    _selectedAnimais = _selectedAnimais
        .map((item) {
          if (item.animal.id != animalId) {
            return item;
          }
          return item.copyWith(
            causa: trimmed == null || trimmed.isEmpty ? null : trimmed,
          );
        })
        .toList(growable: false);
    notifyListeners();
  }

  String? animalCausa(int animalId) {
    try {
      return _selectedAnimais
          .firstWhere((item) => item.animal.id == animalId)
          .causa;
    } catch (_) {
      return null;
    }
  }

  Future<PageActionResult> submit() async {
    final validation = _validateForm();
    if (validation != null) {
      return validation;
    }

    final entity = AbortoUpsertEntity(
      id: _editingAborto?.id,
      appPotreirosId: selectedPotreiroId!,
      appAnimaisLotesId: selectedLotId!,
      data: dataController.text.trim(),
      obs: _emptyToNull(obsController.text),
      animais: isEdit
          ? const []
          : _selectedAnimais
                .map(
                  (item) => AbortoUpsertAnimalEntity(
                    id: item.animal.id,
                    causa: item.causa,
                  ),
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
              ? 'Nao foi possivel atualizar o aborto.'
              : 'Nao foi possivel salvar o aborto.',
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
                ? 'Nao foi possivel atualizar o aborto.'
                : 'Nao foi possivel salvar o aborto.'),
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
        message: 'Informe a data do aborto.',
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

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  int? _animalLotId(AnimalEntity animal) {
    return animal.appAnimaisLotesId ?? animal.lote?.id;
  }

  @override
  void dispose() {
    _addController.removeListener(notifyListeners);
    _editController.removeListener(notifyListeners);
    _animalsController.removeListener(notifyListeners);
    _lotsController.removeListener(notifyListeners);
    _potreirosController.removeListener(notifyListeners);
    dataController.dispose();
    obsController.dispose();
    animalFilterController.dispose();
    super.dispose();
  }
}
