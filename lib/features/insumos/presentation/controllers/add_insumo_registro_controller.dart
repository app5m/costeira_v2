import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/common/get_list/domain/entities/get_list_params_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_category_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_item_entity.dart';
import 'package:costeira/core/common/get_list/domain/entities/list_subcategory_entity.dart';
import 'package:costeira/core/common/get_list/domain/usecases/get_list_usecase.dart';
import 'package:costeira/core/input_formatters/brazilian_currency_input_formatter.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_filter_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/domain/usecases/get_parceiros_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/movimentar_estoque_usecase.dart';
import 'package:flutter/material.dart';

class AddInsumoRegistroController extends ChangeNotifier {
  AddInsumoRegistroController(
    this._movimentarEstoqueUsecase,
    this._getInsumosUsecase,
    this._getListUsecase,
    this._getParceirosUsecase,
    this._resolveCurrentFarmId, {
    required this.isSaida,
    bool produtoNovo = false,
  }) : _produtoNovo = produtoNovo {
    dataController.addListener(notifyListeners);
    nomeController.addListener(notifyListeners);
    qtdController.addListener(notifyListeners);
    valorController.addListener(notifyListeners);
    validadeController.addListener(notifyListeners);
    obsController.addListener(notifyListeners);
    dataController.text = _formatDate(DateTime.now());
    if (isSaida) {
      qtdController.text = '0';
    }
  }

  final MovimentarEstoqueUsecase _movimentarEstoqueUsecase;
  final GetInsumosUsecase _getInsumosUsecase;
  final GetListUsecase _getListUsecase;
  final GetParceirosUsecase _getParceirosUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;
  final bool isSaida;

  final dataController = TextEditingController();
  final nomeController = TextEditingController();
  final qtdController = TextEditingController();
  final valorController = TextEditingController();
  final validadeController = TextEditingController();
  final obsController = TextEditingController();

  bool _isLoading = false;
  bool _produtoNovo = false;
  String? _errorMessage;
  int? _currentUserId;
  int? _farmId;
  int? _categoriaId;
  int? _subcategoriaId;
  int? _produtoId;
  int? _unidadeId;
  int? _motivoId;
  int? _fornecedorId;
  List<ListCategoryEntity> _categorias = const [];
  List<InsumoEntity> _insumos = const [];
  List<ListItemEntity> _unidades = const [];
  List<ListItemEntity> _motivos = const [];
  List<ParceiroEntity> _fornecedores = const [];

  bool get isLoading => _isLoading;
  bool get produtoNovo => _produtoNovo;
  String? get errorMessage => _errorMessage;
  int? get farmId => _farmId;
  int? get categoriaId => _categoriaId;
  int? get subcategoriaId => _subcategoriaId;
  int? get produtoId => _produtoId;
  int? get unidadeId => _unidadeId;
  int? get motivoId => _motivoId;
  int? get fornecedorId => _fornecedorId;
  List<ListCategoryEntity> get categorias => _categorias;
  List<ListItemEntity> get unidades => _unidades;
  List<ListItemEntity> get motivos => _motivos;
  List<ParceiroEntity> get fornecedores => _fornecedores;

  List<ListSubcategoryEntity> get subcategorias {
    final match = _categorias.where((item) => item.id == _categoriaId);
    if (match.isEmpty) {
      return const [];
    }
    return match.first.subcategorias;
  }

  List<InsumoEntity> get produtos {
    if (isSaida) {
      return _insumos;
    }
    if (_categoriaId == null || _subcategoriaId == null) {
      return const [];
    }
    final tagged = _insumos.any(
      (item) => item.appEstoquesInsumosCategoriasId != null,
    );
    if (!tagged) {
      return _insumos;
    }
    return _insumos
        .where(
          (item) =>
              item.appEstoquesInsumosCategoriasId == _categoriaId &&
              item.appEstoquesInsumosSubcategoriasId == _subcategoriaId,
        )
        .toList(growable: false);
  }

  InsumoEntity? get produtoSelecionado {
    final match = produtos.where((item) => item.id == _produtoId);
    return match.isEmpty ? null : match.first;
  }

  bool get isFormValid {
    if (dataController.text.trim().isEmpty) {
      return false;
    }
    final quantidade = _parseDecimal(qtdController.text);
    if (quantidade == null || quantidade <= 0) {
      return false;
    }
    if (isSaida) {
      final produto = produtoSelecionado;
      final saldo = produto?.qtdTotal ?? 0;
      return _motivoId != null &&
          produto != null &&
          saldo > 0 &&
          quantidade <= saldo &&
          _unidadeDoProduto(produto) != null &&
          obsController.text.trim().isNotEmpty;
    }
    if (_categoriaId == null || _subcategoriaId == null) {
      return false;
    }
    if (produtoNovo) {
      return nomeController.text.trim().isNotEmpty && _unidadeId != null;
    }
    final produto = produtoSelecionado;
    return produto != null && _unidadeDoProduto(produto) != null;
  }

  String get unidadeLabel {
    if (produtoNovo && !isSaida) {
      return _nomeUnidade(_unidadeId) ?? 'Selecione...';
    }
    final produto = produtoSelecionado;
    if (produto == null) {
      return '—';
    }
    return _nomeUnidade(_unidadeDoProduto(produto)) ?? '—';
  }

  String produtoLabel(InsumoEntity insumo) {
    final saldo = _formatQty(insumo.qtdTotal);
    final unidade = _unidadeNome(insumo);
    final custo = _money(insumo);
    return '${insumo.nome} — saldo $saldo $unidade, custo médio $custo';
  }

  String? get avisoEntrada {
    final produto = produtoSelecionado;
    if (produto == null || produtoNovo || isSaida) {
      return null;
    }
    final saldo = _formatQty(produto.qtdTotal);
    final unidade = _unidadeNome(produto);
    return '${produto.nome} — saldo atual de $saldo $unidade, custo médio ${_money(produto)}. Esta entrada será somada ao saldo existente, recalculando a média ponderada.';
  }

  String? get avisoBaixa {
    final produto = produtoSelecionado;
    if (!isSaida || produto == null) {
      return null;
    }
    return 'Saldo atual: ${_formatQty(produto.qtdTotal)} ${_unidadeNome(produto)} disponíveis para baixa.';
  }

  Future<void> init() async {
    _setLoading(true);
    _errorMessage = null;
    try {
      final user = await SessionStorage.getUserSession();
      _currentUserId = user?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      _farmId = await _resolveCurrentFarmId(userId: _currentUserId);
      if (_farmId == null || _farmId! <= 0) {
        throw ApiException('Selecione uma fazenda antes de registrar.');
      }

      final lists = await _getListUsecase(
        GetListParamsEntity(sexo: 1, userId: _currentUserId),
      );
      _categorias = lists.estoqueInsumosCategorias;
      _motivos = lists.estoqueInsumosMotivos;
      _unidades = lists.estoqueUnidadesMedidas;

      final estoque = await _getInsumosUsecase(
        InsumosFilterEntity(appUsersId: _currentUserId!, appFazendasId: _farmId),
      );
      _insumos = estoque.lista;

      await reloadFornecedores();
      AppLogger.success(
        'INSUMOS MOVIMENTO: CAT=${_categorias.length} ITENS=${_insumos.length} UNIDADES=${_unidades.length}',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reloadFornecedores() async {
    final userId = _currentUserId;
    final farmId = _farmId;
    if (userId == null || farmId == null) {
      return;
    }
    final result = await _getParceirosUsecase(
      ParceiroFilterEntity(
        kind: ParceiroKind.fornecedor,
        appUsersId: userId,
        appFazendasId: farmId,
      ),
    );
    _fornecedores = result.data;
    notifyListeners();
  }

  void onProdutoNovo(bool value) {
    _produtoNovo = value;
    _produtoId = null;
    if (value) {
      _unidadeId = null;
    }
    notifyListeners();
  }

  void onCategoria(int? value) {
    _categoriaId = value;
    _subcategoriaId = null;
    _produtoId = null;
    notifyListeners();
  }

  void onSubcategoria(int? value) {
    _subcategoriaId = value;
    _produtoId = null;
    notifyListeners();
  }

  void onProduto(int? value) {
    _produtoId = value;
    final unidade = produtoSelecionado == null
        ? null
        : _unidadeDoProduto(produtoSelecionado!);
    if (!produtoNovo) {
      _unidadeId = unidade;
    }
    notifyListeners();
  }

  void onUnidade(int? value) {
    _unidadeId = value;
    notifyListeners();
  }

  void onMotivo(int? value) {
    _motivoId = value;
    notifyListeners();
  }

  void onFornecedor(int? value) {
    _fornecedorId = value;
    notifyListeners();
  }

  void setData(DateTime value) {
    dataController.text = _formatDate(value);
  }

  void setValidade(DateTime value) {
    validadeController.text = _formatDate(value);
  }

  Future<ApiMessage?> submit() async {
    if (!isFormValid) {
      _errorMessage = 'Preencha os campos obrigatorios.';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    _errorMessage = null;
    try {
      if (isSaida) {
        return await _submitBaixa();
      }
      if (produtoNovo) {
        return await _submitNovo();
      }
      return await _submitExistente(produtoSelecionado!);
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiMessage> _submitExistente(InsumoEntity produto) {
    return _movimentarEstoqueUsecase(
      EstoqueMovimentoEntity(
        saida: false,
        appUsersId: _currentUserId,
        appFazendasId: _farmId,
        insumoId: produto.id,
        qtdTotal: _parseDecimal(qtdController.text)!,
        obs: _emptyToNull(obsController.text),
        dataValidade: _emptyToNull(validadeController.text),
        valorUnitario: _emptyToNull(BrazilianCurrency.toApi(valorController.text)),
        fornecedorId: _fornecedorId,
      ),
    );
  }

  Future<ApiMessage> _submitNovo() {
    return _movimentarEstoqueUsecase(
      EstoqueMovimentoEntity(
        saida: false,
        appUsersId: _currentUserId,
        appFazendasId: _farmId,
        nome: nomeController.text.trim(),
        categoriaId: _categoriaId,
        subcategoriaId: _subcategoriaId,
        unidadeId: _unidadeId,
        qtdTotal: _parseDecimal(qtdController.text)!,
        obs: _emptyToNull(obsController.text),
        dataValidade: _emptyToNull(validadeController.text),
        valorUnitario: _valorApi(),
        fornecedorId: _fornecedorId,
      ),
    );
  }

  Future<ApiMessage> _submitBaixa() {
    return _movimentarEstoqueUsecase(
      EstoqueMovimentoEntity(
        saida: true,
        appUsersId: _currentUserId,
        appFazendasId: _farmId,
        insumoId: produtoSelecionado!.id,
        motivoId: _motivoId,
        qtdTotal: _parseDecimal(qtdController.text)!,
        obs: obsController.text.trim(),
      ),
    );
  }

  String _valorApi() {
    final api = BrazilianCurrency.toApi(valorController.text);
    return api.isEmpty ? '0,00' : api;
  }

  int? _unidadeDoProduto(InsumoEntity produto) {
    if (produto.appEstoquesInsumosUnidadesId > 0) {
      return produto.appEstoquesInsumosUnidadesId;
    }
    final id = int.tryParse(produto.unidade?.id?.toString() ?? '');
    if (id != null && id > 0) {
      return id;
    }
    final nome = produto.unidade?.nome.trim().toLowerCase();
    if (nome == null || nome.isEmpty) {
      return null;
    }
    final match = _unidades.where((item) => item.nome.toLowerCase() == nome);
    return match.isEmpty ? null : match.first.id;
  }

  String? _nomeUnidade(int? id) {
    if (id == null) {
      return null;
    }
    final match = _unidades.where((item) => item.id == id);
    if (match.isNotEmpty) {
      return match.first.nome;
    }
    return null;
  }

  String _unidadeNome(InsumoEntity produto) {
    final catalogo = _nomeUnidade(_unidadeDoProduto(produto));
    if (catalogo != null) {
      return catalogo;
    }
    final nome = produto.unidade?.nome.trim();
    return nome == null || nome.isEmpty ? 'un' : nome;
  }

  String _money(InsumoEntity produto) {
    final raw = produto.valorUnidadeRaw;
    if (raw != null) {
      return BrazilianCurrency.format(raw);
    }
    final parsed = BrazilianCurrency.parse(produto.valorUnidade ?? '');
    return BrazilianCurrency.format(parsed ?? 0);
  }

  String _formatQty(double? value) {
    if (value == null) {
      return '0';
    }
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  double? _parseDecimal(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return BrazilianCurrency.parse(trimmed) ??
        double.tryParse(trimmed.replaceAll(',', '.'));
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    dataController.dispose();
    nomeController.dispose();
    qtdController.dispose();
    valorController.dispose();
    validadeController.dispose();
    obsController.dispose();
    super.dispose();
  }
}
