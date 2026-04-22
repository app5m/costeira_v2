import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/climate_and_rain/domain/entities/delete_climate_entity.dart';
import 'package:costeira/features/climate_and_rain/domain/usecases/delete_climate_usecase.dart';
import 'package:flutter/foundation.dart';

class DeleteClimateController extends ChangeNotifier {
  DeleteClimateController(this._deleteClimateUsecase);

  final DeleteClimateUsecase _deleteClimateUsecase;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage?> delete(int climateId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      return _deleteClimateUsecase(
        DeleteClimateEntity(appUsersId: user.id, id: climateId),
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
