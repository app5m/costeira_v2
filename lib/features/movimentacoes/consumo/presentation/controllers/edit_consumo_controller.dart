import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/usecases/update_consumo_usecase.dart';
import 'package:flutter/foundation.dart';

class EditConsumoController extends ChangeNotifier {
  EditConsumoController(this._updateConsumoUsecase, this._resolveCurrentFarmId);

  final UpdateConsumoUsecase _updateConsumoUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage?> submit(ConsumoUpsertEntity consumo) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final farmId = await _resolveCurrentFarmId(
        preferred: consumo.appFazendasId,
        userId: user.id,
      );
      if (farmId == null) {
        throw ApiException('Cadastre uma fazenda antes de editar o consumo.');
      }

      return await _updateConsumoUsecase(
        consumo.copyWith(appUsersId: user.id, appFazendasId: farmId),
      );
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
