import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/usecases/get_sanitarios_usecase.dart';
import 'package:flutter/foundation.dart';

class ListSanitariosController extends ChangeNotifier {
  ListSanitariosController(this._getSanitariosUsecase);

  final GetSanitariosUsecase _getSanitariosUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  SanitariosListEntity _result = const SanitariosListEntity(rows: 0, lista: []);
  SanitariosFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  SanitariosListEntity get result => _result;
  List<SanitarioEntity> get sanitarios => _result.lista;
  List<SanitarioEntity> get planejados => _result.byStatus('planejado');
  List<SanitarioEntity> get executados => _result.byStatus('executado');

  Future<void> load({
    int? id,
    String? tipoManejo,
    String? dataIn,
    String? dataOut,
  }) async {
    AppLogger.info('SANITARIOS LIST CONTROLLER: INICIANDO CARREGAMENTO');
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuário não autenticado.');
      }

      _currentFilter = SanitariosFilterEntity(
        appUsersId: user.id,
        id: id,
        tipoManejo: tipoManejo,
        dataIn: dataIn,
        dataOut: dataOut,
      );

      _result = await _getSanitariosUsecase(_currentFilter!);
    } on ApiException catch (error) {
      _errorMessage = error.message;
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
      _result = await _getSanitariosUsecase(filter);
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
