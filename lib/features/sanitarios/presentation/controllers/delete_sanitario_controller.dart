import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/sanitarios/domain/entities/sanitario.dart';
import 'package:costeira/features/sanitarios/domain/usecases/delete_sanitario_usecase.dart';
import 'package:flutter/foundation.dart';

class DeleteSanitarioController extends ChangeNotifier {
  DeleteSanitarioController(this._deleteSanitarioUsecase);

  final DeleteSanitarioUsecase _deleteSanitarioUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;

  Future<ApiMessage?> deleteSanitario(int sanitarioId) async {
    AppLogger.warning(
      'SANITARIOS DELETE CONTROLLER: INICIANDO EXCLUSAO ID=$sanitarioId',
    );
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final result = await _deleteSanitarioUsecase(
        DeleteSanitarioEntity(appUsersId: user.id, id: sanitarioId),
      );
      _lastResult = result;
      AppLogger.success(
        'SANITARIOS DELETE CONTROLLER: EXCLUSAO CONCLUIDA STATUS=${result.status} MSG=${result.message}',
      );
      return result;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'SANITARIOS DELETE CONTROLLER: ERRO AO EXCLUIR MSG=${error.message}',
      );
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
