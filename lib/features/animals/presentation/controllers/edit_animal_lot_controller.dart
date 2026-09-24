import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_upsert_entity.dart';
import 'package:costeira/features/animals/domain/usecases/update_animal_lot_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:flutter/foundation.dart';

class EditAnimalLotController extends ChangeNotifier {
  EditAnimalLotController(
    this._updateAnimalLotUsecase,
    this._resolveCurrentFarmId,
  );

  final UpdateAnimalLotUsecase _updateAnimalLotUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;
  AnimalLotEntity? _initialLot;
  int? _currentUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;
  AnimalLotEntity? get initialLot => _initialLot;
  int? get currentUserId => _currentUserId;

  void setInitialLot(AnimalLotEntity lot) {
    _initialLot = lot;
    _currentUserId = lot.appUsersId;
    notifyListeners();
  }

  AnimalLotUpsertEntity? get initialFormValue {
    final lot = _initialLot;
    if (lot == null) {
      return null;
    }

    return AnimalLotUpsertEntity(
      id: lot.id,
      appUsersId: lot.appUsersId,
      nome: lot.nome,
    );
  }

  Future<ApiMessage?> submit(AnimalLotUpsertEntity lot) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUserId ??= (await SessionStorage.getUserSession())?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuário não autenticado.');
      }

      final farmId = await _resolveCurrentFarmId(
        preferred: lot.appFazendasId,
        userId: _currentUserId,
      );
      if (farmId == null) {
        throw ApiException('Cadastre uma fazenda antes de editar o lote.');
      }

      final result = await _updateAnimalLotUsecase(
        lot.copyWith(appUsersId: _currentUserId, appFazendasId: farmId),
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

  void clearFeedback() {
    _errorMessage = null;
    _lastResult = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
