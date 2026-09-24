import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/presentation/controllers/get_list_controller.dart';
import 'package:costeira/core/config/ws_constantes.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/presentation/controllers/list_animal_lots_controller.dart';
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
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_animal_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/compra_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/controllers/add_compra_controller.dart';
import 'package:costeira/features/movimentacoes/compras/presentation/controllers/edit_compra_controller.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/presentation/controllers/list_potreiros_controller.dart';
import 'package:flutter/material.dart';

enum CompraFornecedorMode { existente, novo }

class CompraAnimalRow {
  CompraAnimalRow({required String brinco, required String peso})
    : brincoController = TextEditingController(text: brinco),
      pesoController = TextEditingController(text: peso);

  final TextEditingController brincoController;
  final TextEditingController pesoController;

  void dispose() {
    brincoController.dispose();
    pesoController.dispose();
  }
}

class CompraFormPageController extends ChangeNotifier {
  CompraFormPageController(
    this._addController,
    this._editController,
    this._getListController,
    this._lotsController,
    this._potreirosController,
    this._getFazendasUsecase,
    this._getParceirosUsecase,
    this._createParceiroUsecase,
  ) {
    _addController.addListener(notifyListeners);
    _editController.addListener(notifyListeners);
    _getListController.addListener(notifyListeners);
    _lotsController.addListener(notifyListeners);
    _potreirosController.addListener(notifyListeners);
    dataController.addListener(notifyListeners);
    valorUnitarioController.addListener(notifyListeners);
    valorFreteController.addListener(notifyListeners);
    valorComissaoController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
    quantidadeController.addListener(_onQuantidadeChanged);
    loteQtdController.addListener(_onLotePesoChanged);
    lotePesoTotalController.addListener(_onLotePesoChanged);
    lotePesoMedioController.addListener(notifyListeners);
    novoNomeController.addListener(notifyListeners);
    novoDocumentoController.addListener(notifyListeners);
    novoContatoController.addListener(notifyListeners);
  }

  static const List<String> tiposCompra = ['kg', 'cabeça'];
  static const String tipoCadastroIndividual = 'individual';
  static const String tipoCadastroLote = 'lote';
  static const int _maxAnimalRows = 200;

  final AddCompraController _addController;
  final EditCompraController _editController;
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
  final TextEditingController quantidadeController = TextEditingController();
  final TextEditingController loteQtdController = TextEditingController();
  final TextEditingController lotePesoTotalController = TextEditingController();
  final TextEditingController lotePesoMedioController = TextEditingController();
  final TextEditingController novoNomeController = TextEditingController();
  final TextEditingController novoDocumentoController = TextEditingController();
  final TextEditingController novoContatoController = TextEditingController();

  CompraEntity? _editingCompra;
  List<FazendaEntity> fazendas = const [];
  List<ParceiroEntity> fornecedores = const [];
  int? selectedFarmId;
  int? selectedPotreiroId;
  int? selectedLotId;
  String? selectedTipoCompra = 'cabeça';
  String tipoCadastro = tipoCadastroIndividual;
  CompraFornecedorMode fornecedorMode = CompraFornecedorMode.existente;
  int? selectedFornecedorId;
  int? selectedSexo;
  int? selectedAnimalCategoryId;
  int? selectedAnimalSubcategoryId;
  int? selectedAnimalBaseRacialId;
  bool isLoadingFarms = false;
  bool isLoadingFornecedores = false;
  bool isCreatingFornecedor = false;
  String? farmsError;
  String? fornecedoresError;
  final List<CompraAnimalRow> animalRows = [];
  int _listLoadRequest = 0;
  bool _syncingQuantidade = false;
  bool _syncingLoteMedio = false;
  _CompraFormSnapshot? _initialSnapshot;

  bool get isEdit => _editingCompra != null;
  bool get isLoading =>
      _addController.isLoading ||
      _editController.isLoading ||
      _getListController.isLoading ||
      _lotsController.isLoading ||
      _potreirosController.isLoading ||
      isLoadingFarms ||
      isLoadingFornecedores ||
      isCreatingFornecedor;
  String? get errorMessage =>
      farmsError ??
      fornecedoresError ??
      _addController.errorMessage ??
      _editController.errorMessage ??
      _getListController.errorMessage ??
      _lotsController.errorMessage ??
      _potreirosController.errorMessage;
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

  List<CompraUpsertAnimalEntity> get animais {
    return animalRows
        .map(
          (row) => CompraUpsertAnimalEntity(
            appAnimaisCategoriasId: selectedAnimalCategoryId ?? 0,
            appAnimaisSubcategoriasId: hasAnimalSubcategories
                ? selectedAnimalSubcategoryId
                : null,
            utBasesRaciaisId: selectedAnimalBaseRacialId,
            sexo: selectedSexo ?? 1,
            brinco: row.brincoController.text.trim(),
            pesoTotal: row.pesoController.text.trim(),
          ),
        )
        .toList(growable: false);
  }

  List<ListCategoryEntity> get animalCategories {
    final categories = _getListController.result?.animaisCategorias ?? const [];
    final sexo = selectedSexo;
    if (sexo == null) {
      return const [];
    }
    return categories
        .where((item) => item.sexo == sexo)
        .toList(growable: false);
  }

  List<ListItemEntity> get basesRaciais =>
      _getListController.result?.animaisBasesRaciais ?? const [];

  List<ListSubcategoryEntity> get animalSubcategories {
    final category = animalCategories.cast<ListCategoryEntity?>().firstWhere(
      (item) => item?.id == selectedAnimalCategoryId,
      orElse: () => null,
    );
    return category?.subcategorias ?? const [];
  }

  bool get hasAnimalSubcategories => animalSubcategories.isNotEmpty;
  bool get shouldShowAnimalSubcategory => hasAnimalSubcategories;
  int get selectedAnimalSexo => selectedSexo ?? 1;
  bool get isIndividual => tipoCadastro == tipoCadastroIndividual;
  bool get showFarmSelector => !isEdit && fazendas.length > 1;

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
      selectedPotreiro?.nome ??
      _editingCompra?.potreiro?.nome ??
      'Selecionar piquete';
  String get selectedLotLabel {
    if (selectedPotreiroId == null) {
      return 'Selecione um piquete primeiro';
    }
    return selectedLot?.nome ?? _editingCompra?.lote?.nome ?? 'Selecionar lote';
  }

  String get valorUnitarioLabel => selectedTipoCompra == 'kg'
      ? 'Valor por kg (R\$)'
      : 'Valor por cabeça (R\$)';

  bool get hasChanges =>
      !isEdit ||
      _initialSnapshot == null ||
      _currentSnapshot() != _initialSnapshot;

  bool get isFormValid {
    if (selectedFarmId == null ||
        selectedPotreiroId == null ||
        selectedLotId == null ||
        dataController.text.trim().isEmpty ||
        (BrazilianCurrency.parse(valorUnitarioController.text) ?? 0) <= 0 ||
        !hasChanges) {
      return false;
    }
    if (fornecedorMode == CompraFornecedorMode.existente &&
        selectedFornecedorId == null) {
      return false;
    }
    if (fornecedorMode == CompraFornecedorMode.novo &&
        novoNomeController.text.trim().isEmpty) {
      return false;
    }
    if (isEdit) {
      return true;
    }
    if (selectedSexo == null ||
        selectedAnimalCategoryId == null ||
        selectedTipoCompra == null) {
      return false;
    }
    if (hasAnimalSubcategories && selectedAnimalSubcategoryId == null) {
      return false;
    }
    if (isIndividual) {
      return animalRows.isNotEmpty &&
          animalRows.every(
            (row) =>
                row.brincoController.text.trim().isNotEmpty &&
                row.pesoController.text.trim().isNotEmpty,
          );
    }
    return loteQtdController.text.trim().isNotEmpty &&
        lotePesoTotalController.text.trim().isNotEmpty &&
        lotePesoMedioController.text.trim().isNotEmpty;
  }

  bool get isIdentificacaoComplete {
    if (isEdit) {
      return dataController.text.trim().isNotEmpty;
    }
    if (showFarmSelector && selectedFarmId == null) {
      return false;
    }
    if (dataController.text.trim().isEmpty ||
        selectedSexo == null ||
        selectedAnimalCategoryId == null) {
      return false;
    }
    return !hasAnimalSubcategories || selectedAnimalSubcategoryId != null;
  }

  bool get isDestinoComplete =>
      selectedPotreiroId != null && selectedLotId != null;

  bool get isFornecedorComplete {
    if (fornecedorMode == CompraFornecedorMode.existente) {
      return selectedFornecedorId != null;
    }
    return novoNomeController.text.trim().isNotEmpty;
  }

  bool get isValoresComplete =>
      (BrazilianCurrency.parse(valorUnitarioController.text) ?? 0) > 0 &&
      (isEdit || selectedTipoCompra != null);

  bool get isCadastroComplete {
    if (isIndividual) {
      return animalRows.isNotEmpty &&
          animalRows.every(
            (row) =>
                row.brincoController.text.trim().isNotEmpty &&
                row.pesoController.text.trim().isNotEmpty,
          );
    }
    return loteQtdController.text.trim().isNotEmpty &&
        lotePesoTotalController.text.trim().isNotEmpty &&
        lotePesoMedioController.text.trim().isNotEmpty;
  }

  CompraSummary get summary {
    final unitario = _parseNumber(valorUnitarioController.text) ?? 0;
    final frete = _parseNumber(valorFreteController.text) ?? 0;
    final comissao = _parseNumber(valorComissaoController.text) ?? 0;
    final extras = frete + comissao;

    if (isIndividual) {
      final pesos = animalRows
          .map((row) => _parseNumber(row.pesoController.text))
          .whereType<double>()
          .toList(growable: false);
      final count = animalRows.isEmpty ? 0 : animalRows.length;
      final pesoTotal = pesos.fold<double>(0, (sum, item) => sum + item);
      final pesoMedio = pesos.isEmpty ? 0.0 : pesoTotal / pesos.length;
      final valorMedio = selectedTipoCompra == 'kg'
          ? pesoMedio * unitario
          : unitario;
      final extrasAnimal = count == 0 ? 0.0 : extras / count;
      final custoReal = valorMedio + extrasAnimal;
      final custoKg = pesoMedio == 0 ? 0.0 : custoReal / pesoMedio;
      return CompraSummary(
        pesoMedio: pesoMedio,
        valorMedioAnimal: valorMedio,
        extrasPorAnimal: extrasAnimal,
        custoRealAnimal: custoReal,
        custoRealKg: custoKg,
      );
    }

    final qtd = int.tryParse(loteQtdController.text.trim()) ?? 0;
    final pesoTotal = _parseNumber(lotePesoTotalController.text) ?? 0;
    final pesoMedio = qtd == 0
        ? (_parseNumber(lotePesoMedioController.text) ?? 0)
        : pesoTotal / qtd;
    final valorMedio = selectedTipoCompra == 'kg'
        ? pesoMedio * unitario
        : unitario;
    final extrasAnimal = qtd == 0 ? 0.0 : extras / qtd;
    final custoReal = valorMedio + extrasAnimal;
    final custoKg = pesoMedio == 0 ? 0.0 : custoReal / pesoMedio;
    return CompraSummary(
      pesoMedio: pesoMedio,
      valorMedioAnimal: valorMedio,
      extrasPorAnimal: extrasAnimal,
      custoRealAnimal: custoReal,
      custoRealKg: custoKg,
    );
  }

  double animalLineValue(CompraAnimalRow row) {
    final unitario = _parseNumber(valorUnitarioController.text) ?? 0;
    if (selectedTipoCompra == 'kg') {
      return (_parseNumber(row.pesoController.text) ?? 0) * unitario;
    }
    return unitario;
  }

  Future<void> init({CompraEntity? compra}) async {
    _editingCompra = compra;
    if (compra != null) {
      selectedPotreiroId = compra.appPotreirosId ?? compra.potreiro?.id;
      selectedLotId = compra.appAnimaisLotesId ?? compra.lote?.id;
      selectedTipoCompra = tiposCompra.contains(compra.tipoCompra)
          ? compra.tipoCompra
          : 'cabeça';
      selectedFornecedorId = compra.idFornecedor;
      dataController.text = compra.data;
      valorUnitarioController.text =
          BrazilianCurrency.formatFromRaw(compra.valorUnitario) ??
          (compra.valorUnitarioRaw != null
              ? BrazilianCurrency.format(compra.valorUnitarioRaw!)
              : '');
      valorFreteController.text =
          BrazilianCurrency.formatFromRaw(compra.valorFrete) ?? '';
      valorComissaoController.text =
          BrazilianCurrency.formatFromRaw(compra.valorComissao) ?? '';
      obsController.text = compra.obs ?? '';
      if (compra.animais.isNotEmpty) {
        tipoCadastro = tipoCadastroIndividual;
        quantidadeController.text = '${compra.animais.length}';
        _replaceAnimalRows(
          compra.animais
              .map(
                (animal) => CompraAnimalRow(
                  brinco: animal.brinco ?? '',
                  peso: animal.pesoTotal?.toStringAsFixed(2) ?? '',
                ),
              )
              .toList(),
        );
      } else {
        tipoCadastro = tipoCadastroLote;
        loteQtdController.text = '${compra.qtdAnimais}';
        if (compra.pesoTotal != null) {
          lotePesoTotalController.text = compra.pesoTotal!.toStringAsFixed(2);
        }
        if (compra.pesoMedio != null) {
          lotePesoMedioController.text = compra.pesoMedio!.toStringAsFixed(2);
        }
      }
    } else {
      final now = DateTime.now();
      dataController.text =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    }

    try {
      await Future.wait([
        _loadFazendas(preferredFarmId: compra?.appFazendasId),
        _lotsController.load(),
        _potreirosController.load(),
      ]);
      if (!isEdit && selectedSexo != null) {
        await _loadAnimalLists(selectedSexo!);
      }
      if (isEdit) {
        _matchFornecedorFromEditing();
      }
      notifyListeners();
      _initialSnapshot = _currentSnapshot();
    } catch (_) {
      notifyListeners();
    }
  }

  Future<void> reloadLots() => _lotsController.load();
  Future<void> reloadPotreiros() => _potreirosController.load();

  void selectNewestPotreiro() {
    if (potreiros.isEmpty) {
      return;
    }
    var newest = potreiros.first;
    for (final item in potreiros) {
      if (item.id > newest.id) {
        newest = item;
      }
    }
    selectedPotreiroId = newest.id;
    if (selectedLotId != null && !lots.any((lot) => lot.id == selectedLotId)) {
      selectedLotId = null;
    }
    notifyListeners();
  }

  void selectNewestLot() {
    if (lots.isEmpty) {
      return;
    }
    var newest = lots.first;
    for (final item in lots) {
      if (item.id > newest.id) {
        newest = item;
      }
    }
    selectedLotId = newest.id;
    notifyListeners();
  }

  void onFarmChanged(int? value) {
    if (value == null || value == selectedFarmId) {
      return;
    }
    selectedFarmId = value;
    selectedFornecedorId = null;
    fornecedores = const [];
    notifyListeners();
    _loadFornecedores();
  }

  void onPotreiroChanged(int? value) {
    selectedPotreiroId = value;
    if (selectedLotId != null && !lots.any((lot) => lot.id == selectedLotId)) {
      selectedLotId = null;
    }
    notifyListeners();
  }

  void onLotChanged(int? value) {
    selectedLotId = value;
    notifyListeners();
  }

  void onTipoCompraChanged(String? value) {
    selectedTipoCompra = value;
    notifyListeners();
  }

  void onTipoCadastroChanged(String value) {
    tipoCadastro = value;
    notifyListeners();
  }

  void onFornecedorModeChanged(CompraFornecedorMode mode) {
    fornecedorMode = mode;
    notifyListeners();
  }

  void onFornecedorChanged(int? value) {
    selectedFornecedorId = value;
    notifyListeners();
  }

  Future<void> onAnimalSexoChanged(int value) async {
    final request = ++_listLoadRequest;
    selectedSexo = value;
    selectedAnimalCategoryId = null;
    selectedAnimalSubcategoryId = null;
    selectedAnimalBaseRacialId = null;
    _getListController.clear();
    notifyListeners();
    try {
      await _loadAnimalLists(value);
      if (request != _listLoadRequest) {
        return;
      }
      notifyListeners();
    } catch (_) {}
  }

  void onAnimalCategoryChanged(int? value) {
    selectedAnimalCategoryId = value;
    selectedAnimalSubcategoryId = null;
    notifyListeners();
  }

  void onAnimalSubcategoryChanged(int? value) {
    selectedAnimalSubcategoryId = hasAnimalSubcategories ? value : null;
    notifyListeners();
  }

  void onAnimalBaseRacialChanged(int? value) {
    selectedAnimalBaseRacialId = value;
    notifyListeners();
  }

  PageActionResult addAnimal({
    required String brinco,
    required String pesoTotal,
  }) {
    return addAnimalEntity(
      CompraUpsertAnimalEntity(
        appAnimaisCategoriasId: selectedAnimalCategoryId ?? 0,
        appAnimaisSubcategoriasId: selectedAnimalSubcategoryId,
        utBasesRaciaisId: selectedAnimalBaseRacialId,
        sexo: selectedSexo ?? 1,
        brinco: brinco,
        pesoTotal: pesoTotal,
      ),
    );
  }

  PageActionResult addAnimalEntity(CompraUpsertAnimalEntity animal) {
    if (animal.brinco.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o brinco do animal.',
      );
    }
    if (animal.pesoTotal.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o peso total do animal.',
      );
    }

    _addAnimalRow(
      CompraAnimalRow(
        brinco: animal.brinco.trim(),
        peso: animal.pesoTotal.trim(),
      ),
    );
    _syncingQuantidade = true;
    quantidadeController.text = '${animalRows.length}';
    _syncingQuantidade = false;
    notifyListeners();
    return const PageActionResult(
      isSuccess: true,
      message: 'Animal adicionado.',
    );
  }

  void updateAnimal(int index, CompraUpsertAnimalEntity animal) {
    if (index < 0 || index >= animalRows.length) {
      return;
    }
    animalRows[index].brincoController.text = animal.brinco;
    animalRows[index].pesoController.text = animal.pesoTotal;
    notifyListeners();
  }

  void removeAnimal(int index) {
    if (index < 0 || index >= animalRows.length) {
      return;
    }
    animalRows.removeAt(index).dispose();
    _syncingQuantidade = true;
    quantidadeController.text = animalRows.isEmpty
        ? ''
        : '${animalRows.length}';
    _syncingQuantidade = false;
    notifyListeners();
  }

  String animalCategoryLabel(int id) {
    for (final category in animalCategories) {
      if (category.id == id) {
        return category.nome.trim();
      }
    }
    return 'Categoria $id';
  }

  String? animalSubcategoryLabel(int? id) {
    if (id == null) {
      return null;
    }
    for (final item in animalSubcategories) {
      if (item.id == id) {
        return item.nome.trim();
      }
    }
    return 'Subcategoria $id';
  }

  String? animalBaseRacialLabel(int? id) {
    if (id == null) {
      return null;
    }
    for (final item in basesRaciais) {
      if (item.id == id) {
        return item.nome.trim();
      }
    }
    return 'Base racial $id';
  }

  Future<PageActionResult> submit() async {
    final validation = _validateForm();
    if (validation != null) {
      return validation;
    }

    try {
      final fornecedorId = await _resolveFornecedorId();
      if (fornecedorId == null) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Informe o fornecedor.',
        );
      }

      final entity = isEdit
          ? CompraUpsertEntity(
              id: _editingCompra?.id,
              appFazendasId: selectedFarmId!,
              appPotreirosId: selectedPotreiroId!,
              appAnimaisLotesId: selectedLotId!,
              data: dataController.text.trim(),
              sexo: selectedSexo ?? 1,
              appAnimaisCategoriasId: selectedAnimalCategoryId ?? 0,
              tipoCompra: selectedTipoCompra ?? 'cabeça',
              tipoCadastro: tipoCadastro,
              valorUnitario: BrazilianCurrency.toApi(
                valorUnitarioController.text,
              ),
              valorFrete: BrazilianCurrency.toApiOrNull(
                valorFreteController.text,
              ),
              valorComissao: BrazilianCurrency.toApiOrNull(
                valorComissaoController.text,
              ),
              idFornecedor: fornecedorId,
              obs: _emptyToNull(obsController.text),
              animais: const [],
            )
          : CompraUpsertEntity(
              id: _editingCompra?.id,
              appFazendasId: selectedFarmId!,
              appPotreirosId: selectedPotreiroId!,
              appAnimaisLotesId: selectedLotId!,
              data: dataController.text.trim(),
              sexo: selectedSexo!,
              appAnimaisCategoriasId: selectedAnimalCategoryId!,
              appAnimaisSubcategoriasId: hasAnimalSubcategories
                  ? selectedAnimalSubcategoryId
                  : null,
              utBasesRaciaisId: selectedAnimalBaseRacialId,
              tipoCompra: selectedTipoCompra!,
              tipoCadastro: tipoCadastro,
              valorUnitario: BrazilianCurrency.toApi(
                valorUnitarioController.text,
              ),
              valorFrete: BrazilianCurrency.toApiOrNull(
                valorFreteController.text,
              ),
              valorComissao: BrazilianCurrency.toApiOrNull(
                valorComissaoController.text,
              ),
              idFornecedor: fornecedorId,
              obs: _emptyToNull(obsController.text),
              qtdAnimais: isIndividual
                  ? animalRows.length
                  : int.tryParse(loteQtdController.text.trim()),
              pesoTotal: isIndividual
                  ? null
                  : lotePesoTotalController.text.trim(),
              pesoMedio: isIndividual
                  ? null
                  : lotePesoMedioController.text.trim(),
              animais: isIndividual ? animais : const [],
            );

      final result = isEdit
          ? await _editController.submit(entity)
          : await _addController.submit(entity);
      if (result == null) {
        return PageActionResult(
          isSuccess: false,
          message: isEdit
              ? 'Não foi possível atualizar a compra.'
              : 'Não foi possível salvar a compra.',
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
                ? 'Não foi possível atualizar a compra.'
                : 'Não foi possível salvar a compra.'),
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
    if (selectedPotreiroId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o piquete de destino.',
      );
    }
    if (selectedLotId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o lote de destino.',
      );
    }
    if (dataController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe a data da compra.',
      );
    }
    if ((BrazilianCurrency.parse(valorUnitarioController.text) ?? 0) <= 0) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o valor.',
      );
    }
    if (fornecedorMode == CompraFornecedorMode.existente &&
        selectedFornecedorId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o fornecedor.',
      );
    }
    if (fornecedorMode == CompraFornecedorMode.novo &&
        novoNomeController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe o nome do novo cadastro.',
      );
    }
    if (isEdit) {
      return null;
    }
    if (selectedSexo == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o sexo.',
      );
    }
    if (selectedAnimalCategoryId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione a categoria.',
      );
    }
    if (hasAnimalSubcategories && selectedAnimalSubcategoryId == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione a fase do animal.',
      );
    }
    if (selectedTipoCompra == null) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Selecione o tipo de valor.',
      );
    }
    if (isIndividual) {
      if (animalRows.isEmpty) {
        return const PageActionResult(
          isSuccess: false,
          message: 'Informe a quantidade de animais.',
        );
      }
      for (var i = 0; i < animalRows.length; i++) {
        if (animalRows[i].brincoController.text.trim().isEmpty ||
            animalRows[i].pesoController.text.trim().isEmpty) {
          return PageActionResult(
            isSuccess: false,
            message: 'Preencha brinco e peso da linha ${i + 1}.',
          );
        }
      }
    } else if (loteQtdController.text.trim().isEmpty ||
        lotePesoTotalController.text.trim().isEmpty ||
        lotePesoMedioController.text.trim().isEmpty) {
      return const PageActionResult(
        isSuccess: false,
        message: 'Informe quantidade, peso total e peso médio do lote.',
      );
    }
    return null;
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
        await _loadFornecedores();
      }
    } catch (_) {
      farmsError = 'Nao foi possivel carregar as fazendas.';
    } finally {
      isLoadingFarms = false;
      notifyListeners();
    }
  }

  void _matchFornecedorFromEditing() {
    final compra = _editingCompra;
    if (compra == null || fornecedores.isEmpty) {
      return;
    }
    if (compra.idFornecedor != null) {
      final byId = fornecedores.where((item) => item.id == compra.idFornecedor);
      if (byId.isNotEmpty) {
        selectedFornecedorId = byId.first.id;
        fornecedorMode = CompraFornecedorMode.existente;
        return;
      }
    }
    final nome = compra.fornecedor?.trim().toLowerCase();
    if (nome == null || nome.isEmpty) {
      return;
    }
    final byName = fornecedores.where(
      (item) => item.nome.trim().toLowerCase() == nome,
    );
    if (byName.isNotEmpty) {
      selectedFornecedorId = byName.first.id;
      fornecedorMode = CompraFornecedorMode.existente;
    }
  }

  Future<void> _loadAnimalLists(int sexo) {
    return _getListController.load(sexo);
  }

  Future<void> _loadFornecedores() async {
    final farmId = selectedFarmId;
    if (farmId == null) {
      return;
    }
    isLoadingFornecedores = true;
    fornecedoresError = null;
    notifyListeners();
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw Exception('Usuario nao autenticado.');
      }
      final result = await _getParceirosUsecase(
        ParceiroFilterEntity(
          kind: ParceiroKind.fornecedor,
          appUsersId: user.id,
          appFazendasId: farmId,
        ),
      );
      fornecedores = result.data;
      if (fornecedores.isEmpty && selectedFornecedorId == null) {
        fornecedorMode = CompraFornecedorMode.novo;
      }
    } catch (_) {
      fornecedoresError = 'Nao foi possivel carregar os fornecedores.';
    } finally {
      isLoadingFornecedores = false;
      notifyListeners();
    }
  }

  Future<int?> _resolveFornecedorId() async {
    if (fornecedorMode == CompraFornecedorMode.existente) {
      return selectedFornecedorId;
    }

    final farmId = selectedFarmId;
    if (farmId == null) {
      return null;
    }

    isCreatingFornecedor = true;
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
          kind: ParceiroKind.fornecedor,
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

      await _loadFornecedores();
      final match = fornecedores.cast<ParceiroEntity?>().firstWhere(
        (item) => item?.nome.trim().toLowerCase() == nome.toLowerCase(),
        orElse: () => fornecedores.isEmpty ? null : fornecedores.last,
      );
      selectedFornecedorId = match?.id;
      if (match != null) {
        fornecedorMode = CompraFornecedorMode.existente;
      }
      return selectedFornecedorId;
    } finally {
      isCreatingFornecedor = false;
      notifyListeners();
    }
  }

  void _onQuantidadeChanged() {
    notifyListeners();
    if (_syncingQuantidade || !isIndividual) {
      return;
    }
    final parsed = int.tryParse(quantidadeController.text.trim()) ?? 0;
    final count = parsed.clamp(0, _maxAnimalRows);
    _syncAnimalRowCount(count);
  }

  void _onLotePesoChanged() {
    if (!_syncingLoteMedio && !isIndividual) {
      final qtd = int.tryParse(loteQtdController.text.trim()) ?? 0;
      final total = _parseNumber(lotePesoTotalController.text);
      if (qtd > 0 && total != null) {
        _syncingLoteMedio = true;
        lotePesoMedioController.text = (total / qtd)
            .toStringAsFixed(2)
            .replaceAll('.', ',');
        _syncingLoteMedio = false;
      }
    }
    notifyListeners();
  }

  void _syncAnimalRowCount(int count) {
    while (animalRows.length > count) {
      animalRows.removeLast().dispose();
    }
    while (animalRows.length < count) {
      final index = animalRows.length + 1;
      _addAnimalRow(
        CompraAnimalRow(brinco: index.toString().padLeft(4, '0'), peso: ''),
      );
    }
    notifyListeners();
  }

  void _replaceAnimalRows(List<CompraAnimalRow> rows) {
    for (final row in animalRows) {
      row.dispose();
    }
    animalRows
      ..clear()
      ..addAll(rows);
    for (final row in animalRows) {
      row.brincoController.addListener(notifyListeners);
      row.pesoController.addListener(notifyListeners);
    }
  }

  void _addAnimalRow(CompraAnimalRow row) {
    row.brincoController.addListener(notifyListeners);
    row.pesoController.addListener(notifyListeners);
    animalRows.add(row);
  }

  _CompraFormSnapshot _currentSnapshot() {
    return _CompraFormSnapshot(
      selectedFarmId: selectedFarmId,
      selectedPotreiroId: selectedPotreiroId,
      selectedLotId: selectedLotId,
      selectedTipoCompra: selectedTipoCompra,
      tipoCadastro: tipoCadastro,
      selectedSexo: selectedSexo,
      selectedCategoryId: selectedAnimalCategoryId,
      selectedFornecedorId: selectedFornecedorId,
      data: dataController.text.trim(),
      valorUnitario: valorUnitarioController.text.trim(),
      obs: obsController.text.trim(),
    );
  }

  double? _parseNumber(String value) => BrazilianCurrency.parse(value);

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  void dispose() {
    _addController.removeListener(notifyListeners);
    _editController.removeListener(notifyListeners);
    _getListController.removeListener(notifyListeners);
    _lotsController.removeListener(notifyListeners);
    _potreirosController.removeListener(notifyListeners);
    dataController.dispose();
    valorUnitarioController.dispose();
    valorFreteController.dispose();
    valorComissaoController.dispose();
    obsController.dispose();
    quantidadeController.dispose();
    loteQtdController.dispose();
    lotePesoTotalController.dispose();
    lotePesoMedioController.dispose();
    novoNomeController.dispose();
    novoDocumentoController.dispose();
    novoContatoController.dispose();
    for (final row in animalRows) {
      row.dispose();
    }
    super.dispose();
  }
}

class CompraSummary {
  const CompraSummary({
    required this.pesoMedio,
    required this.valorMedioAnimal,
    required this.extrasPorAnimal,
    required this.custoRealAnimal,
    required this.custoRealKg,
  });

  final double pesoMedio;
  final double valorMedioAnimal;
  final double extrasPorAnimal;
  final double custoRealAnimal;
  final double custoRealKg;
}

class _CompraFormSnapshot {
  const _CompraFormSnapshot({
    required this.selectedFarmId,
    required this.selectedPotreiroId,
    required this.selectedLotId,
    required this.selectedTipoCompra,
    required this.tipoCadastro,
    required this.selectedSexo,
    required this.selectedCategoryId,
    required this.selectedFornecedorId,
    required this.data,
    required this.valorUnitario,
    required this.obs,
  });

  final int? selectedFarmId;
  final int? selectedPotreiroId;
  final int? selectedLotId;
  final String? selectedTipoCompra;
  final String tipoCadastro;
  final int? selectedSexo;
  final int? selectedCategoryId;
  final int? selectedFornecedorId;
  final String data;
  final String valorUnitario;
  final String obs;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _CompraFormSnapshot &&
            other.selectedFarmId == selectedFarmId &&
            other.selectedPotreiroId == selectedPotreiroId &&
            other.selectedLotId == selectedLotId &&
            other.selectedTipoCompra == selectedTipoCompra &&
            other.tipoCadastro == tipoCadastro &&
            other.selectedSexo == selectedSexo &&
            other.selectedCategoryId == selectedCategoryId &&
            other.selectedFornecedorId == selectedFornecedorId &&
            other.data == data &&
            other.valorUnitario == valorUnitario &&
            other.obs == obs;
  }

  @override
  int get hashCode => Object.hash(
    selectedFarmId,
    selectedPotreiroId,
    selectedLotId,
    selectedTipoCompra,
    tipoCadastro,
    selectedSexo,
    selectedCategoryId,
    selectedFornecedorId,
    data,
    valorUnitario,
    obs,
  );
}
