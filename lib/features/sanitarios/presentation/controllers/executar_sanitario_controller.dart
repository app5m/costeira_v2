import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_tipo_usecase.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/usecases/executar_sanitario_usecase.dart';
import 'package:flutter/material.dart';

class ExecutarSanitarioController extends ChangeNotifier {
  ExecutarSanitarioController(
    this._executarSanitarioUsecase,
    this._getInsumosTipoUsecase,
  ) {
    quantidadeController.addListener(_onQuantidadeChanged);
  }

  final ExecutarSanitarioUsecase _executarSanitarioUsecase;
  final GetInsumosTipoUsecase _getInsumosTipoUsecase;
  final quantidadeController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  int? _currentUserId;
  int? _selectedInsumoId;
  List<InsumoTipoEntity> _insumos = const [];
  List<SanitarioExecucaoItemEntity> _itens = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedInsumoId => _selectedInsumoId;
  List<InsumoTipoEntity> get insumos => _insumos;
  List<SanitarioExecucaoItemEntity> get itens => _itens;
  bool get canAddItem =>
      _selectedInsumoId != null &&
      (_parseDecimal(quantidadeController.text) ?? 0) > 0 &&
      quantidadeRestanteSelecionada > 0;
  bool get canSubmit => _itens.isNotEmpty && !_isLoading;

  InsumoTipoEntity? get selectedInsumo {
    final matches = _insumos.where((item) => item.id == _selectedInsumoId);
    return matches.isEmpty ? null : matches.first;
  }

  String get unidadeSelecionada {
    final unidade = selectedInsumo?.unidade?.nome.trim();
    return unidade == null || unidade.isEmpty ? '' : unidade;
  }

  double get quantidadeRestanteSelecionada {
    final insumo = selectedInsumo;
    if (insumo == null) return 0;
    final saldo = insumo.qtdTotal ?? 0;
    final jaAdicionado = _quantidadeAdicionada(insumo.id);
    final restante = saldo - jaAdicionado;
    return restante < 0 ? 0 : restante;
  }

  String get quantidadeMaximaLabel {
    final unidade = unidadeSelecionada;
    final maximo = _formatDecimal(quantidadeRestanteSelecionada);
    return unidade.isEmpty ? maximo : '$maximo $unidade';
  }

  Future<void> init() async {
    _selectedInsumoId = null;
    _itens = const [];
    quantidadeController.clear();
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      _currentUserId = user?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      await _loadMedicamentos();
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } finally {
      _setLoading(false);
    }
  }

  void onInsumoChanged(int? value) {
    _selectedInsumoId = value;
    quantidadeController.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void incrementQuantidade() {
    final value = _parseDecimal(quantidadeController.text) ?? 0;
    final next = value + 1;
    quantidadeController.text = _formatDecimal(
      next > quantidadeRestanteSelecionada
          ? quantidadeRestanteSelecionada
          : next,
    );
  }

  void decrementQuantidade() {
    final value = _parseDecimal(quantidadeController.text) ?? 0;
    quantidadeController.text = _formatDecimal(value <= 1 ? 0 : value - 1);
  }

  bool addItem() {
    final insumo = selectedInsumo;
    final quantidade = _parseDecimal(quantidadeController.text);
    if (insumo == null || quantidade == null || quantidade <= 0) {
      _errorMessage = 'Informe o insumo e uma quantidade valida.';
      notifyListeners();
      return false;
    }

    final saldo = insumo.qtdTotal ?? 0;
    final quantidadeJaAdicionada = _quantidadeAdicionada(insumo.id);
    final quantidadeTotal = quantidadeJaAdicionada + quantidade;

    if (quantidadeTotal > saldo) {
      _errorMessage =
          'Quantidade maior que o saldo disponivel (${_formatDecimal(saldo)} ${_unidade(insumo)}).';
      notifyListeners();
      return false;
    }

    final existingIndex = _itens.indexWhere(
      (item) => item.insumo.id == insumo.id,
    );
    final nextItens = [..._itens];
    if (existingIndex >= 0) {
      final current = nextItens[existingIndex];
      nextItens[existingIndex] = current.copyWith(
        quantidade: current.quantidade + quantidade,
      );
    } else {
      nextItens.add(
        SanitarioExecucaoItemEntity(insumo: insumo, quantidade: quantidade),
      );
    }

    _itens = nextItens;
    _selectedInsumoId = null;
    quantidadeController.clear();
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void removeItem(int insumoId) {
    _itens = _itens.where((item) => item.insumo.id != insumoId).toList();
    notifyListeners();
  }

  Future<ApiMessage?> submit({
    required int sanitarioId,
    required String dataExecucao,
  }) async {
    if (_itens.isEmpty) {
      _errorMessage = 'Adicione ao menos um insumo utilizado.';
      notifyListeners();
      return null;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUserId ??= (await SessionStorage.getUserSession())?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      await _loadMedicamentos();
      _validateItensWithCurrentStock();

      final execucao = SanitarioExecucaoEntity(
        id: sanitarioId,
        appUsersId: _currentUserId,
        dataExecucao: dataExecucao,
        insumos: _itens
            .map(
              (item) => SanitarioExecucaoInsumoEntity(
                idInsumo: item.insumo.id,
                quantidade: item.quantidade,
              ),
            )
            .toList(growable: false),
      );

      return _executarSanitarioUsecase(execucao);
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  String insumoLabel(InsumoTipoEntity insumo) {
    final saldo = insumo.qtdTotal;
    if (saldo == null) return insumo.nome;
    final unidade = _unidade(insumo);
    return unidade.isEmpty
        ? '${insumo.nome} - ${_formatDecimal(saldo)}'
        : '${insumo.nome} - ${_formatDecimal(saldo)} $unidade';
  }

  String itemQuantityLabel(SanitarioExecucaoItemEntity item) {
    final unidade = _unidade(item.insumo);
    return unidade.isEmpty
        ? _formatDecimal(item.quantidade)
        : '${_formatDecimal(item.quantidade)} $unidade';
  }

  Future<void> _loadMedicamentos() async {
    final userId = _currentUserId;
    if (userId == null) {
      throw ApiException('Usuario nao autenticado.');
    }

    for (final tipo in const ['medicamentos', 'medicamento']) {
      final result = await _getInsumosTipoUsecase(
        InsumosTipoFilterEntity(appUsersId: userId, tipo: tipo),
      );
      if (result.data.isNotEmpty || tipo == 'medicamento') {
        _insumos = result.data;
        return;
      }
    }
  }

  void _validateItensWithCurrentStock() {
    for (final item in _itens) {
      final current = _insumos.where((insumo) => insumo.id == item.insumo.id);
      if (current.isEmpty) {
        throw ApiException(
          'O insumo ${item.insumo.nome} nao esta mais disponivel para execucao.',
        );
      }
      final saldo = current.first.qtdTotal ?? 0;
      if (item.quantidade > saldo) {
        throw ApiException(
          'Saldo insuficiente para ${item.insumo.nome}. Disponivel: ${_formatDecimal(saldo)} ${_unidade(current.first)}.',
        );
      }
    }
  }

  void _onQuantidadeChanged() {
    final maximo = quantidadeRestanteSelecionada;
    final value = _parseDecimal(quantidadeController.text);
    if (value != null && value > maximo) {
      final selection = TextSelection.collapsed(
        offset: _formatDecimal(maximo).length,
      );
      quantidadeController.value = TextEditingValue(
        text: _formatDecimal(maximo),
        selection: selection,
      );
      return;
    }
    notifyListeners();
  }

  double _quantidadeAdicionada(int insumoId) {
    return _itens
        .where((item) => item.insumo.id == insumoId)
        .fold<double>(0, (total, item) => total + item.quantidade);
  }

  String _unidade(InsumoTipoEntity insumo) {
    return insumo.unidade?.nome.trim() ?? '';
  }

  double? _parseDecimal(String value) {
    final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  String _formatDecimal(double value) {
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceAll('.', ',');
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    quantidadeController.removeListener(_onQuantidadeChanged);
    quantidadeController.dispose();
    super.dispose();
  }
}

class SanitarioExecucaoItemEntity {
  const SanitarioExecucaoItemEntity({
    required this.insumo,
    required this.quantidade,
  });

  final InsumoTipoEntity insumo;
  final double quantidade;

  SanitarioExecucaoItemEntity copyWith({double? quantidade}) {
    return SanitarioExecucaoItemEntity(
      insumo: insumo,
      quantidade: quantidade ?? this.quantidade,
    );
  }
}
