import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/entities/suplemento.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/delete_suplemento_registro_usecase.dart';
import 'package:costeira/features/pastagem_nutricao_suplemento/domain/usecases/delete_suplemento_usecase.dart';
import 'package:flutter/foundation.dart';

class DeleteSuplementoController extends ChangeNotifier {
  DeleteSuplementoController(
    this._deleteSuplementoUsecase,
    this._deleteRegistroUsecase,
  );

  final DeleteSuplementoUsecase _deleteSuplementoUsecase;
  final DeleteSuplementoRegistroUsecase _deleteRegistroUsecase;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage> deleteSuplemento(int id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      return _deleteSuplementoUsecase(
        DeleteSuplementoEntity(appUsersId: user.id, id: id),
      );
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<ApiMessage> deleteRegistro(int id) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      return _deleteRegistroUsecase(
        DeleteSuplementoRegistroEntity(appUsersId: user.id, id: id),
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
