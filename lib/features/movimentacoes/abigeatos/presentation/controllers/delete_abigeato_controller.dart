import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/delete_abigeato_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/usecases/delete_abigeato_usecase.dart';
import 'package:flutter/foundation.dart';

class DeleteAbigeatoController extends ChangeNotifier {
  DeleteAbigeatoController(this._deleteAbigeatoUsecase);

  final DeleteAbigeatoUsecase _deleteAbigeatoUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;

  Future<ApiMessage?> delete(int abigeatoId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final result = await _deleteAbigeatoUsecase(
        DeleteAbigeatoEntity(appUsersId: user.id, id: abigeatoId),
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
