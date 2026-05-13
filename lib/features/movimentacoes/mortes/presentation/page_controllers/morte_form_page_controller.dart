import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
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

class MorteSelectedAnimal {
  const MorteSelectedAnimal({required this.animal, this.causa});

  final AnimalEntity animal;
  final String? causa;

  MorteSelectedAnimal copyWith({String? causa}) {
    return MorteSelectedAnimal(animal: animal, causa: causa ?? this.causa);
  }
}

class MorteFormPageController extends ChangeNotifier {
  MorteFormPageController(
    this._addController,
    this._editController,
    this._animalsController,
    this._potreirosController,
  ) {
    _addController.addListener(notifyListeners);
    _editController.addListener(notifyListeners);
    _animalsController.addListener(notifyListeners);
    _potreirosController.addListener(notifyListeners);
    dataController.addListener(notifyListeners);
    animalFilterController.addListener(notifyListeners);
  }

  final AddMorteController _addController;
  final EditMorteController _editController;
  final ListAnimalsController _animalsController;
  final ListPotreirosController _potreirosController;

  final TextEditingController dataController = TextEditingController();
  final TextEditingController animalFilterController = TextEditingController();

  MorteEntity? _editingMorte;
  int? selectedPotreiroId;
  List<MorteSelectedAnimal> _selectedAnimais = const [];

  bool get isEdit => _editingMorte != null;
  bool get isLoading =>
      _addController.isLoading ||
      _editController.isLoading ||
      _animalsController.isLoading ||
      _potreirosController.isLoading;
  String? get errorMessage =>
      _addController.errorMessage ??
      _editController.errorMessage ??
      _animalsController.errorMessage ??
      _potreirosController.errorMessage;
  List<AnimalEntity> get animais => _animalsController.animals;
  List<PotreiroEntity> get potreiros => _potreirosController.potreiros;
  List<MorteSelectedAnimal> get selectedAnimais => _selectedAnimais;

  PotreiroEntity? get selectedPotreiro {
    try {
      return potreiros.firstWhere((item) => item.id == selectedPotreiroId);
    } catch (_) {
      return null;
    }
  }

  String get selectedPotreiroLabel =>
      selectedPotreiro?.nome ??
      _editingMorte?.potreiro?.nome ??
      'Selecionar potreiro';

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

  bool get isFormValid =>
      dataController.text.trim().isNotEmpty &&
      selectedPotreiroId != null &&
      (isEdit || _selectedAnimais.isNotEmpty);

  Future<void> init({MorteEntity? morte}) async {
    _editingMorte = morte;
    if (morte != null) {
      dataController.text = morte.data;
      selectedPotreiroId = morte.appPotreirosId ?? morte.potreiro?.id;
    }

    try {
      await Future.wait([
        _potreirosController.load(),
        if (!isEdit) _animalsController.load(),
      ]);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> reloadPotreiros() => _potreirosController.load();
  Future<void> reloadAnimais() => _animalsController.reload();

  void onPotreiroChanged(int? value) {
    selectedPotreiroId = value;
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
        MorteSelectedAnimal(animal: animal),
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

    final entity = MorteUpsertEntity(
      id: _editingMorte?.id,
      appPotreirosId: selectedPotreiroId!,
      data: dataController.text.trim(),
      animais: isEdit
          ? const []
          : _selectedAnimais
                .map(
                  (item) => MorteUpsertAnimalEntity(
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
              ? 'Nao foi possivel atualizar a morte.'
              : 'Nao foi possivel salvar a morte.',
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
                ? 'Nao foi possivel atualizar a morte.'
                : 'Nao foi possivel salvar a morte.'),
      );
    }
  }

  PageActionResult? _validateForm() {
    if (dataController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data da morte.',
      );
    }
    if (selectedPotreiroId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o potreiro.',
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

  @override
  void dispose() {
    _addController.removeListener(notifyListeners);
    _editController.removeListener(notifyListeners);
    _animalsController.removeListener(notifyListeners);
    _potreirosController.removeListener(notifyListeners);
    dataController.dispose();
    animalFilterController.dispose();
    super.dispose();
  }
}
