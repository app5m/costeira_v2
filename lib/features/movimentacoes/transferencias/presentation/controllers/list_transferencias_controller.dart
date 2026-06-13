import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/transferencia_entity.dart';
import 'package:costeira/features/movimentacoes/domain/usecases/get_transferencias_usecase.dart';
import 'package:flutter/foundation.dart';

class ListTransferenciasController extends ChangeNotifier {
  ListTransferenciasController(this._getTransferenciasUsecase);

  final GetTransferenciasUsecase _getTransferenciasUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<TransferenciaEntity> _transferencias = const [];
  int _rows = 0;
  MovimentacaoFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TransferenciaEntity> get transferencias => _transferencias;
  int get rows => _rows;
  MovimentacaoFilterEntity? get currentFilter => _currentFilter;

  Future<void> load({int? id, String? dataIn, String? dataOut}) async {
    AppLogger.info('TRANSFERENCIAS LIST CONTROLLER: INICIANDO CARREGAMENTO');
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

      final result = await _getTransferenciasUsecase(_currentFilter!);
      _transferencias = result.data;
      _rows = result.rows;
      AppLogger.success(
        'TRANSFERENCIAS LIST CONTROLLER: LISTA CARREGADA COM ${result.data.length} REGISTROS',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'TRANSFERENCIAS LIST CONTROLLER: ERRO AO LISTAR MSG=${error.message}',
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
      final result = await _getTransferenciasUsecase(filter);
      _transferencias = result.data;
      _rows = result.rows;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void removeById(int id) {
    _transferencias = _transferencias.where((item) => item.id != id).toList();
    _rows = _transferencias.length;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
