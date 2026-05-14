import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/nascimento_entity.dart';
import 'package:costeira/features/movimentacoes/domain/usecases/get_nascimentos_usecase.dart';
import 'package:flutter/foundation.dart';

class ListNascimentosController extends ChangeNotifier {
  ListNascimentosController(this._getNascimentosUsecase);

  final GetNascimentosUsecase _getNascimentosUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<NascimentoEntity> _nascimentos = const [];
  int _rows = 0;
  MovimentacaoFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<NascimentoEntity> get nascimentos => _nascimentos;
  int get rows => _rows;
  MovimentacaoFilterEntity? get currentFilter => _currentFilter;

  Future<void> load({int? id, String? dataIn, String? dataOut}) async {
    AppLogger.info('NASCIMENTOS LIST CONTROLLER: INICIANDO CARREGAMENTO');
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

      final result = await _getNascimentosUsecase(_currentFilter!);
      _nascimentos = result.data;
      _rows = result.rows;
      AppLogger.success(
        'NASCIMENTOS LIST CONTROLLER: LISTA CARREGADA COM ${result.rows} REGISTROS',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'NASCIMENTOS LIST CONTROLLER: ERRO AO LISTAR MSG=${error.message}',
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
      final result = await _getNascimentosUsecase(filter);
      _nascimentos = result.data;
      _rows = result.rows;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
