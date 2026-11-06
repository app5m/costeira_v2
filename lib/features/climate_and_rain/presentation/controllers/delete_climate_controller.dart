import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/delete_climate_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/usecases/delete_climate_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:flutter/foundation.dart';

class DeleteClimateController extends ChangeNotifier {
  DeleteClimateController(
    this._deleteClimateUsecase,
    this._resolveCurrentFarmId,
  );

  final DeleteClimateUsecase _deleteClimateUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage?> delete(int climateId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }
      final farmId = await _farmId(user.id);

      return _deleteClimateUsecase(
        DeleteClimateEntity(
          appUsersId: user.id,
          appFazendasId: farmId,
          id: climateId,
        ),
      );
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
      throw ApiException('Selecione uma fazenda antes de excluir o clima.');
    }
    return farmId;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
