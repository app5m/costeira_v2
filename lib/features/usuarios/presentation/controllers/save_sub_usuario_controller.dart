import 'package:costeira/core/api/api_exception.dart';
import 'package:costeira/core/models/api_message.dart';
import 'package:costeira/features/usuarios/domain/entities/sub_usuario_upsert_entity.dart';
import 'package:costeira/features/usuarios/domain/usecases/save_sub_usuario_usecase.dart';
import 'package:flutter/foundation.dart';

class SaveSubUsuarioController extends ChangeNotifier {
  SaveSubUsuarioController(this._saveSubUsuarioUsecase);

  final SaveSubUsuarioUsecase _saveSubUsuarioUsecase;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<ApiMessage> save(SubUsuarioUpsertEntity usuario) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      return await _saveSubUsuarioUsecase(usuario);
    } on ApiException catch (error) {
      _errorMessage = error.message;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
