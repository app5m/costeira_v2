import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/usecases/create_sanitario_usecase.dart';
import 'package:costeira/features/sanitarios/domain/usecases/update_sanitario_usecase.dart';
import 'package:flutter/foundation.dart';

class SanitarioFormController extends ChangeNotifier {
  SanitarioFormController(
    this._createSanitarioUsecase,
    this._updateSanitarioUsecase,
  );

  final CreateSanitarioUsecase _createSanitarioUsecase;
  final UpdateSanitarioUsecase _updateSanitarioUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;
  int? _currentUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;

  Future<ApiMessage?> submit(SanitarioUpsertEntity sanitario) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUserId ??= (await SessionStorage.getUserSession())?.id;
      if (_currentUserId == null) {
        throw ApiException('Usuário não autenticado.');
      }

      final request = sanitario.copyWith(appUsersId: _currentUserId);
      final result = request.id == null
          ? await _createSanitarioUsecase(request)
          : await _updateSanitarioUsecase(request);
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
