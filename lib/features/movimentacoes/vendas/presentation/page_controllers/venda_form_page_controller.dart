import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animals_controller.dart';
import 'package:costeira/features/animals/presentation/page_controllers/page_action_result.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_filter_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_upsert_entity.dart';
import 'package:costeira/features/cadastros/domain/usecases/create_parceiro_usecase.dart';
import 'package:costeira/features/cadastros/domain/usecases/get_parceiros_usecase.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/domain/entities/venda_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/controllers/add_venda_controller.dart';
import 'package:costeira/features/movimentacoes/vendas/presentation/controllers/edit_venda_controller.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

enum VendaCompradorMode { existente, novo }

enum VendaEscopo { loteiro, parcial }

class VendaPesagemRow {
  VendaPesagemRow({required this.animal, required String pesoSaida})
    : pesoSaidaController = TextEditingController(text: pesoSaida);

  final AnimalEntity animal;
  final TextEditingController pesoSaidaController;

  void dispose() {
    pesoSaidaController.dispose();
  }
}

class VendaFormPageController extends ChangeNotifier {
  VendaFormPageController(
    this._addController,
    this._editController,
    this._animalsController,
    this._getListController,
    this._lotsController,
    this._potreirosController,
    this._getFazendasUsecase,
    this._getParceirosUsecase,
    this._createParceiroUsecase,
  ) {
    _addController.addListener(notifyListeners);
    _editController.addListener(notifyListeners);
    _animalsController.addListener(notifyListeners);
    _getListController.addListener(notifyListeners);
    _lotsController.addListener(notifyListeners);
    _potreirosController.addListener(notifyListeners);
    dataController.addListener(notifyListeners);
    valorUnitarioController.addListener(notifyListeners);
    valorFreteController.addListener(notifyListeners);
    valorComissaoController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
    novoNomeController.addListener(notifyListeners);
    novoDocumentoController.addListener(notifyListeners);
    novoContatoController.addListener(notifyListeners);
  }

  static const List<String> tiposValor = ['kg', 'cabeça'];
  static const String tipoCadastroIndividual = 'individual';
  static const String tipoCadastroLote = 'lote';

  final AddVendaController _addController;
  final EditVendaController _editController;
  final ListAnimalsController _animalsController;
  final GetListController _getListController;
  final ListAnimalLotsController _lotsController;
  final ListPotreirosController _potreirosController;
  final GetFazendasUsecase _getFazendasUsecase;
  final GetParceirosUsecase _getParceirosUsecase;
  final CreateParceiroUsecase _createParceiroUsecase;

  final TextEditingController dataController = TextEditingController();
  final TextEditingController valorUnitarioController = TextEditingController();
  final TextEditingController valorFreteController = TextEditingController();
  final TextEditingController valorComissaoController = TextEditingController();
  final TextEditingController obsController = TextEditingController();
  final TextEditingController novoNomeController = TextEditingController();
  final TextEditingController novoDocumentoController = TextEditingController();
  final TextEditingController novoContatoController = TextEditingController();
  final TextEditingController animalFilterController = TextEditingController();

  VendaEntity? _editingVenda;
  List<FazendaEntity> fazendas = const [];
  List<ParceiroEntity> compradores = const [];
  List<ListCategoryEntity> _allCategories = const [];
  int? selectedFarmId;
  int? selectedPotreiroId;
  int? selectedLotId;
  int? selectedCategoryId;
  int? selectedSubcategoryId;
  final Set<String> selectedStatuses = {};
  String? selectedTipoValor = 'cabeça';
  VendaEscopo escopo = VendaEscopo.loteiro;
  VendaCompradorMode compradorMode = VendaCompradorMode.existente;
  int? selectedCompradorId;
  bool isLoadingFarms = false;
  bool isLoadingCompradores = false;
  bool isCreatingComprador = false;
  String? farmsError;
  String? compradoresError;
  final Set<int> _parcialSelectedIds = {};
  final Map<int, VendaPesagemRow> _pesagemRows = {};
  int _listRequest = 0;
  _VendaFormSnapshot? _initialSnapshot;

  bool get isEdit => _editingVenda != null;
  bool get isLoading =>
      _addController.isLoading ||
      _editController.isLoading ||
      _animalsController.isLoading ||
      _lotsController.isLoading ||
      _potreirosController.isLoading ||
      isLoadingFarms ||
      isLoadingCompradores ||
      isCreatingComprador;
  String? get errorMessage =>
      farmsError ??
      compradoresError ??
      _addController.errorMessage ??
      _editController.errorMessage ??
      _animalsController.errorMessage ??
      _lotsController.errorMessage ??
      _potreirosController.errorMessage;
  bool get showFarmSelector => !isEdit && fazendas.length > 1;
  bool get canListAnimals =>
      selectedFarmId != null &&
      selectedPotreiroId != null &&
      selectedLotId != null;
  bool get isLoteiro => escopo == VendaEscopo.loteiro;
  List<PotreiroEntity> get potreiros => _potreirosController.potreiros;
  List<AnimalLotEntity> get lots {
    final all = _lotsController.lots;
    final potreiroId = selectedPotreiroId;
    if (potreiroId == null) {
      return const [];
    }
    return all
        .where(
          (lot) =>
              lot.appPotreirosId == null || lot.appPotreirosId == potreiroId,
        )
        .toList(growable: false);
  }

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
  List<String> get availableStatuses {
    if (!canSelectStatus) {
      return const [];
    }
    final fromAnimals = groupedAnimals
        .map((animal) => animal.status?.trim())
        .whereType<String>()
        .where((item) => item.isNotEmpty)
        .toSet();
    return fromAnimals.toList(growable: false)..sort();
  }

  bool get hasStatusOptions => availableStatuses.isNotEmpty;

  List<AnimalEntity> get groupedAnimals {
    return _animalsController.animals.where(_matchesGroup).toList(
      growable: false,
    );
  }

  List<AnimalEntity> get scopedAnimals {
    if (isLoteiro) {
      return groupedAnimals;
    }
    return groupedAnimals
        .where((animal) => _parcialSelectedIds.contains(animal.id))
        .toList(growable: false);
  }

  List<VendaPesagemRow> get pesagemRows {
    return scopedAnimals
        .map((animal) => _pesagemRows[animal.id])
        .whereType<VendaPesagemRow>()
        .toList(growable: false);
  }

  FazendaEntity? get selectedFarm {
    final id = selectedFarmId;
    if (id == null) {
      return null;
    }
    for (final farm in fazendas) {
      if (farm.id == id) {
        return farm;
      }
    }
    return null;
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
      selectedPotreiro?.nome ?? 'Selecionar piquete';
  String get selectedLotLabel {
    if (selectedPotreiroId == null) {
      return 'Selecione um piquete primeiro';
    }
    return selectedLot?.nome ?? 'Selecionar lote';
  }

  String get valorUnitarioLabel => selectedTipoValor == 'kg'
      ? 'Valor por kg vivo (R\$)'
      : 'Valor por cabeça (R\$)';

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

  double get pesoTotalSaida {
    var total = 0.0;
    for (final row in pesagemRows) {
      total += _parsePeso(row.pesoSaidaController.text) ?? 0;
    }
    return total;
  }

  double get pesoMedioSaida {
    final count = pesagemRows.length;
    if (count == 0) {
      return 0;
    }
    return pesoTotalSaida / count;
  }

  double get valorTotalEstimado {
    final unitario = _parseNumber(valorUnitarioController.text) ?? 0;
    if (selectedTipoValor == 'kg') {
      return pesoTotalSaida * unitario;
    }
    return scopedAnimals.length * unitario;
  }

  bool get hasChanges =>
      !isEdit ||
      _initialSnapshot == null ||
      _currentSnapshot() != _initialSnapshot;

  bool get isFormValid {
    if (selectedFarmId == null ||
        dataController.text.trim().isEmpty ||
        (BrazilianCurrency.parse(valorUnitarioController.text) ?? 0) <= 0 ||
        !hasChanges) {
      return false;
    }
    if (compradorMode == VendaCompradorMode.existente &&
        selectedCompradorId == null) {
      return false;
    }
    if (compradorMode == VendaCompradorMode.novo &&
        novoNomeController.text.trim().isEmpty) {
      return false;
    }
    if (isEdit) {
      return true;
    }
    if (selectedPotreiroId == null ||
        selectedLotId == null ||
        selectedTipoValor == null) {
      return false;
    }
    if (scopedAnimals.isEmpty) {
      return false;
    }
    return pesagemRows.every(
      (row) => row.pesoSaidaController.text.trim().isNotEmpty,
    );
  }

  bool get isCompradorComplete {
    if (showFarmSelector && selectedFarmId == null) {
      return false;
    }
    if (dataController.text.trim().isEmpty) {
      return false;
    }
    if (compradorMode == VendaCompradorMode.existente) {
      return selectedCompradorId != null;
    }
    return novoNomeController.text.trim().isNotEmpty;
  }

  /// Filtros opcionais: neutro se vazio; check só com filtro ativo.
  bool? get isGrupoComplete {
    if (selectedCategoryId != null || selectedStatuses.isNotEmpty) {
      return true;
    }
    return null;
  }

  bool get isEscopoComplete {
    if (isEdit) {
      return true;
    }
    return canListAnimals &&
        scopedAnimals.isNotEmpty &&
        pesagemRows.every(
          (row) => row.pesoSaidaController.text.trim().isNotEmpty,
        );
  }

  bool get isValoresComplete =>
      (BrazilianCurrency.parse(valorUnitarioController.text) ?? 0) > 0 &&
      (isEdit || selectedTipoValor != null);

  bool isParcialSelected(int animalId) => _parcialSelectedIds.contains(animalId);

  List<AnimalEntity> get filteredAnimais => groupedAnimals;
  List<AnimalEntity> get selectedAnimais => scopedAnimals;
  bool isAnimalSelected(int animalId) =>
      isLoteiro || _parcialSelectedIds.contains(animalId);
  Future<void> reloadAnimais() => _reloadGroupAnimals();

  void toggleAnimal(AnimalEntity animal) {
    toggleParcialAnimal(animal.id);
  }

  Future<void> init({VendaEntity? venda}) async {
    _resetFormState();
    _editingVenda = venda;
    if (venda != null) {
      dataController.text = venda.data;
      selectedCompradorId = venda.idComprador;
      valorUnitarioController.text =
          BrazilianCurrency.formatFromRaw(venda.valorUnitario) ??
          (venda.valorUnitarioRaw != null
              ? BrazilianCurrency.format(venda.valorUnitarioRaw!)
              : '');
      valorFreteController.text =
          BrazilianCurrency.formatFromRaw(venda.valorFrete) ?? '';
      valorComissaoController.text =
          BrazilianCurrency.formatFromRaw(venda.valorComissao) ?? '';
      obsController.text = venda.obs ?? '';
    } else {
      final now = DateTime.now();
      dataController.text =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    }

    try {
      await Future.wait([
        _loadFazendas(preferredFarmId: venda?.appFazendasId),
        if (!isEdit) ...[
          _lotsController.load(),
          _potreirosController.load(),
          _loadCategories(),
        ],
      ]);
      if (isEdit) {
        _matchCompradorFromEditing();
      }
      notifyListeners();
      _initialSnapshot = _currentSnapshot();
    } catch (_) {
      notifyListeners();
    }
  }

  void _resetFormState() {
    _editingVenda = null;
    selectedFarmId = null;
    selectedPotreiroId = null;
    selectedLotId = null;
    selectedCategoryId = null;
    selectedSubcategoryId = null;
    selectedStatuses.clear();
    selectedTipoValor = 'cabeça';
    escopo = VendaEscopo.loteiro;
    compradorMode = VendaCompradorMode.existente;
    selectedCompradorId = null;
    farmsError = null;
    compradoresError = null;
    compradores = const [];
    _parcialSelectedIds.clear();
    _clearPesagemRows();
    valorUnitarioController.clear();
    valorFreteController.clear();
    valorComissaoController.clear();
    obsController.clear();
    novoNomeController.clear();
    novoDocumentoController.clear();
    novoContatoController.clear();
    animalFilterController.clear();
    _initialSnapshot = null;
  }

  Future<void> reloadLots() => _lotsController.load();
  Future<void> reloadPotreiros() => _potreirosController.load();

  void onFarmChanged(int? value) {
    if (value == null || value == selectedFarmId) {
      return;
    }
    selectedFarmId = value;
    selectedCompradorId = null;
    compradores = const [];
    notifyListeners();
    _loadCompradores();
    _reloadGroupAnimals();
  }

  void onPotreiroChanged(int? value) {
    selectedPotreiroId = value;
    if (selectedLotId != null && !lots.any((lot) => lot.id == selectedLotId)) {
      selectedLotId = null;
    }
    notifyListeners();
    _reloadGroupAnimals();
  }

  void onLotChanged(int? value) {
    selectedLotId = value;
    notifyListeners();
    _reloadGroupAnimals();
  }

  void onCategoryChanged(int? value) {
    selectedCategoryId = value;
    selectedSubcategoryId = null;
    selectedStatuses.clear();
    _applyGroupFiltersLocally();
  }

  void onSubcategoryChanged(int? value) {
    selectedSubcategoryId = hasAnimalSubcategories ? value : null;
    selectedStatuses.clear();
    _applyGroupFiltersLocally();
  }

  void toggleStatus(String status) {
    if (selectedStatuses.contains(status)) {
      selectedStatuses.remove(status);
    } else {
      selectedStatuses.add(status);
    }
    _applyGroupFiltersLocally();
  }

  void onTipoValorChanged(String? value) {
    selectedTipoValor = value;
    notifyListeners();
  }

  void onEscopoChanged(VendaEscopo value) {
    escopo = value;
    if (isLoteiro) {
      _parcialSelectedIds
        ..clear()
        ..addAll(groupedAnimals.map((animal) => animal.id));
    }
    _syncSelectionAndRows();
    notifyListeners();
  }

  void onCompradorModeChanged(VendaCompradorMode mode) {
    compradorMode = mode;
    notifyListeners();
  }

  void onCompradorChanged(int? value) {
    selectedCompradorId = value;
    notifyListeners();
  }

  void toggleParcialAnimal(int animalId) {
    if (isLoteiro) {
      return;
    }
    if (_parcialSelectedIds.contains(animalId)) {
      _parcialSelectedIds.remove(animalId);
    } else {
      _parcialSelectedIds.add(animalId);
    }
    _syncSelectionAndRows();
    notifyListeners();
  }

  void selectAllParcial() {
    _parcialSelectedIds
      ..clear()
      ..addAll(groupedAnimals.map((animal) => animal.id));
    _syncSelectionAndRows();
    notifyListeners();
  }

  void clearParcial() {
    _parcialSelectedIds.clear();
    _syncSelectionAndRows();
    notifyListeners();
  }

  String? gmdLabel(VendaPesagemRow row) {
    final saida = _parsePeso(row.pesoSaidaController.text);
    final ultimo = row.animal.peso;
    final lastDate = _parseDate(
      row.animal.ultimaPesagem ??
          row.animal.updateAt ??
          row.animal.createAt,
    );
    if (saida == null || ultimo == null || lastDate == null) {
      return null;
    }
    final vendaDate = _parseDate(dataController.text) ?? DateTime.now();
    final start = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final end = DateTime(vendaDate.year, vendaDate.month, vendaDate.day);
    final days = end.difference(start).inDays;
    if (days <= 0) {
      return null;
    }
    final gmd = (saida - ultimo) / days;
    return gmd.toStringAsFixed(2).replaceAll('.', ',');
  }

  Future<PageActionResult> submit() async {
    final validation = _validateForm();
    if (validation != null) {
      return validation;
    }

    try {
      final compradorId = await _resolveCompradorId();
      if (compradorId == null) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Informe o comprador.',
        );
      }

      final entity = VendaUpsertEntity(
        id: _editingVenda?.id,
        appFazendasId: selectedFarmId!,
        data: dataController.text.trim(),
        tipoCompra: selectedTipoValor ?? 'cabeça',
        tipoCadastro: isEdit
            ? tipoCadastroIndividual
            : (isLoteiro ? tipoCadastroLote : tipoCadastroIndividual),
        valorUnitario: BrazilianCurrency.toApi(valorUnitarioController.text),
        valorFrete: BrazilianCurrency.toApiOrNull(valorFreteController.text),
        valorComissao: BrazilianCurrency.toApiOrNull(
          valorComissaoController.text,
        ),
        idComprador: compradorId,
        obs: _emptyToNull(obsController.text),
        animais: isEdit
            ? const []
            : pesagemRows
                  .map(
                    (row) => VendaUpsertAnimalEntity(
                      id: row.animal.id,
                      pesoTotal: row.pesoSaidaController.text.trim(),
                    ),
                  )
                  .toList(growable: false),
      );

      final result = isEdit
          ? await _editController.submit(entity)
          : await _addController.submit(entity);
      if (result == null) {
        return PageActionResult(
          isSuccess: false,
          message: isEdit
              ? 'Não foi possível atualizar a venda.'
              : 'Não foi possível salvar a venda.',
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
                ? 'Não foi possível atualizar a venda.'
                : 'Não foi possível salvar a venda.'),
      );
    }
  }

  PageActionResult? _validateForm() {
    if (selectedFarmId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Cadastre uma fazenda antes.',
      );
    }
    if (dataController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data da venda.',
      );
    }
    if ((BrazilianCurrency.parse(valorUnitarioController.text) ?? 0) <= 0) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o valor.',
      );
    }
    if (compradorMode == VendaCompradorMode.existente &&
        selectedCompradorId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o comprador.',
      );
    }
    if (compradorMode == VendaCompradorMode.novo &&
        novoNomeController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o nome do novo cadastro.',
      );
    }
    if (isEdit) {
      return null;
    }
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
    if (selectedTipoValor == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o tipo de valor.',
      );
    }
    if (scopedAnimals.isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione pelo menos um animal.',
      );
    }
    for (final row in pesagemRows) {
      if (row.pesoSaidaController.text.trim().isEmpty) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Informe o peso de saída dos animais.',
        );
      }
    }
    return null;
  }

  bool _matchesGroup(AnimalEntity animal) {
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
    if (selectedStatuses.isNotEmpty) {
      final status = animal.status?.trim();
      if (status == null || !selectedStatuses.contains(status)) {
        return false;
      }
    }
    return true;
  }

  Future<void> _reloadGroupAnimals() async {
    if (isEdit || !canListAnimals) {
      _parcialSelectedIds.clear();
      _clearPesagemRows();
      notifyListeners();
      return;
    }

    final request = ++_listRequest;
    try {
      // Lista por fazenda/piquete/lote. Categoria/fase/status/brinco
      // filtram só no client (_matchesGroup) pra não zerar a API.
      await _animalsController.load(
        appFazendasId: selectedFarmId,
        appPotreirosId: selectedPotreiroId,
        appAnimaisLotesId: selectedLotId,
      );
      if (request != _listRequest) {
        return;
      }
      _applyGroupFiltersLocally();
    } catch (_) {
      notifyListeners();
    }
  }

  void _applyGroupFiltersLocally() {
    if (isLoteiro) {
      _parcialSelectedIds
        ..clear()
        ..addAll(groupedAnimals.map((animal) => animal.id));
    } else {
      _parcialSelectedIds.removeWhere(
        (id) => groupedAnimals.every((animal) => animal.id != id),
      );
    }
    _syncSelectionAndRows();
    notifyListeners();
  }

  void _syncSelectionAndRows() {
    final scopedIds = scopedAnimals.map((animal) => animal.id).toSet();
    final stale = _pesagemRows.keys
        .where((id) => !scopedIds.contains(id))
        .toList(growable: false);
    for (final id in stale) {
      _pesagemRows.remove(id)?.dispose();
    }
    for (final animal in scopedAnimals) {
      if (_pesagemRows.containsKey(animal.id)) {
        continue;
      }
      final peso = animal.peso == null
          ? ''
          : animal.peso!.toStringAsFixed(1).replaceAll('.', ',');
      final row = VendaPesagemRow(animal: animal, pesoSaida: peso);
      row.pesoSaidaController.addListener(notifyListeners);
      _pesagemRows[animal.id] = row;
    }
  }

  void _clearPesagemRows() {
    for (final row in _pesagemRows.values) {
      row.dispose();
    }
    _pesagemRows.clear();
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

  Future<void> _loadFazendas({int? preferredFarmId}) async {
    isLoadingFarms = true;
    farmsError = null;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw Exception('Usuario nao autenticado.');
      }
      final result = await _getFazendasUsecase(
        FazendaFilterEntity(appUsersId: user.id),
      );
      fazendas = result.data;
      if (preferredFarmId != null &&
          fazendas.any((farm) => farm.id == preferredFarmId)) {
        selectedFarmId = preferredFarmId;
      } else {
        selectedFarmId = fazendas.isEmpty ? null : fazendas.first.id;
      }
      if (selectedFarmId != null) {
        await _loadCompradores();
      }
    } catch (_) {
      farmsError = 'Nao foi possivel carregar as fazendas.';
    } finally {
      isLoadingFarms = false;
      notifyListeners();
    }
  }

  void _matchCompradorFromEditing() {
    final venda = _editingVenda;
    if (venda == null || compradores.isEmpty) {
      return;
    }
    if (venda.idComprador != null) {
      final byId = compradores.where((item) => item.id == venda.idComprador);
      if (byId.isNotEmpty) {
        selectedCompradorId = byId.first.id;
        compradorMode = VendaCompradorMode.existente;
        return;
      }
    }
    final nome = venda.comprador?.trim().toLowerCase();
    if (nome == null || nome.isEmpty) {
      return;
    }
    final byName = compradores.where(
      (item) => item.nome.trim().toLowerCase() == nome,
    );
    if (byName.isNotEmpty) {
      selectedCompradorId = byName.first.id;
      compradorMode = VendaCompradorMode.existente;
    }
  }

  Future<void> _loadCompradores() async {
    final farmId = selectedFarmId;
    if (farmId == null) {
      return;
    }
    isLoadingCompradores = true;
    compradoresError = null;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw Exception('Usuario nao autenticado.');
      }
      final result = await _getParceirosUsecase(
        ParceiroFilterEntity(
          kind: ParceiroKind.comprador,
          appUsersId: user.id,
          appFazendasId: farmId,
        ),
      );
      compradores = result.data;
      if (compradores.isEmpty && selectedCompradorId == null) {
        compradorMode = VendaCompradorMode.novo;
      }
    } catch (_) {
      compradoresError = 'Nao foi possivel carregar os compradores.';
    } finally {
      isLoadingCompradores = false;
      notifyListeners();
    }
  }

  Future<int?> _resolveCompradorId() async {
    if (compradorMode == VendaCompradorMode.existente) {
      return selectedCompradorId;
    }

    final farmId = selectedFarmId;
    if (farmId == null) {
      return null;
    }

    isCreatingComprador = true;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw Exception('Usuario nao autenticado.');
      }

      final nome = novoNomeController.text.trim();
      final digits = novoDocumentoController.text.replaceAll(RegExp(r'\D'), '');
      final isPj = digits.length > 11;
      final contato = novoContatoController.text.trim();
      final isEmail = contato.contains('@');

      await _createParceiroUsecase(
        ParceiroUpsertEntity(
          kind: ParceiroKind.comprador,
          appUsersId: user.id,
          appFazendasId: farmId,
          tipoPessoa: isPj
              ? WSConstantes.tipoPessoaJuridica
              : WSConstantes.tipoPessoaFisica,
          nome: nome,
          email: isEmail ? contato : '',
          celular: isEmail ? '' : contato,
          documento: isPj ? null : digits,
          cnpj: isPj ? digits : null,
          razaoSocial: isPj ? nome : null,
          nomeFantasia: isPj ? nome : null,
          endereco: '',
          numero: '0',
        ),
      );

      await _loadCompradores();
      final match = compradores.cast<ParceiroEntity?>().firstWhere(
        (item) => item?.nome.trim().toLowerCase() == nome.toLowerCase(),
        orElse: () => compradores.isEmpty ? null : compradores.last,
      );
      selectedCompradorId = match?.id;
      if (match != null) {
        compradorMode = VendaCompradorMode.existente;
      }
      return selectedCompradorId;
    } finally {
      isCreatingComprador = false;
      notifyListeners();
    }
  }

  _VendaFormSnapshot _currentSnapshot() {
    return _VendaFormSnapshot(
      selectedFarmId: selectedFarmId,
      selectedPotreiroId: selectedPotreiroId,
      selectedLotId: selectedLotId,
      selectedCompradorId: selectedCompradorId,
      data: dataController.text.trim(),
      valorUnitario: valorUnitarioController.text.trim(),
    );
  }

  double? _parseNumber(String value) => BrazilianCurrency.parse(value);

  double? _parsePeso(String value) {
    var normalized = value.replaceAll('R\$', '').replaceAll(' ', '').trim();
    if (normalized.isEmpty) {
      return null;
    }
    if (normalized.contains(',')) {
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    }
    return double.tryParse(normalized);
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    // Aceita "24/09/2026", "24/09/2026 14:39:19", "2026-09-24"...
    final raw = value.trim().split(RegExp(r'\s+')).first;
    final br = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})$').firstMatch(raw);
    if (br != null) {
      final day = int.tryParse(br.group(1)!);
      final month = int.tryParse(br.group(2)!);
      var year = int.tryParse(br.group(3)!);
      if (day != null && month != null && year != null) {
        if (year < 100) {
          year += 2000;
        }
        return DateTime(year, month, day);
      }
    }
    final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})').firstMatch(raw);
    if (iso != null) {
      final year = int.tryParse(iso.group(1)!);
      final month = int.tryParse(iso.group(2)!);
      final day = int.tryParse(iso.group(3)!);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return DateTime.tryParse(raw);
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
    valorUnitarioController.dispose();
    valorFreteController.dispose();
    valorComissaoController.dispose();
    obsController.dispose();
    novoNomeController.dispose();
    novoDocumentoController.dispose();
    novoContatoController.dispose();
    animalFilterController.dispose();
    _clearPesagemRows();
    super.dispose();
  }
}

class _VendaFormSnapshot {
  const _VendaFormSnapshot({
    required this.selectedFarmId,
    required this.selectedPotreiroId,
    required this.selectedLotId,
    required this.selectedCompradorId,
    required this.data,
    required this.valorUnitario,
  });

  final int? selectedFarmId;
  final int? selectedPotreiroId;
  final int? selectedLotId;
  final int? selectedCompradorId;
  final String data;
  final String valorUnitario;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _VendaFormSnapshot &&
            other.selectedFarmId == selectedFarmId &&
            other.selectedPotreiroId == selectedPotreiroId &&
            other.selectedLotId == selectedLotId &&
            other.selectedCompradorId == selectedCompradorId &&
            other.data == data &&
            other.valorUnitario == valorUnitario;
  }

  @override
  int get hashCode => Object.hash(
    selectedFarmId,
    selectedPotreiroId,
    selectedLotId,
    selectedCompradorId,
    data,
    valorUnitario,
  );
}
