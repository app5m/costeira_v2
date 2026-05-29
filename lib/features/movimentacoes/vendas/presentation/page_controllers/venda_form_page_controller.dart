import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_destino_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/controllers/add_venda_controller.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/controllers/edit_venda_controller.dart';
import 'package:flutter/material.dart';

class VendaFormPageController extends ChangeNotifier {
  VendaFormPageController(
    this._addController,
    this._editController,
    this._animalsController,
  ) {
    _addController.addListener(notifyListeners);
    _editController.addListener(notifyListeners);
    _animalsController.addListener(notifyListeners);
    dataController.addListener(notifyListeners);
    valorUnitarioController.addListener(notifyListeners);
    compradorController.addListener(notifyListeners);
    municipioController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
    animalFilterController.addListener(notifyListeners);
  }

  static const List<String> tiposAbate = ['kg vivo', 'kg carcaça'];
  static const List<String> tiposReposicao = ['kg vivo', 'unidade'];

  final AddVendaController _addController;
  final EditVendaController _editController;
  final ListAnimalsController _animalsController;

  final TextEditingController dataController = TextEditingController();
  final TextEditingController valorUnitarioController = TextEditingController();
  final TextEditingController compradorController = TextEditingController();
  final TextEditingController municipioController = TextEditingController();
  final TextEditingController obsController = TextEditingController();
  final TextEditingController animalFilterController = TextEditingController();

  VendaEntity? _editingVenda;
  List<AnimalEntity> _selectedAnimais = const [];
  String? selectedTipoAbate;
  String? selectedTipoReposicao;
  _VendaFormSnapshot? _initialSnapshot;

  bool get isEdit => _editingVenda != null;
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
  VendaEntity? get editingVenda => _editingVenda;

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
      valorUnitarioController.text.trim().isNotEmpty &&
      selectedTipoAbate != null &&
      selectedTipoReposicao != null &&
      (isEdit || _selectedAnimais.isNotEmpty) &&
      hasChanges;
  bool get hasChanges =>
      !isEdit ||
      _initialSnapshot == null ||
      _currentSnapshot() != _initialSnapshot;

  Future<void> init({VendaEntity? venda}) async {
    _editingVenda = venda;
    if (venda != null) {
      dataController.text = venda.data;
      valorUnitarioController.text =
          venda.valorUnitario?.replaceAll('R\$', '').trim() ?? '';
      compradorController.text = venda.comprador ?? '';
      municipioController.text = venda.municipio ?? '';
      obsController.text = venda.obs ?? '';
      selectedTipoAbate = _destinoTipo(venda, 1);
      selectedTipoReposicao = _destinoTipo(venda, 2);
      _initialSnapshot = _currentSnapshot();
    } else {
      _initialSnapshot = null;
    }

    if (!isEdit) {
      try {
        await _animalsController.load();
      } catch (_) {}
    }
    notifyListeners();
  }

  void onTipoAbateChanged(String? value) {
    selectedTipoAbate = value;
    notifyListeners();
  }

  void onTipoReposicaoChanged(String? value) {
    selectedTipoReposicao = value;
    notifyListeners();
  }

  void toggleAnimal(AnimalEntity animal) {
    if (isEdit) {
      return;
    }
    final isSelected = _selectedAnimais.any((item) => item.id == animal.id);
    if (isSelected) {
      _selectedAnimais = _selectedAnimais
          .where((item) => item.id != animal.id)
          .toList(growable: false);
    } else {
      _selectedAnimais = [..._selectedAnimais, animal];
    }
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

    final entity = VendaUpsertEntity(
      id: _editingVenda?.id,
      data: dataController.text.trim(),
      valorUnitario: valorUnitarioController.text.trim(),
      comprador: _emptyToNull(compradorController.text),
      municipio: _emptyToNull(municipioController.text),
      obs: _emptyToNull(obsController.text),
      animais: isEdit
          ? const []
          : _selectedAnimais
                .map((animal) => VendaUpsertAnimalEntity(id: animal.id))
                .toList(growable: false),
      destinos: [
        VendaDestinoEntity(destino: 1, tipo: selectedTipoAbate!),
        VendaDestinoEntity(destino: 2, tipo: selectedTipoReposicao!),
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
              ? 'Nao foi possivel atualizar a venda.'
              : 'Nao foi possivel salvar a venda.',
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
                ? 'Nao foi possivel atualizar a venda.'
                : 'Nao foi possivel salvar a venda.'),
      );
    }
  }

  PageActionResult? _validateForm() {
    if (dataController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data da venda.',
      );
    }
    if (valorUnitarioController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o valor unitário.',
      );
    }
    if (selectedTipoAbate == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o tipo do destino abate.',
      );
    }
    if (selectedTipoReposicao == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o tipo do destino reposicao.',
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

  String? _destinoTipo(VendaEntity venda, int destino) {
    try {
      return venda.destinos.firstWhere((item) => item.destino == destino).tipo;
    } catch (_) {
      return null;
    }
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  _VendaFormSnapshot _currentSnapshot() {
    return _VendaFormSnapshot(
      data: dataController.text.trim(),
      valorUnitario: _normalizeMoney(valorUnitarioController.text),
      comprador: _normalizeOptionalText(compradorController.text),
      municipio: _normalizeOptionalText(municipioController.text),
      obs: _normalizeOptionalText(obsController.text),
      selectedTipoAbate: selectedTipoAbate,
      selectedTipoReposicao: selectedTipoReposicao,
    );
  }

  String _normalizeMoney(String value) {
    return value.replaceAll('R\$', '').trim();
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
    dataController.dispose();
    valorUnitarioController.dispose();
    compradorController.dispose();
    municipioController.dispose();
    obsController.dispose();
    animalFilterController.dispose();
    super.dispose();
  }
}

class _VendaFormSnapshot {
  const _VendaFormSnapshot({
    required this.data,
    required this.valorUnitario,
    required this.comprador,
    required this.municipio,
    required this.obs,
    required this.selectedTipoAbate,
    required this.selectedTipoReposicao,
  });

  final String data;
  final String valorUnitario;
  final String? comprador;
  final String? municipio;
  final String? obs;
  final String? selectedTipoAbate;
  final String? selectedTipoReposicao;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _VendaFormSnapshot &&
            other.data == data &&
            other.valorUnitario == valorUnitario &&
            other.comprador == comprador &&
            other.municipio == municipio &&
            other.obs == obs &&
            other.selectedTipoAbate == selectedTipoAbate &&
            other.selectedTipoReposicao == selectedTipoReposicao;
  }

  @override
  int get hashCode => Object.hash(
    data,
    valorUnitario,
    comprador,
    municipio,
    obs,
    selectedTipoAbate,
    selectedTipoReposicao,
  );
}
