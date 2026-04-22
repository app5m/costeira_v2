import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_charts_entity.dart';
import 'package:costeira/features/potreiros/domain/entities/potreiro_charts_filter_entity.dart';
import 'package:costeira/features/potreiros/domain/usecases/get_potreiro_charts_usecase.dart';
import 'package:flutter/foundation.dart';

class GetPotreiroChartsController extends ChangeNotifier {
  GetPotreiroChartsController(this._getPotreiroChartsUsecase);

  final GetPotreiroChartsUsecase _getPotreiroChartsUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  PotreiroChartsEntity? _charts;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PotreiroChartsEntity? get charts => _charts;

  Future<void> load() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuário não autenticado.');
      }

      _charts = await _getPotreiroChartsUsecase(
        PotreiroChartsFilterEntity(appUsersId: user.id),
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
