import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/delete_animal_entity.dart';
import 'package:costeira/features/animals/domain/usecases/delete_animal_usecase.dart';
import 'package:flutter/foundation.dart';

class DeleteAnimalController extends ChangeNotifier {
  DeleteAnimalController(this._deleteAnimalUsecase);

  final DeleteAnimalUsecase _deleteAnimalUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;

  Future<ApiMessage?> delete(int animalId) async {
    AppLogger.warning(
      'ANIMAIS DELETE CONTROLLER: INICIANDO EXCLUSAO ID=$animalId',
    );
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        AppLogger.error('ANIMAIS DELETE CONTROLLER: USUARIO NAO AUTENTICADO');
        throw ApiException('Usuário não autenticado.');
      }

      final result = await _deleteAnimalUsecase(
        DeleteAnimalEntity(appUsersId: user.id, id: animalId),
      );
      _lastResult = result;
      AppLogger.success(
        'ANIMAIS DELETE CONTROLLER: EXCLUSAO CONCLUIDA STATUS=${result.status} MSG=${result.message}',
      );
      return result;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'ANIMAIS DELETE CONTROLLER: ERRO AO EXCLUIR MSG=${error.message}',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void clearFeedback() {
    AppLogger.debug('ANIMAIS DELETE CONTROLLER: LIMPANDO FEEDBACK');
    _errorMessage = null;
    _lastResult = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    AppLogger.debug('ANIMAIS DELETE CONTROLLER: LOADING=$value');
    notifyListeners();
  }
}
