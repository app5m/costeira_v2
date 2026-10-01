import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/entities/transferencia_fazenda_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/transferencias/domain/usecases/update_transferencia_fazenda_usecase.dart';
import 'package:flutter/foundation.dart';

class EditTransferenciaFazendaController extends ChangeNotifier {
  EditTransferenciaFazendaController(
    this._updateUsecase,
    this._resolveCurrentFarmId,
  );

  final UpdateTransferenciaFazendaUsecase _updateUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage?> submit(
    TransferenciaFazendaUpsertEntity transferencia,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final farmId = await _resolveCurrentFarmId(
        preferred: transferencia.appFazendasId,
        userId: user.id,
      );
      if (farmId == null) {
        throw ApiException(
          'Cadastre uma fazenda antes de editar a transferencia.',
        );
      }

      return await _updateUsecase(
        transferencia.copyWith(appUsersId: user.id, appFazendasId: farmId),
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
