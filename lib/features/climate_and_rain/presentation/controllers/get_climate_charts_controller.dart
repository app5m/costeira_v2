import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_charts_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/climate_charts_filter_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/usecases/get_climate_charts_usecase.dart';
import 'package:flutter/foundation.dart';

class GetClimateChartsController extends ChangeNotifier {
  GetClimateChartsController(this._getClimateChartsUsecase);

  final GetClimateChartsUsecase _getClimateChartsUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ClimateChartsEntity? _charts;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ClimateChartsEntity? get charts => _charts;

  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      _charts = await _getClimateChartsUsecase(
        ClimateChartsFilterEntity(appUsersId: user.id),
      );
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
