import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/cadastros/domain/entities/delete_parceiro_entity.dart';
import 'package:costeira/features/cadastros/domain/entities/parceiro_kind.dart';
import 'package:costeira/features/cadastros/domain/usecases/delete_parceiro_usecase.dart';
import 'package:flutter/foundation.dart';

class DeleteParceiroController extends ChangeNotifier {
  DeleteParceiroController(this._deleteParceiroUsecase);

  final DeleteParceiroUsecase _deleteParceiroUsecase;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage> delete({
    required ParceiroKind kind,
    required int id,
  }) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      return await _deleteParceiroUsecase(
        DeleteParceiroEntity(kind: kind, id: id),
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
