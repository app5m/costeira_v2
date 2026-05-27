import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/presentation/controllers/add_consumo_controller.dart';
import 'package:costeira/features/movimentacoes/consumo/presentation/controllers/edit_consumo_controller.dart';
import 'package:flutter/material.dart';

class ConsumoFormPageController extends ChangeNotifier {
  ConsumoFormPageController(
    this._addController,
    this._editController,
    this._animalsController,
  ) {
    _addController.addListener(notifyListeners);
    _editController.addListener(notifyListeners);
    _animalsController.addListener(notifyListeners);
    dataController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
    animalFilterController.addListener(notifyListeners);
  }

  final AddConsumoController _addController;
  final EditConsumoController _editController;
  final ListAnimalsController _animalsController;

  final TextEditingController dataController = TextEditingController();
  final TextEditingController obsController = TextEditingController();
  final TextEditingController animalFilterController = TextEditingController();

  ConsumoUpsertEntity? _editingConsumo;
  List<AnimalEntity> _selectedAnimais = const [];

  bool get isEdit => _editingConsumo?.id != null;
  bool get isLoading =>
      _addController.isLoading ||
      _editController.isLoading ||
      _animalsController.isLoading;
  String? get errorMessage =>
      _addController.errorMessage ??
      _editController.errorMessage ??
      _animalsController.errorMessage;
  List<AnimalEntity> get animais => _animalsController.animals;
  List<AnimalEntity> get selectedAnimais => _selectedAnimais;

  List<AnimalEntity> get filteredAnimais {
    final filter = animalFilterController.text.trim().toLowerCase();
    if (filter.isEmpty) {
      return animais;
    }
    return animais
        .where((animal) {
          final brinco = animal.brinco?.toLowerCase() ?? '';
          final categoria = animal.categoria?.nome.toLowerCase() ?? '';
          return brinco.contains(filter) || categoria.contains(filter);
        })
        .toList(growable: false);
  }

  bool get isFormValid {
    if (dataController.text.trim().isEmpty) {
      return false;
    }
    return isEdit || _selectedAnimais.isNotEmpty;
  }

  Future<void> init({ConsumoUpsertEntity? consumo}) async {
    _editingConsumo = consumo;
    if (consumo != null) {
      dataController.text = consumo.data;
      obsController.text = consumo.obs ?? '';
    }

    if (!isEdit) {
      try {
        await _animalsController.load();
      } catch (_) {}
    }
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

  Future<void> reloadAnimais() => _animalsController.reload();

  Future<PageActionResult> submit() async {
    final validation = _validateForm();
    if (validation != null) {
      return validation;
    }

    final entity = ConsumoUpsertEntity(
      id: _editingConsumo?.id,
      data: dataController.text.trim(),
      obs: _emptyToNull(obsController.text),
      animais: isEdit
          ? const []
          : _selectedAnimais
                .map((animal) => ConsumoUpsertAnimalEntity(id: animal.id))
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
              ? 'Nao foi possivel atualizar o consumo.'
              : 'Nao foi possivel salvar o consumo.',
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
                ? 'Nao foi possivel atualizar o consumo.'
                : 'Nao foi possivel salvar o consumo.'),
      );
    }
  }

  PageActionResult? _validateForm() {
    if (isEdit && _editingConsumo?.id == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o consumo para atualizar.',
      );
    }
    if (dataController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data do consumo.',
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

  @override
  void dispose() {
    _addController.removeListener(notifyListeners);
    _editController.removeListener(notifyListeners);
    _animalsController.removeListener(notifyListeners);
    dataController.dispose();
    obsController.dispose();
    animalFilterController.dispose();
    super.dispose();
  }
}
