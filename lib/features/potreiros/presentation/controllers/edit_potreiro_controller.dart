import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_upsert_entity.dart';
import 'package:costeira/features/potreiros/domain/usecases/update_potreiro_usecase.dart';
import 'package:flutter/foundation.dart';

class EditPotreiroController extends ChangeNotifier {
  EditPotreiroController(
    this._updatePotreiroUsecase,
    this._resolveCurrentFarmId,
  );

  final UpdatePotreiroUsecase _updatePotreiroUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;
  PotreiroEntity? _initialPotreiro;
  int? _currentUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;
  PotreiroEntity? get initialPotreiro => _initialPotreiro;
  int? get currentUserId => _currentUserId;

  void setInitialPotreiro(PotreiroEntity potreiro) {
    _initialPotreiro = potreiro;
    _currentUserId = potreiro.appUsersId;
    notifyListeners();
  }

  Future<ApiMessage?> submit(PotreiroUpsertEntity potreiro) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUserId ??= (await SessionStorage.getUserSession())?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuário não autenticado.');
      }

      final farmId = await _resolveCurrentFarmId(
        preferred: potreiro.appFazendasId,
        userId: _currentUserId,
      );
      if (farmId == null) {
        throw ApiException('Cadastre uma fazenda antes de editar o piquete.');
      }

      final result = await _updatePotreiroUsecase(
        potreiro.copyWith(appUsersId: _currentUserId, appFazendasId: farmId),
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
