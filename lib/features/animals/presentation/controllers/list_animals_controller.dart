import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/animals/domain/entities/animal_entity.dart';
import 'package:costeira/features/animals/domain/entities/animals_filter_entity.dart';
import 'package:costeira/features/animals/domain/usecases/get_animals_usecase.dart';
import 'package:flutter/foundation.dart';

class ListAnimalsController extends ChangeNotifier {
  ListAnimalsController(this._getAnimalsUsecase);

  final GetAnimalsUsecase _getAnimalsUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  List<AnimalEntity> _animals = const [];
  int _rows = 0;
  AnimalsFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AnimalEntity> get animals => _animals;
  int get rows => _rows;
  AnimalsFilterEntity? get currentFilter => _currentFilter;

  Future<void> load({
    int? id,
    int? appAnimaisCategoriasId,
    int? appAnimaisSubcategoriasId,
    int? utBasesRaciaisId,
    String? brinco,
  }) async {
    AppLogger.info(
      'ANIMAIS LIST CONTROLLER: INICIANDO CARREGAMENTO DE ANIMAIS',
    );
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        AppLogger.error('ANIMAIS LIST CONTROLLER: USUARIO NAO AUTENTICADO');
        throw ApiException('Usuário não autenticado.');
      }

      _currentFilter = AnimalsFilterEntity(
        appUsersId: user.id,
        id: id,
        appAnimaisCategoriasId: appAnimaisCategoriasId,
        appAnimaisSubcategoriasId: appAnimaisSubcategoriasId,
        utBasesRaciaisId: utBasesRaciaisId,
        brinco: brinco,
      );

      final result = await _getAnimalsUsecase(_currentFilter!);
      _animals = result.data;
      _rows = result.rows;
      AppLogger.success(
        'ANIMAIS LIST CONTROLLER: LISTA CARREGADA COM ${result.rows} REGISTROS',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'ANIMAIS LIST CONTROLLER: ERRO AO LISTAR ANIMAIS MSG=${error.message}',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reload() async {
    AppLogger.info('ANIMAIS LIST CONTROLLER: RECARREGANDO LISTA');
    final filter = _currentFilter;
    if (filter == null) {
      await load();
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _getAnimalsUsecase(filter);
      _animals = result.data;
      _rows = result.rows;
      AppLogger.success(
        'ANIMAIS LIST CONTROLLER: RELOAD CONCLUIDO COM ${result.rows} REGISTROS',
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'ANIMAIS LIST CONTROLLER: ERRO NO RELOAD MSG=${error.message}',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void removeAnimalById(int animalId) {
    AppLogger.warning(
      'ANIMAIS LIST CONTROLLER: REMOVENDO ANIMAL ID=$animalId DA LISTA LOCAL',
    );
    _animals = _animals.where((animal) => animal.id != animalId).toList();
    _rows = _animals.length;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    AppLogger.debug('ANIMAIS LIST CONTROLLER: LOADING=$value');
    notifyListeners();
  }
}
