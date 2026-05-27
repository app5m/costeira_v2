import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/entities/consumo_upsert_entity.dart';
import 'package:costeira/features/movimentacoes/consumo/domain/usecases/create_consumo_usecase.dart';
import 'package:flutter/foundation.dart';

class AddConsumoController extends ChangeNotifier {
  AddConsumoController(this._createConsumoUsecase);

  final CreateConsumoUsecase _createConsumoUsecase;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage?> submit(ConsumoUpsertEntity consumo) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      return await _createConsumoUsecase(consumo.copyWith(appUsersId: user.id));
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
