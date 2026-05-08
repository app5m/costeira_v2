import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/manejo_filter.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/get_manejos_usecase.dart';
import 'package:flutter/foundation.dart';

class ListManejosController extends ChangeNotifier {
  ListManejosController(this._getManejosUsecase);

  final GetManejosUsecase _getManejosUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<Manejo> _manejos = const [];
  List<TipoManejo> _tiposManejo = const [];
  int _rows = 0;
  ManejoFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Manejo> get manejos => _manejos;
  List<TipoManejo> get tiposManejo => _tiposManejo;
  int get rows => _rows;
  ManejoFilterEntity? get currentFilter => _currentFilter;

  Future<void> load({int? id, int? idPotreiro}) async {
    AppLogger.info('MANEJO LIST CONTROLLER: INICIANDO CARREGAMENTO');
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      _currentFilter = ManejoFilterEntity(appUsersId: user.id, id: id, idPotreiro: idPotreiro);

      final result = await _getManejosUsecase(_currentFilter!);
      _manejos = result.manejos;
      _tiposManejo = result.tiposManejo;
      _rows = result.rows;
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

    await load(id: filter.id, idPotreiro: filter.idPotreiro);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
