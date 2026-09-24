import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_entity.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_filter_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/get_fazendas_usecase.dart';
import 'package:flutter/foundation.dart';

class ListFazendasController extends ChangeNotifier {
  ListFazendasController(this._getFazendasUsecase);

  final GetFazendasUsecase _getFazendasUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<FazendaEntity> _fazendas = const [];
  FazendaFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<FazendaEntity> get fazendas => _fazendas;

  Future<void> load() async {
    AppLogger.info('FAZENDAS LIST CONTROLLER: INICIANDO CARREGAMENTO');
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      _currentFilter = FazendaFilterEntity(appUsersId: user.id);
      final result = await _getFazendasUsecase(_currentFilter!);
      _fazendas = result.data;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reload() async {
    if (_currentFilter == null) {
      await load();
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _getFazendasUsecase(_currentFilter!);
      _fazendas = result.data;
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
