import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_upsert_entity.dart';
import 'package:costeira/features/cadastros/domain/usecases/create_parceiro_usecase.dart';
import 'package:costeira/features/cadastros/domain/usecases/update_parceiro_usecase.dart';
import 'package:flutter/foundation.dart';

class SaveParceiroController extends ChangeNotifier {
  SaveParceiroController(
    this._createParceiroUsecase,
    this._updateParceiroUsecase,
  );

  final CreateParceiroUsecase _createParceiroUsecase;
  final UpdateParceiroUsecase _updateParceiroUsecase;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage> save(ParceiroUpsertEntity parceiro) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final payload = parceiro.copyWith(appUsersId: user.id);
      if (payload.id == null) {
        return _createParceiroUsecase(payload);
      }
      return _updateParceiroUsecase(payload);
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
