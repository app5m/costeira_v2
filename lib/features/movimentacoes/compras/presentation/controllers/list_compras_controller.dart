import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/domain/entities/compra_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/usecases/get_compras_usecase.dart';
import 'package:flutter/foundation.dart';

class ListComprasController extends ChangeNotifier {
  ListComprasController(this._getComprasUsecase);

  final GetComprasUsecase _getComprasUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<CompraEntity> _compras = const [];
  int _rows = 0;
  MovimentacaoFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CompraEntity> get compras => _compras;
  int get rows => _rows;
  MovimentacaoFilterEntity? get currentFilter => _currentFilter;

  Future<void> load({int? id, String? dataIn, String? dataOut}) async {
    AppLogger.info('COMPRAS LIST CONTROLLER: INICIANDO CARREGAMENTO');
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      _currentFilter = MovimentacaoFilterEntity(
        appUsersId: user.id,
        id: id,
        dataIn: dataIn,
        dataOut: dataOut,
      );

      final result = await _getComprasUsecase(_currentFilter!);
      _compras = result.data;
      _rows = result.rows;
      AppLogger.success(
        'COMPRAS LIST CONTROLLER: LISTA CARREGADA COM ${result.rows} REGISTROS',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'COMPRAS LIST CONTROLLER: ERRO AO LISTAR MSG=${error.message}',
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

    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _getComprasUsecase(filter);
      _compras = result.data;
      _rows = result.rows;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<CompraEntity?> findById(int compraId) async {
    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final result = await _getComprasUsecase(
        MovimentacaoFilterEntity(appUsersId: user.id, id: compraId),
      );
      return result.data.cast<CompraEntity?>().firstWhere(
        (item) => item?.id == compraId,
        orElse: () => null,
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'COMPRAS LIST CONTROLLER: ERRO AO BUSCAR COMPRA MSG=${error.message}',
      );
      rethrow;
    }
  }

  void removeById(int compraId) {
    _compras = _compras.where((item) => item.id != compraId).toList();
    _rows = _compras.length;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
