import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_upsert_entity.dart';
import 'package:costeira/features/animals/domain/usecases/create_animal_lot_usecase.dart';
import 'package:flutter/foundation.dart';

class AddAnimalLotController extends ChangeNotifier {
  AddAnimalLotController(this._createAnimalLotUsecase);

  final CreateAnimalLotUsecase _createAnimalLotUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;
  int? _currentUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;
  int? get currentUserId => _currentUserId;

  Future<void> loadCurrentUser() async {
    final user = await SessionStorage.getUserSession();
    _currentUserId = user?.id;
    notifyListeners();
  }

  Future<ApiMessage?> submit(AnimalLotUpsertEntity lot) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUserId ??= (await SessionStorage.getUserSession())?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuário não autenticado.');
      }

      final result = await _createAnimalLotUsecase(
        lot.copyWith(appUsersId: _currentUserId),
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
