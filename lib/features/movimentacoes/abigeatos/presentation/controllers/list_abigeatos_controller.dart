import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/domain/entities/abigeato_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/usecases/get_abigeatos_usecase.dart';
import 'package:flutter/foundation.dart';

class ListAbigeatosController extends ChangeNotifier {
  ListAbigeatosController(this._getAbigeatosUsecase);

  final GetAbigeatosUsecase _getAbigeatosUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<AbigeatoEntity> _abigeatos = const [];
  int _rows = 0;
  MovimentacaoFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AbigeatoEntity> get abigeatos => _abigeatos;
  int get rows => _rows;
  MovimentacaoFilterEntity? get currentFilter => _currentFilter;

  Future<void> load({int? id, String? dataIn, String? dataOut}) async {
    AppLogger.info('ABIGEATOS LIST CONTROLLER: INICIANDO CARREGAMENTO');
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

      final result = await _getAbigeatosUsecase(_currentFilter!);
      _abigeatos = result.data;
      _rows = result.rows;
      AppLogger.success(
        'ABIGEATOS LIST CONTROLLER: LISTA CARREGADA COM ${result.data.length} REGISTROS',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'ABIGEATOS LIST CONTROLLER: ERRO AO LISTAR MSG=${error.message}',
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
      final result = await _getAbigeatosUsecase(filter);
      _abigeatos = result.data;
      _rows = result.rows;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void removeById(int id) {
    _abigeatos = _abigeatos.where((item) => item.id != id).toList();
    _rows = _abigeatos.length;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
