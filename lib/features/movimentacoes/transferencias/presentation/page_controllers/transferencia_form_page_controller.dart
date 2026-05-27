import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_upsert_lote_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/controllers/add_transferencia_controller.dart';
import 'package:costeira/features/movimentacoes/transferencias/presentation/controllers/edit_transferencia_controller.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

class TransferenciaFormPageController extends ChangeNotifier {
  TransferenciaFormPageController(
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
    lotFilterController.addListener(notifyListeners);
  }

  static const String tipoAnimais = 'animais';
  static const String tipoLotes = 'lotes';
  static const List<String> tipos = [tipoAnimais, tipoLotes];

  final AddTransferenciaController _addController;
  final EditTransferenciaController _editController;
  final ListAnimalsController _animalsController;
  final ListAnimalLotsController _lotsController;
  final ListPotreirosController _potreirosController;

  final TextEditingController dataController = TextEditingController();
  final TextEditingController obsController = TextEditingController();
  final TextEditingController animalFilterController = TextEditingController();
  final TextEditingController lotFilterController = TextEditingController();

  TransferenciaUpsertEntity? _editingTransferencia;
  String selectedTipo = tipoAnimais;
  int? selectedPotreiroDestinoId;
  int? selectedLoteDestinoId;
  List<AnimalEntity> _selectedAnimais = const [];
  List<AnimalLotEntity> _selectedLotes = const [];

  bool get isEdit => _editingTransferencia?.id != null;
  bool get isTipoAnimais => selectedTipo == tipoAnimais;
  bool get isTipoLotes => selectedTipo == tipoLotes;
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
  List<AnimalEntity> get selectedAnimais => _selectedAnimais;
  List<AnimalLotEntity> get selectedLotes => _selectedLotes;

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

  List<AnimalLotEntity> get filteredLotes {
    final filter = lotFilterController.text.trim().toLowerCase();
    if (filter.isEmpty) {
      return lots;
    }
    return lots
        .where((lote) => lote.nome.toLowerCase().contains(filter))
        .toList(growable: false);
  }

  String get selectedPotreiroDestinoLabel =>
      _selectedPotreiroDestino?.nome ?? 'Selecionar potreiro de destino';
  String get selectedLoteDestinoLabel =>
      _selectedLoteDestino?.nome ?? 'Selecionar lote de destino';

  bool get isFormValid {
    final baseValid =
        dataController.text.trim().isNotEmpty &&
        selectedPotreiroDestinoId != null;
    if (!baseValid) {
      return false;
    }
    if (isEdit) {
      return !isTipoLotes || selectedLoteDestinoId != null;
    }
    if (isTipoAnimais) {
      return _selectedAnimais.isNotEmpty;
    }
    return selectedLoteDestinoId != null && _selectedLotes.isNotEmpty;
  }

  Future<void> init({TransferenciaUpsertEntity? transferencia}) async {
    _editingTransferencia = transferencia;
    if (transferencia != null) {
      dataController.text = transferencia.data;
      obsController.text = transferencia.obs ?? '';
      selectedTipo = tipos.contains(transferencia.tipo)
          ? transferencia.tipo
          : tipoAnimais;
      selectedPotreiroDestinoId = transferencia.potreiroDestino;
      selectedLoteDestinoId = transferencia.loteDestino;
    }

    try {
      await Future.wait([
        _potreirosController.load(),
        _animalsController.load(),
        _lotsController.load(),
      ]);
      notifyListeners();
    } catch (_) {}
  }

  void onTipoChanged(String? value) {
    if (value == null || value == selectedTipo) {
      return;
    }
    selectedTipo = value;
    _selectedAnimais = const [];
    _selectedLotes = const [];
    if (selectedTipo == tipoAnimais) {
      selectedLoteDestinoId = null;
    }
    notifyListeners();
  }

  void onPotreiroDestinoChanged(int? value) {
    selectedPotreiroDestinoId = value;
    notifyListeners();
  }

  void onLoteDestinoChanged(int? value) {
    selectedLoteDestinoId = value;
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

  void toggleLote(AnimalLotEntity lote) {
    if (isEdit) {
      return;
    }
    final isSelected = _selectedLotes.any((item) => item.id == lote.id);
    _selectedLotes = isSelected
        ? _selectedLotes
              .where((item) => item.id != lote.id)
              .toList(growable: false)
        : [..._selectedLotes, lote];
    notifyListeners();
  }

  bool isAnimalSelected(int animalId) {
    return _selectedAnimais.any((item) => item.id == animalId);
  }

  bool isLoteSelected(int loteId) {
    return _selectedLotes.any((item) => item.id == loteId);
  }

  Future<void> reloadAnimais() => _animalsController.reload();
  Future<void> reloadLotes() => _lotsController.reload();
  Future<void> reloadPotreiros() => _potreirosController.reload();

  Future<PageActionResult> submit() async {
    final validation = _validateForm();
    if (validation != null) {
      return validation;
    }

    final entity = TransferenciaUpsertEntity(
      id: _editingTransferencia?.id,
      data: dataController.text.trim(),
      tipo: selectedTipo,
      potreiroDestino: selectedPotreiroDestinoId!,
      loteDestino: isTipoLotes ? selectedLoteDestinoId : null,
      obs: _emptyToNull(obsController.text),
      animais: isEdit
          ? const []
          : _selectedAnimais
                .map((animal) => TransferenciaUpsertAnimalEntity(id: animal.id))
                .toList(growable: false),
      lotes: isEdit
          ? const []
          : _selectedLotes
                .map((lote) => TransferenciaUpsertLoteEntity(id: lote.id))
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
              ? 'Nao foi possivel atualizar a transferencia.'
              : 'Nao foi possivel salvar a transferencia.',
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
                ? 'Nao foi possivel atualizar a transferencia.'
                : 'Nao foi possivel salvar a transferencia.'),
      );
    }
  }

  PageActionResult? _validateForm() {
    if (isEdit && _editingTransferencia?.id == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a transferencia para atualizar.',
      );
    }
    if (dataController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data da transferencia.',
      );
    }
    if (selectedPotreiroDestinoId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o potreiro de destino.',
      );
    }
    if (isTipoLotes && selectedLoteDestinoId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o lote de destino.',
      );
    }
    if (!isEdit && isTipoAnimais && _selectedAnimais.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione pelo menos um animal.',
      );
    }
    if (!isEdit && isTipoLotes && _selectedLotes.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione pelo menos um lote.',
      );
    }
    return null;
  }

  PotreiroEntity? get _selectedPotreiroDestino {
    try {
      return potreiros.firstWhere(
        (item) => item.id == selectedPotreiroDestinoId,
      );
    } catch (_) {
      return null;
    }
  }

  AnimalLotEntity? get _selectedLoteDestino {
    try {
      return lots.firstWhere((item) => item.id == selectedLoteDestinoId);
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
    _lotsController.removeListener(notifyListeners);
    _potreirosController.removeListener(notifyListeners);
    dataController.dispose();
    obsController.dispose();
    animalFilterController.dispose();
    lotFilterController.dispose();
    super.dispose();
  }
}
