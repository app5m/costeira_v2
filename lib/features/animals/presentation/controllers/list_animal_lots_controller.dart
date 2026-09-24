import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/animals/domain/entities/animal_lot_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_lots_filter_entity.dart';
import 'package:costeira/features/animals/domain/usecases/get_animal_lots_usecase.dart';
import 'package:costeira/features/fazendas/domain/usecases/resolve_current_farm_id.dart';
import 'package:flutter/foundation.dart';

class ListAnimalLotsController extends ChangeNotifier {
  ListAnimalLotsController(
    this._getAnimalLotsUsecase,
    this._resolveCurrentFarmId,
  );

  final GetAnimalLotsUsecase _getAnimalLotsUsecase;
  final ResolveCurrentFarmId _resolveCurrentFarmId;

  bool _isLoading = false;
  String? _errorMessage;
  List<AnimalLotEntity> _lots = const [];
  int _rows = 0;
  AnimalLotsFilterEntity? _currentFilter;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AnimalLotEntity> get lots => _lots;
  int get rows => _rows;
  AnimalLotsFilterEntity? get currentFilter => _currentFilter;

  Future<void> load({int? id, String? nome, int? appFazendasId}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null || user.id <= 0) {
        throw ApiException('Usuário não autenticado.');
      }

      final farmId = await _resolveCurrentFarmId(
        preferred: appFazendasId,
        userId: user.id,
      );
      if (farmId == null) {
        _lots = const [];
        _rows = 0;
        _errorMessage = 'Cadastre uma fazenda antes.';
        return;
      }

      _currentFilter = AnimalLotsFilterEntity(
        appUsersId: user.id,
        appFazendasId: farmId,
        id: id,
        nome: nome,
      );

      final result = await _getAnimalLotsUsecase(_currentFilter!);
      _lots = result.data;
      _rows = result.rows;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> reload() async {
    final filter = _currentFilter;
    if (filter == null) {
      await load();
      return;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final result = await _getAnimalLotsUsecase(filter);
      _lots = result.data;
      _rows = result.rows;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void removeLotById(int lotId) {
    _lots = _lots.where((lot) => lot.id != lotId).toList();
    _rows = _lots.length;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
