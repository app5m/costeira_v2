import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/entities/abigeato_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/abigeatos/domain/usecases/update_abigeato_usecase.dart';
import 'package:flutter/foundation.dart';

class EditAbigeatoController extends ChangeNotifier {
  EditAbigeatoController(this._updateAbigeatoUsecase);

  final UpdateAbigeatoUsecase _updateAbigeatoUsecase;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage?> submit(AbigeatoUpsertEntity abigeato) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      return await _updateAbigeatoUsecase(
        abigeato.copyWith(appUsersId: user.id),
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
