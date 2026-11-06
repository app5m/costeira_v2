import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_filter_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/usecases/get_climates_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:flutter/foundation.dart';

class ListClimatesController extends ChangeNotifier {
  ListClimatesController(this._getClimatesUsecase, this._resolveCurrentFarmId);

  final GetClimatesUsecase _getClimatesUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isLoading = false;
  String? _errorMessage;
  List<ClimateEntity> _climates = const [];
  int _rows = 0;
  ClimateFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ClimateEntity> get climates => _climates;
  int get rows => _rows;
  ClimateFilterEntity? get currentFilter => _currentFilter;

  Future<void> load({int? id, String? dataIn, String? dataOut}) async {
    AppLogger.info('CLIMATE LIST CONTROLLER: INICIANDO CARREGAMENTO');
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farmId = await _farmId(user.id);

      _currentFilter = ClimateFilterEntity(
        appUsersId: user.id,
        appFazendasId: farmId,
        id: id,
        dataIn: dataIn,
        dataOut: dataOut,
      );

      final result = await _getClimatesUsecase(_currentFilter!);
      _climates = result.data;
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
      final result = await _getClimatesUsecase(filter);
      _climates = result.data;
      _rows = result.rows;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void removeById(int climateId) {
    _climates = _climates.where((item) => item.id != climateId).toList();
    _rows = _climates.length;
    notifyListeners();
  }

  Future<int> _farmId(int userId) async {
    final farmId = await _resolveCurrentFarmId(userId: userId);
    if (farmId == null || farmId <= 0) {
      throw ApiException('Selecione uma fazenda antes de ver o clima.');
    }
    return farmId;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
