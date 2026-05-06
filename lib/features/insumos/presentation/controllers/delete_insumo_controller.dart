import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/core/storage/session_storage.dart';
import 'package:costeira/core/utils/app_logger.dart';
import 'package:costeira/features/insumos/domain/entities/insumos.dart';
import 'package:costeira/features/insumos/domain/usecases/delete_insumo_registro_usecase.dart';
import 'package:costeira/features/insumos/domain/usecases/delete_insumo_usecase.dart';
import 'package:flutter/foundation.dart';

class DeleteInsumoController extends ChangeNotifier {
  DeleteInsumoController(
    this._deleteInsumoUsecase,
    this._deleteInsumoRegistroUsecase,
  );

  final DeleteInsumoUsecase _deleteInsumoUsecase;
  final DeleteInsumoRegistroUsecase _deleteInsumoRegistroUsecase;

  bool _isLoading = false;
  String? _errorMessage;
  ApiMessage? _lastResult;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ApiMessage? get lastResult => _lastResult;

  Future<ApiMessage?> deleteInsumo(int insumoId) async {
    return _delete(
      id: insumoId,
      operationName: 'INSUMO',
      action: (entity) => _deleteInsumoUsecase(entity),
    );
  }

  Future<ApiMessage?> deleteRegistro(int registroId) async {
    return _delete(
      id: registroId,
      operationName: 'REGISTRO',
      action: (entity) => _deleteInsumoRegistroUsecase(entity),
    );
  }

  Future<ApiMessage?> _delete({
    required int id,
    required String operationName,
    required Future<ApiMessage> Function(DeleteInsumoEntity entity) action,
  }) async {
    AppLogger.warning(
      'INSUMOS DELETE CONTROLLER: INICIANDO EXCLUSAO $operationName ID=$id',
    );
    _setLoading(true);
    _errorMessage = null;

    try {
      final user = await SessionStorage.getUserSession();
      if (user == null) {
        throw ApiException('Usuario nao autenticado.');
      }

      final result = await action(
        DeleteInsumoEntity(appUsersId: user.id, id: id),
      );
      _lastResult = result;
      AppLogger.success(
        'INSUMOS DELETE CONTROLLER: EXCLUSAO $operationName CONCLUIDA STATUS=${result.status} MSG=${result.message}',
      );
      return result;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      AppLogger.error(
        'INSUMOS DELETE CONTROLLER: ERRO AO EXCLUIR $operationName MSG=${error.message}',
      );
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
