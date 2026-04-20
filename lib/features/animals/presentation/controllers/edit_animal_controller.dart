import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_upsert_entity.dart';
import 'package:costeira/features/animals/domain/usecases/update_animal_usecase.dart';
import 'package:flutter/foundation.dart';

class EditAnimalController extends ChangeNotifier {
  EditAnimalController(this._updateAnimalUsecase);

  final UpdateAnimalUsecase _updateAnimalUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;
  AnimalEntity? _initialAnimal;
  int? _currentUserId;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;
  AnimalEntity? get initialAnimal => _initialAnimal;
  int? get currentUserId => _currentUserId;

  void setInitialAnimal(AnimalEntity animal) {
    AppLogger.info(
      'ANIMAIS EDIT CONTROLLER: DEFININDO ANIMAL INICIAL ID=${animal.id}',
    );
    _initialAnimal = animal;
    _currentUserId = animal.appUsersId;
    notifyListeners();
  }

  AnimalUpsertEntity? get initialFormValue {
    final animal = _initialAnimal;
    if (animal == null) {
      return null;
    }

    return AnimalUpsertEntity(
      id: animal.id,
      appUsersId: animal.appUsersId,
      appAnimaisCategoriasId: animal.appAnimaisCategoriasId,
      appAnimaisSubcategoriasId: animal.appAnimaisSubcategoriasId,
      utBasesRaciaisId: animal.utBasesRaciaisId,
      appAnimaisLotesId: animal.appAnimaisLotesId,
      appPotreirosId: animal.appPotreirosId,
      sexo: animal.sexo,
      brinco: animal.brinco,
      peso: animal.peso?.toString(),
      obs: animal.obs,
      status: animal.status,
    );
  }

  Future<ApiMessage?> submit(AnimalUpsertEntity animal) async {
    AppLogger.info('ANIMAIS EDIT CONTROLLER: INICIANDO SUBMIT DE EDICAO');
    _setLoading(true);
    _errorMessage = null;

    try {
      _currentUserId ??= (await SessionStorage.getUserSession())?.id;
      if (_currentUserId == null) {
        AppLogger.error('ANIMAIS EDIT CONTROLLER: USUARIO NAO AUTENTICADO');
        throw ApiException('Usuário não autenticado.');
      }

      final result = await _updateAnimalUsecase(
        animal.copyWith(appUsersId: _currentUserId),
      );
      _lastResult = result;
      AppLogger.success(
        'ANIMAIS EDIT CONTROLLER: ANIMAL ATUALIZADO STATUS=${result.status} MSG=${result.message}',
      );
      return result;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'ANIMAIS EDIT CONTROLLER: ERRO AO ATUALIZAR ANIMAL MSG=${error.message}',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void clearFeedback() {
    AppLogger.debug('ANIMAIS EDIT CONTROLLER: LIMPANDO FEEDBACK');
    _errorMessage = null;
    _lastResult = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    AppLogger.debug('ANIMAIS EDIT CONTROLLER: LOADING=$value');
    notifyListeners();
  }
}
