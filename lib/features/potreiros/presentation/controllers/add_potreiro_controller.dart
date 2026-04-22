import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_upsert_entity.dart';
import 'package:costeira/features/potreiros/domain/usecases/create_potreiro_usecase.dart';
import 'package:flutter/foundation.dart';

class AddPotreiroController extends ChangeNotifier {
  AddPotreiroController(this._createPotreiroUsecase);

  final CreatePotreiroUsecase _createPotreiroUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;
  int? _currentUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;
  int? get currentUserId => _currentUserId;

  Future<ApiMessage?> submit(PotreiroUpsertEntity potreiro) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUserId ??= (await SessionStorage.getUserSession())?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuário não autenticado.');
      }

      final result = await _createPotreiroUsecase(
        potreiro.copyWith(appUsersId: _currentUserId),
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
