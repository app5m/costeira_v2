import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_upsert_entity.dart';
import 'package:costeira/features/animals/domain/usecases/create_animal_usecase.dart';
import 'package:flutter/foundation.dart';

class AddAnimalController extends ChangeNotifier {
  AddAnimalController(this._createAnimalUsecase);

  final CreateAnimalUsecase _createAnimalUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;
  int? _currentUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;
  int? get currentUserId => _currentUserId;

  Future<void> loadCurrentUser() async {
    AppLogger.info('ANIMAIS ADD CONTROLLER: CARREGANDO USUARIO DA SESSAO');
    final user = await SessionStorage.getUserSession();
    _currentUserId = user?.id;
    AppLogger.success(
      'ANIMAIS ADD CONTROLLER: USUARIO CARREGADO ID=${_currentUserId ?? 'NULL'}',
    );
    notifyListeners();
  }

  Future<ApiMessage?> submit(AnimalUpsertEntity animal) async {
    AppLogger.info('ANIMAIS ADD CONTROLLER: INICIANDO SUBMIT DE ANIMAL');
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUserId ??= (await SessionStorage.getUserSession())?.id;
      if (_currentUserId == null) {
        AppLogger.error('ANIMAIS ADD CONTROLLER: USUARIO NAO AUTENTICADO');
        throw ApiException('Usuário não autenticado.');
      }

      final result = await _createAnimalUsecase(
        animal.copyWith(appUsersId: _currentUserId),
      );
      _lastResult = result;
      AppLogger.success(
        'ANIMAIS ADD CONTROLLER: ANIMAL SALVO STATUS=${result.status} MSG=${result.message}',
      );
      return result;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'ANIMAIS ADD CONTROLLER: ERRO AO SALVAR ANIMAL MSG=${error.message}',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void clearFeedback() {
    AppLogger.debug('ANIMAIS ADD CONTROLLER: LIMPANDO FEEDBACK');
    _errorMessage = null;
    _lastResult = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    AppLogger.debug('ANIMAIS ADD CONTROLLER: LOADING=$value');
    notifyListeners();
  }
}
