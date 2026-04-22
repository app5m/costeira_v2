import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/potreiros/domain/entities/delete_potreiro_entity.dart';
import 'package:costeira/features/potreiros/domain/usecases/delete_potreiro_usecase.dart';
import 'package:flutter/foundation.dart';

class DeletePotreiroController extends ChangeNotifier {
  DeletePotreiroController(this._deletePotreiroUsecase);

  final DeletePotreiroUsecase _deletePotreiroUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;

  Future<ApiMessage?> delete(int potreiroId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuário não autenticado.');
      }

      final result = await _deletePotreiroUsecase(
        DeletePotreiroEntity(appUsersId: user.id, id: potreiroId),
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
