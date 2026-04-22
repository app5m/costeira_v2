import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiros_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiros_usecase.dart';
import 'package:flutter/foundation.dart';

class ListPotreirosController extends ChangeNotifier {
  ListPotreirosController(this._getPotreirosUsecase);

  final GetPotreirosUsecase _getPotreirosUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<PotreiroEntity> _potreiros = const [];
  int _rows = 0;
  PotreirosFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<PotreiroEntity> get potreiros => _potreiros;
  int get rows => _rows;
  PotreirosFilterEntity? get currentFilter => _currentFilter;

  Future<void> load({int? id, String? statusAtual}) async {
    AppLogger.info('POTREIROS LIST CONTROLLER: INICIANDO CARREGAMENTO');
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuário não autenticado.');
      }

      _currentFilter = PotreirosFilterEntity(
        appUsersId: user.id,
        id: id,
        statusAtual: statusAtual,
      );

      final result = await _getPotreirosUsecase(_currentFilter!);
      _potreiros = result.data;
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

    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _getPotreirosUsecase(filter);
      _potreiros = result.data;
      _rows = result.rows;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void removeById(int potreiroId) {
    _potreiros = _potreiros.where((item) => item.id != potreiroId).toList();
    _rows = _potreiros.length;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
