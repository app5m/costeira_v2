import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/entities/troca_categoria_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/troca_categoria/domain/usecases/update_troca_categoria_usecase.dart';
import 'package:flutter/foundation.dart';

class EditTrocaCategoriaController extends ChangeNotifier {
  EditTrocaCategoriaController(this._updateTrocaCategoriaUsecase, this._resolveCurrentFarmId);

  final UpdateTrocaCategoriaUsecase _updateTrocaCategoriaUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage?> submit(TrocaCategoriaUpsertEntity troca) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final farmId = await _resolveCurrentFarmId(
        preferred: troca.appFazendasId,
        userId: user.id,
      );
      if (farmId == null) {
        throw ApiException('Cadastre uma fazenda antes de editar a troca de categoria.');
      }

      return await _updateTrocaCategoriaUsecase(
        troca.copyWith(appUsersId: user.id, appFazendasId: farmId),
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
