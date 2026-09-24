import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/fazendas/domain/entities/fazenda_upsert_entity.dart';
import 'package:costeira/features/fazendas/domain/usecases/create_fazenda_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/update_fazenda_usecase.dart';
import 'package:flutter/foundation.dart';

class SaveFazendaController extends ChangeNotifier {
  SaveFazendaController(this._createFazendaUsecase, this._updateFazendaUsecase);

  final CreateFazendaUsecase _createFazendaUsecase;
  final UpdateFazendaUsecase _updateFazendaUsecase;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage> save(FazendaUpsertEntity fazenda) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final payload = fazenda.copyWith(appUsersId: user.id);
      if (payload.id == null) {
        return _createFazendaUsecase(payload);
      }
      return _updateFazendaUsecase(payload);
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
