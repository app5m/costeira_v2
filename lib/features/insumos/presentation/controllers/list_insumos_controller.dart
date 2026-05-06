import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/get_insumos_usecase.dart';
import 'package:flutter/foundation.dart';

class ListInsumosController extends ChangeNotifier {
  ListInsumosController(this._getInsumosUsecase);

  final GetInsumosUsecase _getInsumosUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<InsumoEntity> _insumos = const [];
  List<InsumoRegistroEntity> _registros = const [];
  List<InsumoReferenceEntity> _tipoInsumos = const [];
  int _rows = 0;
  InsumosFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<InsumoEntity> get insumos => _insumos;
  List<InsumoRegistroEntity> get registros => _registros;
  List<InsumoReferenceEntity> get tipoInsumos => _tipoInsumos;
  int get rows => _rows;
  InsumosFilterEntity? get currentFilter => _currentFilter;

  Future<void> load({int? id, String? tipoInsumo}) async {
    AppLogger.info('INSUMOS LIST CONTROLLER: INICIANDO CARREGAMENTO');
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        AppLogger.error('INSUMOS LIST CONTROLLER: USUARIO NAO AUTENTICADO');
        throw ApiException('Usuario nao autenticado.');
      }

      _currentFilter = InsumosFilterEntity(
        appUsersId: user.id,
        id: id,
        tipoInsumo: tipoInsumo,
      );

      final result = await _getInsumosUsecase(_currentFilter!);
      _insumos = result.lista;
      _registros = result.registros;
      _tipoInsumos = result.tipoInsumos;
      _rows = result.rows;
      AppLogger.success(
        'INSUMOS LIST CONTROLLER: LISTA CARREGADA COM ${result.rows} REGISTROS',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'INSUMOS LIST CONTROLLER: ERRO AO LISTAR MSG=${error.message}',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reload() async {
    final filter = _currentFilter;
    if (filter == null) {
      await load();
      return;
    }
    await load(id: filter.id, tipoInsumo: filter.tipoInsumo);
  }

  bool hasActiveFilters() {
    return currentFilter?.tipoInsumo?.trim().isNotEmpty ?? false;
  }

  String tipoLabel(String tipoInsumo) {
    final normalized = tipoInsumo.trim();
    final match = _tipoInsumos.where(
      (tipo) => tipo.id?.toString() == normalized,
    );
    if (match.isNotEmpty) {
      return match.first.nome;
    }
    if (normalized.isEmpty) {
      return 'Insumo';
    }
    return normalized[0].toUpperCase() + normalized.substring(1);
  }

  String buildDescription(InsumoEntity insumo) {
    final parts = <String?>[
      insumo.nome,
      insumo.suplemento?.nome,
    ].whereType<String>().where((item) => item.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'Sem detalhes informados' : parts.join(' - ');
  }

  String buildQuantity(InsumoEntity insumo) {
    final unidade = insumo.unidade?.nome.trim();
    final quantity = insumo.qtdTotal;
    final formattedQuantity = quantity == null
        ? null
        : quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toString();
    final value = insumo.valorUnidade?.trim();

    return <String?>[
      formattedQuantity == null
          ? null
          : unidade == null || unidade.isEmpty
          ? formattedQuantity
          : '$formattedQuantity $unidade',
      value == null || value.isEmpty
          ? null
          : unidade == null || unidade.isEmpty
          ? value
          : '$value/$unidade',
    ].whereType<String>().join(' - ');
  }

  String buildRegistroQuantity(InsumoRegistroEntity registro) {
    final unidade = registro.unidade?.nome.trim();
    final quantity = registro.qtd;
    if (quantity == null) {
      return 'Quantidade nao informada';
    }

    final formattedQuantity = quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toString();
    if (unidade == null || unidade.isEmpty) {
      return formattedQuantity;
    }
    return '$formattedQuantity $unidade';
  }

  void removeInsumoById(int insumoId) {
    _insumos = _insumos.where((insumo) => insumo.id != insumoId).toList();
    _rows = _insumos.length;
    notifyListeners();
  }

  void removeRegistroById(int registroId) {
    _registros = _registros
        .where((registro) => registro.id != registroId)
        .toList();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    AppLogger.debug('INSUMOS LIST CONTROLLER: LOADING=$value');
    notifyListeners();
  }
}
