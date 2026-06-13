import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/troca_categoria_entity.dart';
import 'package:costeira/features/movimentacoes/domain/usecases/get_troca_categoria_usecase.dart';
import 'package:flutter/foundation.dart';

class ListTrocaCategoriaController extends ChangeNotifier {
  ListTrocaCategoriaController(this._getTrocaCategoriaUsecase);

  final GetTrocaCategoriaUsecase _getTrocaCategoriaUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<TrocaCategoriaEntity> _trocas = const [];
  int _rows = 0;
  MovimentacaoFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TrocaCategoriaEntity> get trocas => _trocas;
  int get rows => _rows;
  MovimentacaoFilterEntity? get currentFilter => _currentFilter;

  Future<void> load({int? id, String? dataIn, String? dataOut}) async {
    AppLogger.info('TROCA CATEGORIA LIST CONTROLLER: INICIANDO CARREGAMENTO');
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

      final result = await _getTrocaCategoriaUsecase(_currentFilter!);
      _trocas = result.data;
      _rows = result.rows;
      AppLogger.success(
        'TROCA CATEGORIA LIST CONTROLLER: LISTA CARREGADA COM ${result.rows} REGISTROS',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'TROCA CATEGORIA LIST CONTROLLER: ERRO AO LISTAR MSG=${error.message}',
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
      final result = await _getTrocaCategoriaUsecase(filter);
      _trocas = result.data;
      _rows = result.rows;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void removeById(int id) {
    _trocas = _trocas.where((item) => item.id != id).toList();
    _rows = _trocas.length;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
