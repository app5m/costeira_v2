import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/movimentacoes/domain/entities/morte_entity.dart';
import 'package:costeira/features/movimentacoes/domain/entities/movimentacao_filter_entity.dart';
import 'package:costeira/features/movimentacoes/domain/usecases/get_mortes_usecase.dart';
import 'package:flutter/foundation.dart';

class ListMortesController extends ChangeNotifier {
  ListMortesController(this._getMortesUsecase);

  final GetMortesUsecase _getMortesUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<MorteEntity> _mortes = const [];
  int _rows = 0;
  MovimentacaoFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MorteEntity> get mortes => _mortes;
  int get rows => _rows;
  MovimentacaoFilterEntity? get currentFilter => _currentFilter;

  Future<void> load({int? id, String? dataIn, String? dataOut}) async {
    AppLogger.info('MORTES LIST CONTROLLER: INICIANDO CARREGAMENTO');
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

      final result = await _getMortesUsecase(_currentFilter!);
      _mortes = result.data;
      _rows = result.rows;
      AppLogger.success(
        'MORTES LIST CONTROLLER: LISTA CARREGADA COM ${result.data.length} REGISTROS',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'MORTES LIST CONTROLLER: ERRO AO LISTAR MSG=${error.message}',
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
      final result = await _getMortesUsecase(filter);
      _mortes = result.data;
      _rows = result.rows;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void removeById(int morteId) {
    _mortes = _mortes.where((item) => item.id != morteId).toList();
    _rows = _mortes.length;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
