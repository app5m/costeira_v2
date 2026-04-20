import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/animals/domain/entities/delete_animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/usecases/delete_animal_lot_usecase.dart';
import 'package:flutter/foundation.dart';

class DeleteAnimalLotController extends ChangeNotifier {
  DeleteAnimalLotController(this._deleteAnimalLotUsecase);

  final DeleteAnimalLotUsecase _deleteAnimalLotUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;

  Future<ApiMessage?> delete(int lotId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuário não autenticado.');
      }

      final result = await _deleteAnimalLotUsecase(
        DeleteAnimalLotEntity(appUsersId: user.id, id: lotId),
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
