import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_upsert_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/usecases/update_climate_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:flutter/foundation.dart';

class EditClimateController extends ChangeNotifier {
  EditClimateController(this._updateClimateUsecase, this._resolveCurrentFarmId);

  final UpdateClimateUsecase _updateClimateUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;
  int? _currentUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;

  void setCurrentClimate(ClimateEntity climate) {
    _currentUserId = climate.appUsersId;
  }

  Future<ApiMessage?> submit(ClimateUpsertEntity climate) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUserId ??= climate.appUsersId;
      _currentUserId ??= (await SessionStorage.getUserSession())?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farmId = await _farmId(_currentUserId!);

      final result = await _updateClimateUsecase(
        climate.copyWith(
          appUsersId: _currentUserId,
          appFazendasId: farmId,
        ),
      );
      _lastResult = result;
      return result;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<int> _farmId(int userId) async {
    final farmId = await _resolveCurrentFarmId(userId: userId);
    if (farmId == null || farmId <= 0) {
      throw ApiException('Selecione uma fazenda antes de atualizar o clima.');
    }
    return farmId;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
