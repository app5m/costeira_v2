import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/animals/domain/entities/animal_charts_entity.dart';
import 'package:costeira/features/animals/domain/entities/animal_charts_filter_entity.dart';
import 'package:costeira/features/animals/domain/usecases/get_animal_charts_usecase.dart';
import 'package:flutter/foundation.dart';

class GetAnimalChartsController extends ChangeNotifier {
  GetAnimalChartsController(this._getAnimalChartsUsecase);

  final GetAnimalChartsUsecase _getAnimalChartsUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  AnimalChartsEntity? _charts;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AnimalChartsEntity? get charts => _charts;

  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuário não autenticado.');
      }

      final filter = AnimalChartsFilterEntity(appUsersId: user.id);
      _charts = await _getAnimalChartsUsecase(filter);
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
