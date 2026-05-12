import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/features/movimentacoes/compras/domain/entities/delete_compra_entity.dart';
import 'package:costeira/features/movimentacoes/compras/domain/usecases/delete_compra_usecase.dart';
import 'package:flutter/foundation.dart';

class DeleteCompraController extends ChangeNotifier {
  DeleteCompraController(this._deleteCompraUsecase);

  final DeleteCompraUsecase _deleteCompraUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;

  Future<ApiMessage?> delete(int compraId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final result = await _deleteCompraUsecase(
        DeleteCompraEntity(appUsersId: user.id, id: compraId),
      );
      _lastResult = result;
      return result;
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
